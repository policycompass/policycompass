# Policy Compass

Install the policy compass web application and all dependent services for development.


## Installation

Requirements:

* Ubuntu linux 64bit (tested with 14.04 LTS)
* git
* make
* bash
* python3.4 (optional for automatic installation)
* postgres, elasticsearch, and tons of other dependencies (see Makefile for reference)

### Checkout main repository

This requires an github.com account with [ssh keys](https://help.github.com/articles/generating-ssh-keys).

    git clone git@github.com:policycompass/policycompass.git
    cd policycompass

### Automatic installation on ubuntu systems

Install dependencies:

    sudo make install_deps

Install dependency services and build shell environment with all development tools:

    make

Start all installed services and the frontend using supervisord:

    supervisord -c etc/supervisord.conf

Install Adhocracy:

    make adhocracy3_install

Run Adhocracy:

    supervisorctl start adhocracy:

### Manual installation

Install basic requirements:

* [python3.4](https://python.org)
* firefox (default setting for browser acceptance tests)

Checkout sub repositories:

    git submodule foreach --recursive "(git checkout master; git submodule init; git submodule update; git pull)"

To update all repositories run:

    git pull
    git submodule foreach --recursive "(git submodule init; git submodule update; git-pull)"

Create Python virtualenv:

    pyvenv-3.4 .

Install test runner:

    bin/pip3.4 install -r requirements.txt

Install dependency services:

    Read the README files in the subproject directories (./policycompass-*).


## API Documentation

The API documentation for all the Policy Compass services can be found [here](https://github.com/policycompass/policycompass/wiki/Policy-Compass-REST-API-Documentation).


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


### API mock servers

You can start the example mock server with:

    bin/python tests-mock-services/example-service.py

Test that it is working correctly:

    wget http://localhost:9900/test/value


### Run frontend acceptance tests

    bin/py.test tests-acceptance-frontend


### Run API tests

    bin/py.test tests-api-services


## Policy Compass is Free Software

This project (i.e. all files in this repository if not declared otherwise) is
licensed under the GNU Affero General Public License (AGPLv3), see
LICENSE.txt.
