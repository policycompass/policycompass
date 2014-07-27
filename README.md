# Policy Compass

Install the policy compass web application and all dependency services for development.

## Installation

requires:

  * Linux/Mac 64bit system (the policycompass_adhocracy service needs 64bit)
  * build-essential tools 
  * git
  * python3.4 (optional for automatic installation)

### Checkout repositories:

This requires an github.com account with [ssh keys](https://help.github.com/articles/generating-ssh-keys).

```shell
    git clone git@github.com:policycompass/policycompass.git
    cd policycompass
    git submodule init
    git submodule update --recursive
    git submodule foreach --recursive git checkout master
```shell

### Automatic installation with the [nix](http://nixos.org/nix/) package manager:

Install nix:

    bash <(curl https://nixos.org/nix/install)
    make

Start shell environment with all development tools:

    nix/env/bin/load-env-policycompass

All dependency services are now ready to work with (WORK IN PROGRESS).

Optional: lock this nix environment and make a covenience link:

  nix-env -iA policycompass-env -f dev.nix -p /nix/var/nix/gcroots/profiles/per-user/policycompass
  ln -sf /nix/var/nix/gcroots/profiles/per-user/policycompass/bin/load-env-policycompass ~/.

Optional: Start all services an mock services with [supervisor](http://supervisord.org/):

   (WORK IN PROGRESS)
   

### Manual installation:

install basic requirements:

    * [python3.4](python.org)
    * firefox (default setting for browser acceptance tests)

create Python virtualenv:

```shell
   pyvenv-3.4 .
```

install test runner:

```shell
	bin/pip3.4 install -r requirements.txt
```

Read the README files in the subproject directories (./policycompass-*).


## Testing

Acceptance tests for the frontend webapplication and
functional tests/specification that show how to use a service.

To ease distributed development every service API has a mock HTTP
server which specifies HTTP responses for given HTTP requests.

### Software Stack

* [pytest](http://pytest.org) (test runner)
* [pytest_splinter](https://pypi.python.org/pypi/pytest-splinter) (test fixtures/configuration for the splinter browser)
* [splinter](http://splinter.cobrateam.info/docs) (test browser based on webdriver)
* [webdriver](http://docs.seleniumhq.org) (browser automation)
* [requests](http://docs.python-requests.org) (library for http requests)

### api mock servers

You can start the example mock server with:

```shell
    bin/python tests-mock-services/example-service.py
    wget localhost:9900/test/value
```

### Run frontend acceptance tests

```shell
   bin/py.test tests-acceptance-frontend
```

### Run api tests

```shell
   bin/py.test tests-api-services
`
