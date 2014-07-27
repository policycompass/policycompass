NIX_PATH=~/.nix-defexpr/channels/

all: dev.nix
	nix-channel --update
	NIX_PATH=${NIX_PATH} nix-build -A policycompass-env -A policycompass dev.nix
	./result-2/bin/pyvenv-3.4 .
#    echo ../../../result-2/lib/python3.4/site-packages > lib/python3.4/site-packages/nixenv.pth

print-python-syspath:
	./bin/python -c 'import sys,pprint;pprint.pprint(sys.path)'

.PHONY: print-syspath
