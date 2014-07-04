# Policy Compass Acceptance tests

Acceptance tests for the frontend webapplication and
functional tests/specification that show how to use a service.

To ease distributed development every service API has a mock HTTP
server which specifies HTTP responses for given HTTP requests.

## Software Stack

* [pytest](http://pytest.org) (test runner)
* [pytest_splinter](https://pypi.python.org/pypi/pytest-splinter) (test fixtures/configuration for the splinter browser)
* [splinter](http://phantomjs.org/build.html) (test browser based on webdriver)
* [webdriver](http://docs.seleniumhq.org) (browser automation)
* [requests](http://docs.python-requests.org) (library for http requests)

## Installation

### Requires

* python2.7
* virtualenv > 1.11 https://virtualenv.pypa.io/en/latest/virtualenv.html#installation
* firefox (default setting for browser tests)

### Install

Create Python Virtualenv and update pip:

```shell
    virtualenv .
    bin/pip install --upgrade pip
```

Install test runner and mock servers:

```shell
	bin/pip install -r requirements.txt
```

## api mock servers

You can start the example mock server with:

```shell
    bin/python tests-mock-services/example-service.py
    wget localhost:9900/test/value
```

## Tests

### Run frontend acceptance tests

```shell
   bin/py.test tests-api-services
```

### Run api tests

```shell
   bin/py.test tests-acceptance-frontend
```
