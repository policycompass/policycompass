all: update_repros test_install frontend_install postgres_init services_install fcmmanager_install

PYTHON_EXECUTABLE=$(shell which python3.4)
CATALINA_EXECUTABLE=/usr/share/tomcat7/bin/catalina.sh
ELASTICSEARCH_EXECUTABLE=/usr/share/elasticsearch/bin/elasticsearch
ELASTICSEARCH_INCLUDES=/usr/share/elasticsearch/bin/elasticsearch.in.sh
POSTGRES_DEDICATED=true

#
# Install dependencies from ubtunut sources (needs to be run with root)
#

install_deps: install_deps_ubuntu install_elasticsearch_ubuntu /usr/bin/node

# list of packages for ubuntu 14.04 lts
UBUNTU_PACKAGES= maven tomcat7 libxml2 libxslt1.1 libzip2 python3 python3-pil python3-pip		\
	         python-virtualenv python3-ipdb python3-pep8 pyflakes sqlite build-essential zlibc	\
	         curl file git ruby ruby-dev nodejs npm leiningen openjdk-7-jdk phantomjs		\
	         supervisor nginx postgresql

/usr/bin/node:
	ln -srf /usr/bin/nodejs /usr/bin/node

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
update_repros:
	git submodule update --init
	git submodule foreach git checkout master
	git submodule foreach git pull

bin/python3.4:
	virtualenv --python=$(PYTHON_EXECUTABLE) .

bin/wheel: bin/python3.4
	./bin/pip3.4 install -I wheel

cache/wheels: bin/wheel
	./bin/pip3.4 wheel --wheel-dir=./cache/wheels -r requirements.txt

test_install: cache/wheels bin/wheel bin/python3.4
	./bin/pip3.4 install --upgrade wheel
	./bin/pip3.4 install --no-index --find-links=./cache/wheels -r requirements.txt

frontend_install:
	cd policycompass-frontend && npm install
	cd policycompass-frontend && yes n | node_modules/.bin/bower install
	echo '{"PC_SERVICES_URL": "http://localhost:8000", "FCM_SERVICES_URL": "http://localhost:10080", "ELASTIC_SEARCH_URL": "http://localhost:9200"}' > policycompass-frontend/development.json

policycompass-services/bin/python3.4:
	virtualenv --python=$(PYTHON_EXECUTABLE) policycompass-services

services_install: policycompass-services/bin/python3.4
	ln -sf $(ELASTICSEARCH_EXECUTABLE) bin/elasticsearch
	ln -sf $(ELASTICSEARCH_INCLUDES) bin/elasticsearch.in.sh
	policycompass-services/bin/pip3.4 install --upgrade wheel
	policycompass-services/bin/pip3.4 install --download-cache cache/downloads -r policycompass-services/requirements.txt
	cp etc/services-settings.py policycompass-services/config/settings.py
	cd policycompass-services && bin/python3.4 manage.py migrate
	cd policycompass-services && bin/python3.4 manage.py loaddata metrics events common references visualizations

adhocracy3:
	git clone git@github.com:liqd/adhocracy3.git

adhocracy3_git: adhocracy3
	cd adhocracy3 &&\
	git pull &&\
	git submodule init &&\
	git submodule update

adhocracy3/bin/python3.4: adhocracy3
	virtualenv --python=$(PYTHON_EXECUTABLE) adhocracy3

adhocracy3/bin/buildout: adhocracy3 adhocracy3/bin/python3.4
	cd adhocracy3 && bin/python3.4 ./bootstrap.py -v 2.3.1 --setuptools-version=12.1

adhocracy3_install: adhocracy3/bin/buildout
	cd adhocracy3 && bin/buildout

carneades_install:
	ln -sf $(CATALINA_EXECUTABLE) ./bin/catalina.sh
	export PATH=$(PATH):`(gem env gempath | cut -d ':' -f 2 )`/bin &&\
	mkdir -p var/lib/tomcat/webapps &&\
	gem install --user-install compass &&\
	./carneades/src/CarneadesWeb/scripts/build_war.sh --deploy $(CURDIR)/var/lib/tomcat/webapps/carneades.war

carneades_config:
	@echo "{:projects-directory \""$(CURDIR)"/carneades/projects\"}" > .carneades.clj

postgres_init:
ifeq ($(POSTGRES_DEDICATED), true)
	if [ ! -f var/lib/postgres/PG_VERSION ]; then \
		initdb var/lib/postgres &&\
		pg_ctl start -D var/lib/postgres -o "-c config_file=etc/postgres/postgresql.conf" &&\
		sleep 2 &&\
		createuser --no-superuser --no-createrole --no-createdb  pcompass &&\
		createdb -e pcompass -E UTF-8 --owner=pcompass &&\
		pg_ctl stop -D var/lib/postgres;\
	fi
else
	psql -c "create user pcompass with unencrypted password 'pcompass';" -U postgres
	psql -c "create database pcompass owner pcompass;" -U postgres
endif

export CATALINA_HOME := $(CURDIR)/var/lib/tomcat
fcmmanager_install:
	ln -sf $(CATALINA_EXECUTABLE) ./bin/catalina.sh
	[ -f  policycompass-fcmmanager/src/main/resources/hibernate.cfg.xml ] || cp policycompass-fcmmanager/src/main/resources/hibernate.cfg.template.xml policycompass-fcmmanager/src/main/resources/hibernate.cfg.xml
	cd policycompass-fcmmanager && mvn clean install

.PHONY: test_install frontend_install adhocracy3_git adhocracy3_install postgres_init fcmmanager_install all install_deps install_elasticsearch_ubuntu install_deps_ubuntu
