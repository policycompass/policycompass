# add nix path to download channel data
NIX_PATH=~/.nix-defexpr/channels/nixos
# add all binaries from nix enviroment to path
export PATH := $(PWD)/nix/env/bin:$(PATH)
# setup ssl certificate paths for git in nix env (this is an issue of nix)
export GIT_SSL_CAINFO := $(PWD)/nix/env/etc/ca-bundle.crt

all: update_repros nix_build test_pyvenv test_install frontend_install services_pyvenv services_install

# recursivly checkout all submodules master branches
update_repros:
	git submodule init
	git submodule update --recursive
	git submodule foreach --recursive git submodule init
	git submodule foreach --recursive git submodule update
	git submodule foreach --recursive git checkout master
	git pull --recurse-submodules

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
	echo '{"PC_SERVICES_URL": "http://localhost:9000"}' > development.json ;\
	cd ..

services_pyvenv:
	cd policycompass-services/ ;\
	[ ! -f ./bin/python3.4 ] && ../nix/env/bin/pyvenv-3.4 . ;\
	echo ../../../../nix/env/lib/python3.4/site-packages > lib/python3.4/site-packages/env.pth ;\
	cd ..

services_install:
	cd policycompass-services/ ;\
	./bin/pip3.4 install --upgrade wheel ;\
	./bin/pip3.4 install --download-cache ../cache/downloads -r requirements.txt ;\
	cp config/settings.sample.py config/settings.py ;\
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

print-python-syspath:
	./bin/python -c 'import sys,pprint;pprint.pprint(sys.path)'


.PHONY: print-python-syspath test_install test_pyvenv frontend_install nix_build adhocracy_install adhocracy3_pyenv all
