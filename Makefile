NIX_PATH=~/.nix-defexpr/channels/


all: nix-build test_pyvenv test_install frontend_install

nix-build:
	nix-channel --update; \
	NIX_PATH=${NIX_PATH} nix-build -A policycompass-env -A policycompass --out-link nix/env dev.nix;\

test_pyvenv:
	[ ! -f ./bin/python3.4 ] && ./result-2/bin/pyvenv-3.4 --system-site-packages . ;\
	echo ../../../nix/env-2/lib/python3.4/site-packages > lib/python3.4/site-packages/result-2.pth ;\

test_install:
	./bin/pip3.4 install --upgrade wheel ;\
	#./bin/pip3.4 install --download-cache ./cache/downloads -r requirements.txt ;\
	#./bin/pip3.4 wheel --wheel-dir=./cache/wheels -r requirements.txt ;\
	bin/pip3.4 install --no-index --find-links=./cache/wheels -r requirements.txt

frontend_install:
	cd policycompass-frontend/ && ../nix/env-2/bin/npm install ;\
	../nix/env-2/bin/npm install bower ;\

print-python-syspath:
	./bin/python -c 'import sys,pprint;pprint.pprint(sys.path)'

.PHONY: print-python-syspath acceptancetests pyvenv nix-build
