{ }:

let
   pkgs = import <nixpkgs> { };
   devtools = [
        pkgs.cacert
        pkgs.git
        pkgs.gitAndTools.tig
    ];
in

with pkgs;

rec {

  policycompass-env = stdenv.mkDerivation {
    name = "policycompass";
    buildInputs = [ policycompass ];
  };

  # install dependencies
  policycompass = buildEnv {
    name = "policycompass";
    paths = [
        python34env
        supervisordev34
        nginx
        devtools
        policycompass_service
        policycompass_adhocracy
        policycompass_frontend
        tests
        ];
  };

  policycompass_service = buildEnv {
    name = "policycompass_service";
    paths = [
        postgresql93
        ];
  };

  policycompass_adhocracy = buildEnv {
    name = "policycompass_adhocracy";
    paths = [
        ruby
        graphviz
        ];
  };

  policycompass_frontend = buildEnv {
    name = "policycompass_frontend";
    paths = [
        nodePackages.npm
        ];
  };

  tests = buildEnv {
    name = "tests";
    paths = [
        phantomjs
        ];
  };

  nodejs-env = buildEnv {
    name = "nodejs-env";
    paths = [
        nodejs
        ];
  };

  python34env = buildEnv {
    name = "Python34Env";
    paths = [
        libxml2
        libxslt
        libzip
        python34
        python34Packages.recursivePthLoader
        python34Packages.virtualenv
        python34Packages.pillow
        python34Packages.ipdb
        python34Packages.pep8
        pyflakes
        sqlite
        stdenv
        zlib
        ];
  };

  meld334 = python34Packages.buildPythonPackage {
     name = "meld3-1.0.0";
     buildInputs = [ python34 ];
     src = pkgs.fetchurl {
        url = https://pypi.python.org/packages/source/m/meld3/meld3-1.0.0.tar.gz;
        sha256 = "57b41eebbb5a82d4a928608962616442e239ec6d611fe6f46343e765e36f0b2b";
     };
  };

  supervisordev34 = python34Packages.buildPythonPackage {
     name = "supervisordev34";
     buildInputs = [ python34 python34Packages.mock ];
     src = pkgs.fetchgit {
        url = https://github.com/Supervisor/supervisor.git;
        rev = "7e4e41b1f7e955de6d0963972695d6704ebeaf6a";
        sha256 = "1jp52d2n16912kh3gig1ms5qc90zamn6p8axmyn9y5v23h61iw1n";
     };
     propagatedBuildInputs = [ meld334 ];
  };

  pyflakes = stdenv.lib.overrideDerivation python34Packages.pyflakes (oldAttrs: {
     name = "pyflakes-0.8.1";
     src = fetchurl {
       url = "http://pypi.python.org/packages/source/p/pyflakes/pyflakes-0.8.1.tar.gz";
       md5 = "905fe91ad14b912807e8fdc2ac2e2c23";
     };
   });
}
