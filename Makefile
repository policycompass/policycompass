# add nix path to download channel data
NIX_PATH=~/.nix-defexpr/channels/nixos
# add npm and node to PATH
export PATH := ../nix/env-3/bin:$(PATH)


all: update_repros nix_build test_pyvenv test_install frontend_install services_pyvenv services_install 

update_repros:
	git pull
	git submodule foreach --recursive git submodule init ;\
	git submodule foreach --recursive git submodule update ;\
	git submodule foreach --recursive git checkout master ;\
    git submodule foreach --recursive git pull

nix_build:
	source ~/.nix-profile/etc/profile.d/nix.sh ;\
	nix-channel --add http://nixos.org/channels/nixos-14.04 nixos ;\
	nix-channel --update ; \
	NIX_PATH=${NIX_PATH} nix-build -A policycompass-env -A policycompass -A nodejs-env --out-link nix/env dev.nix;\

test_pyvenv:
	[ ! -f ./bin/python3.4 ] && ./nix/env-2/bin/pyvenv-3.4 . ;\
	echo ../../../nix/env-2/lib/python3.4/site-packages > lib/python3.4/site-packages/result-2.pth ;\

test_install:
	./bin/pip3.4 install --upgrade wheel ;\
	#./bin/pip3.4 install --download-cache ./cache/downloads -r requirements.txt ;\
	#./bin/pip3.4 wheel --wheel-dir=./cache/wheels -r requirements.txt ;\
	bin/pip3.4 install --no-index --find-links=./cache/wheels -r requirements.txt

frontend_install:
	cd policycompass-frontend/ ;\
	npm install ;\
	node_modules/.bin/bower install ;\
	echo '{"PC_SERVICES_URL": "http://localhost:9000"}' > development.json ;\
	cd .. 

services_pyvenv:
	cd policycompass-services/ ;\
	[ ! -f ./bin/python3.4 ] && ../nix/env-2/bin/pyvenv-3.4 . ;\
	echo ../../../../nix/env-2/lib/python3.4/site-packages > lib/python3.4/site-packages/env-2.pth ;\
	cd ..

services_install:
	cd policycompass-services/ ;\
	./bin/pip3.4 install --upgrade wheel ;\
	./bin/pip3.4 install --download-cache ../cache/downloads -r requirements.txt ;\
    cp config/settings.sample.py config/settings.py ;\
    bin/python3.4 manage.py migrate ;\
    bin/python3.4 manage.py loaddata metrics events users references visualizations;\

print-python-syspath:
	./bin/python -c 'import sys,pprint;pprint.pprint(sys.path)'

.PHONY: print-python-syspath test_install test_pyvenv frontend_install nix-build all
