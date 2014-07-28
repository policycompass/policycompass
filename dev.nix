{ }:

let
  pkgs = import <nixpkgs> { };
in

with pkgs;

rec {

  # source file so load bash environment with dependencies 
  policycompass-env = myEnvFun {
    name = "policycompass";
    buildInputs = with pkgs; [ policycompass ];
    extraCmds = 
        "export PYTHONHOME=${python34env}; export PATH=$PATH:${nodejs-env}/bin;"
    ;
  };

  # install dependencies 
  policycompass = buildEnv {
    name = "policycompass";
    paths = [
        python34env
        supervisordev34
        devtools
        policycompass_service
        policycompass_adhocracy
        policycompass_frontend
        tests
        ];
  };

  devtools = buildEnv {
    name = "devtools";
    paths = [
        git 
        gitAndTools.tig
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
        python34Packages.flake8
        python34Packages.ipdb
        sqlite
        stdenv
        zlib
        ];
  };

  meld334 = buildPythonPackage {
     name = "meld3-1.0.0";
     buildInputs = [ python34 ];
     src = pkgs.fetchurl {
        url = https://pypi.python.org/packages/source/m/meld3/meld3-1.0.0.tar.gz;
        sha256 = "57b41eebbb5a82d4a928608962616442e239ec6d611fe6f46343e765e36f0b2b";
     };
  };
  supervisordev34 = buildPythonPackage {
     name = "supervisordev34";
     buildInputs = [ python34 meld334 ];
     src = pkgs.fetchurl {
        url = https://github.com/Supervisor/supervisor/archive/master.zip;
        sha256 = "f292f520aeea8159ba281eef52a4c94c53cf4b2b8e090ecb9fa884f2205f26e2";
     };
     propagatedBuildInputs = [ meld334 ];
  };
}
