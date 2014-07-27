# Policy Compass

Install the policy compass web application and all dependency services.

## Requires

* [python3.4](python.org)
* [virtualenv >= 1.11](https://virtualenv.pypa.io/en/latest/virtualenv.html#installation)
* firefox (default setting for browser tests)

## Installation

### checkout the project/sub projects repositories:

This requires an github.com account with [ssh keys](https://help.github.com/articles/generating-ssh-keys).

```shell
    git clone git@github.com:policycompass/policycompass.git
    cd policycompass
    git submodule init
    git submodule foreach --recursive git checkout master
```shell

### manual installation:

Create Python Virtualenv and update pip:

```shell
)   virtualenv .
    bin/pip install --upgrade pip
```

Read the README files in the project directories (./policycompass-*).

### automatic install with nix package manager:

Install nix:

    bash <(curl https://nixos.org/nix/install)
    make

Source environment file:

    source result/bin/load-env-policycompass


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

### Installation

Install test runner:

```shell
	bin/pip install -r requirements.txt
```

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
