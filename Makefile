# add nix path to download channel data
NIX_PATH=~/.nix-defexpr/channels/nixos
# add all binaries from nix enviroment to path
export PATH := $(PWD)/nix/env/bin:$(PATH)
# setup ssl certificate paths for git in nix env (this is an issue of nix)
export GIT_SSL_CAINFO := $(PWD)/nix/env/etc/ca-bundle.crt

all: update_repros nix_build test_pyvenv test_install frontend_install services_pyvenv postgres_init services_install fcmmanager_install

# recursivly checkout all submodules master branches
update_repros:
	git submodule update --init --recursive
	git submodule foreach --recursive git checkout master
	git submodule foreach --recursive git pull

nix_build:
	. ~/.nix-profile/etc/profile.d/nix.sh ;\
	nix-channel --add http://nixos.org/channels/nixos-14.04 nixos ;\
	nix-channel --update ; \
	nix-build --out-link nix/env -I $(NIX_PATH)

test_pyvenv:
	[ ! -f ./bin/python3.4 ] && ./nix/env/bin/pyvenv-3.4 . ;\
	echo ../../../nix/env/lib/python3.4/site-packages > lib/python3.4/site-packages/result-2.pth ;\

# To create the wheel packages which are cached in ./cache/weels those commands
# need to be run:
#
#       ./bin/pip3.4 install --download-cache ./cache/downloads -r requirements.txt
#       ./bin/pip3.4 wheel --wheel-dir=./cache/wheels -r requirements.txt

test_install:
	./bin/pip3.4 install --upgrade wheel
	./bin/pip3.4 install --no-index --find-links=./cache/wheels -r requirements.txt

frontend_install:
	cd policycompass-frontend/ ;\
	npm install ;\
	yes n | node_modules/.bin/bower install ;\
	echo '{"PC_SERVICES_URL": "http://localhost:8000", "FCM_SERVICES_URL": "http://localhost:10080", "ELASTIC_SEARCH_URL": "http://localhost:9200"}' > development.json ;\
	cd ..

services_pyvenv:
	cd policycompass-services/ ;\
	[ ! -f ./bin/python3.4 ] && pyvenv-3.4 . ;\
	echo ../../../../nix/env/lib/python3.4/site-packages > lib/python3.4/site-packages/env.pth ;\
	cd ..

services_install:
	cd policycompass-services/ ;\
	./bin/pip3.4 install --upgrade wheel ;\
	./bin/pip3.4 install --download-cache ../cache/downloads -r requirements.txt ;\
	cp ../etc/services-settings.py config/settings.py ;\
	bin/python3.4 manage.py migrate ;\
	bin/python3.4 manage.py loaddata metrics events common references visualizations;\

adhocracy3:
	git clone git@github.com:liqd/adhocracy3.git

adhocracy3_pyenv: adhocracy3 nix_build
	[ ! -f ./adhocracy3/bin/python3.4 ] && ./nix/env/bin/pyvenv-3.4 adhocracy3 || true

adhocracy_install: adhocracy3 nix_build adhocracy3_pyenv
	cd adhocracy3 &&\
	git pull &&\
	git submodule init &&\
	git submodule update
	cd adhocracy3 && ./bin/python ./bootstrap.py
	cd adhocracy3 && ./bin/buildout

carneades_install: nix_build
	export PATH=$(PATH):`(gem env gempath | cut -d ':' -f 2 )`/bin ;\
	mkdir -p var/lib/tomcat/webapps ;\
	nix-shell -I ~/.nix-defexpr/channels/nixos --pure --command "gem install --user-install compass" ;\
	./carneades/src/CarneadesWeb/scripts/build_war.sh --deploy $(CURDIR)/var/lib/tomcat/webapps/carneades.war

carneades_config:
	@echo "{:projects-directory \""$(CURDIR)"/carneades/projects\"}" > .carneades.clj

postgres_init:
	if [ ! -f var/lib/postgres/PG_VERSION ]; then \
		initdb var/lib/postgres &&\
		pg_ctl start -D var/lib/postgres -o "-c config_file=etc/postgres/postgresql.conf" &&\
		sleep 2 &&\
		createuser --no-superuser --no-createrole --no-createdb  pcompass &&\
		createdb -e pcompass -E UTF-8 --owner=pcompass &&\
		pg_ctl stop -D var/lib/postgres;\
	fi

export CATALINA_HOME := $(CURDIR)/var/lib/tomcat
fcmmanager_install:
	[ -f  policycompass-fcmmanager/src/main/resources/hibernate.cfg.xml ] || cp policycompass-fcmmanager/src/main/resources/hibernate.cfg.template.xml policycompass-fcmmanager/src/main/resources/hibernate.cfg.xml
	cd policycompass-fcmmanager && mvn clean install

print-python-syspath:
	./bin/python -c 'import sys,pprint;pprint.pprint(sys.path)'

.PHONY: print-python-syspath test_install test_pyvenv frontend_install nix_build adhocracy_install adhocracy3_pyenv postgres_init fcmmanager_install all
