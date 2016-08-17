
PYTHON_EXECUTABLE=$(shell which python3.4)
CATALINA_EXECUTABLE=/usr/share/tomcat7/bin/catalina.sh
ELASTICSEARCH_EXECUTABLE=/usr/share/elasticsearch/bin/elasticsearch
ELASTICSEARCH_INCLUDES=/usr/share/elasticsearch/bin/elasticsearch.in.sh
# should a postgres be started and where is the postgres executable
POSTGRES_DEDICATED=true
POSTGRES_ADMIN=${USER}
ifeq ($(wildcard /usr/lib/postgresql/9.4),)
	POSTGRES_BIN_PATH=/usr/lib/postgresql/9.3/bin
else
	POSTGRES_BIN_PATH=/usr/lib/postgresql/9.4/bin
endif
POSTGRES_EXECUTABLE=$(POSTGRES_BIN_PATH)/postgres
# python executable used by node-gyp
GYPPYTHON_EXECUTABLE=$(shell which python2)

ADHOCRACY3_COMMIT="0.4.19"

# support different config files for different environments
ifeq ($(shell hostname),poco-test)
CONFIG_TYPE ?= stage
endif
ifeq ($(shell hostname),poco-live)
CONFIG_TYPE ?= prod
endif
CONFIG_TYPE ?= dev

# those files are rendered from mustache templates
MAKO_TEMPLATES= etc/supervisord.conf etc/fcmmanager_web.xml

all: $(MAKO_TEMPLATES) test_utilities update_repos frontend_install postgres_init services_install services_pre_commit_hook fcmmanager_install select_nginx_config


#
# Install dependencies from ubtunut sources (needs to be run with root)
#

install_deps: install_deps_ubuntu install_elasticsearch_ubuntu /usr/bin/node

# list of packages for ubuntu 14.04 lts
UBUNTU_PACKAGES= maven tomcat7 libxml2 libxml2-dev libxslt1.1 libxslt-dev libzip2 python3 python3-pil python3-pip          \
                 python-virtualenv python3-ipdb python3-pep8 pyflakes sqlite build-essential zlibc \
                 curl file git ruby ruby-dev nodejs npm openjdk-7-jdk phantomjs supervisor nginx   \
                 postgresql ruby-compass

/usr/bin/node:
	ln -sf /usr/bin/nodejs /usr/bin/node

install_deps_ubuntu:
	apt-get -y update
	apt-get -y install $(UBUNTU_PACKAGES)

/etc/apt/sources.list.d/elasticsearch.list:
	curl "https://packages.elasticsearch.org/GPG-KEY-elasticsearch" | apt-key add -
	echo "deb http://packages.elasticsearch.org/elasticsearch/1.4/debian stable main" > /etc/apt/sources.list.d/elasticsearch.list
	apt-get -y update

install_elasticsearch_ubuntu: /etc/apt/sources.list.d/elasticsearch.list
	apt-get -y install elasticsearch

#
# Install policy compass development environment into user account
#

# recursivly checkout all submodules master branches
update_repos:
	git submodule update --init
	git submodule foreach git checkout master
	git submodule foreach git pull
	git submodule foreach 'git config remote.origin.pushurl $$(git config --get remote.origin.url | sed "s#https://github.com/#git@github.com:#")'

bin/python3.4:
	virtualenv --python=$(PYTHON_EXECUTABLE) .

bin/mako-render: bin/python3.4
	./bin/pip3 install -I mako==1.0.4

test_utilities:
	./bin/pip3 install -r requirements.txt

frontend_install:
	cd policycompass-frontend && npm install --python=$(GYPPYTHON_EXECUTABLE)
	cd policycompass-frontend && node_modules/.bin/bower --config.interactive=false prune
	cd policycompass-frontend && node_modules/.bin/bower --config.interactive=false install
	cd policycompass-frontend && compass compile -e production
	ln -sf ../../etc/policycompass/$(CONFIG_TYPE)/frontend-config.js policycompass-frontend/app/config.js
	echo '{"PC_SERVICES_URL": "http://localhost:8000", "FCM_SERVICES_URL": "http://localhost:10080", "ELASTIC_SEARCH_URL": "http://localhost:9200"}' > policycompass-frontend/development.json

etc/secret_key:
	cat /dev/urandom | tr -dc 'a-zA-Z0-9' | fold -w 32 | head -n 1 > $@

policycompass-services/bin/python3.4:
	virtualenv --python=$(PYTHON_EXECUTABLE) policycompass-services

services_install: policycompass-services/bin/python3.4 etc/secret_key
	ln -sf $(ELASTICSEARCH_EXECUTABLE) bin/elasticsearch
	ln -sf $(ELASTICSEARCH_INCLUDES) bin/elasticsearch.in.sh
	policycompass-services/bin/pip3.4 install --upgrade wheel
	policycompass-services/bin/pip3.4 install -r policycompass-services/requirements.txt
	ln -sf ../../etc/policycompass/$(CONFIG_TYPE)/services-settings.py policycompass-services/config/settings.py
	cd policycompass-services && bin/python3.4 manage.py migrate
	cd policycompass-services && bin/python3.4 manage.py loaddata datasets metrics indicators events references visualizations ags feedback-categories
	if [ ! $(CONFIG_TYPE) = dev ]; then cd policycompass-services && bin/python3.4 manage.py collectstatic --noinput; fi

services_pre_commit_hook: etc/hooks/services_pre-commit
	cp etc/hooks/services_pre-commit .git/modules/policycompass-services/hooks/pre-commit

adhocracy3:
	git clone https://github.com/liqd/adhocracy3.git

adhocracy3_git: adhocracy3
	cd adhocracy3 &&\
	git fetch -a &&\
	git checkout $(ADHOCRACY3_COMMIT) &&\
	git submodule update --init

adhocracy3/bin/python3.4: adhocracy3
	virtualenv --python=$(PYTHON_EXECUTABLE) adhocracy3

adhocracy3/bin/buildout: adhocracy3 adhocracy3/bin/python3.4 adhocracy3_git
	mkdir -p adhocracy3/eggs # needed since buildout sometimes fails to create egg
	cd adhocracy3 && ./bin/python3.4 ./bootstrap.py --buildout-version 2.4.4 --setuptools-version=18.3.2

adhocracy3_install: adhocracy3/bin/buildout
	cd adhocracy3 && bin/buildout -c buildout-pcompass.cfg
	ln -sf ../../etc/adhocracy/$(CONFIG_TYPE)/development.ini adhocracy3/etc/development.ini
	ln -sf ../../etc/adhocracy/$(CONFIG_TYPE)/frontend_development.ini adhocracy3/etc/frontend_development.ini

adhocracy3_setup_resources:
	cd adhocracy3 && bin/import_resources etc/development.ini ../etc/adhocracy/resources.json

postgres_init:
	ln -sf $(POSTGRES_EXECUTABLE) bin/postgres
ifeq ($(POSTGRES_DEDICATED), true)
	if [ ! -f var/lib/postgres/PG_VERSION ]; then \
		$(POSTGRES_BIN_PATH)/initdb var/lib/postgres &&\
		$(POSTGRES_BIN_PATH)/pg_ctl start -D var/lib/postgres -o "-c config_file=etc/postgres/postgresql.conf -c unix_socket_directories=''" &&\
		sleep 2 &&\
		createuser -h localhost -p 5433 --no-superuser --no-createrole --no-createdb  pcompass &&\
		createdb -h localhost -p 5433 -e pcompass -E UTF-8 --owner=pcompass &&\
		$(POSTGRES_BIN_PATH)/pg_ctl stop -D var/lib/postgres;\
	fi
else
	if [ $$(psql -U $(POSTGRES_ADMIN) -Atc "SELECT count(*) FROM pg_catalog.pg_user WHERE usename = 'pcompass'") -eq 0 ]; then \
		psql -c "CREATE USER pcompass WITH unencrypted password 'pcompass'"; \
	fi
	if [ $$(psql -U $(POSTGRES_ADMIN) -Atc "SELECT count(*) FROM pg_catalog.pg_database WHERE datname = 'pcompass'") -eq 0 ]; then \
		psql -c "CREATE DATABASE pcompass OWNER pcompass"; \
	fi
endif

export CATALINA_HOME := $(CURDIR)/var/lib/tomcat
ifeq ($(POSTGRES_DEDICATED), true)
export POSTGRES_URI := postgresql://localhost:5433/pcompass
else
export POSTGRES_URI := postgresql://localhost:5432/pcompass
endif

fcmmanager_install: etc/fcmmanager_web.xml
	ln -sf $(CATALINA_EXECUTABLE) ./bin/catalina.sh
	sed 's#postgresql://localhost:5432/pcompass#$(POSTGRES_URI)#' policycompass-fcmmanager/src/main/resources/hibernate.cfg.template.xml > policycompass-fcmmanager/src/main/resources/hibernate.cfg.xml
	cp  etc/fcmmanager_web.xml policycompass-fcmmanager/WebContent/WEB-INF/web.xml
	cd policycompass-fcmmanager && mvn clean install

fcmmanager_loaddata:
	curl http://localhost:10080/api/v1/fcmmanager/loaddata

elasticsearch_rebuildindex:
	curl -XPOST 'http://localhost:8000/api/v1/searchmanager/rebuildindex'

select_nginx_config:
	ln -sf ./nginx/$(CONFIG_TYPE)/nginx.conf etc/nginx.conf

%: %.mako bin/mako-render
	./bin/mako-render $< --var config_type=$(CONFIG_TYPE) > $@

.PHONY: test_utilities update_repos frontend_install adhocracy3_git adhocracy3_install postgres_init fcmmanager_install fcmmanager_loaddata all install_deps install_elasticsearch_ubuntu install_deps_ubuntu elasticsearch_rebuildindex select_nginx_config
