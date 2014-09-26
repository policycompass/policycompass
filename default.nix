{ }:

let
   pkgs = import <nixpkgs> { };
in
with pkgs;
let
   python34env = [
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

   devtools = [
        cacert
        git
        gitAndTools.tig
    ];

    # install dependencies
    adhocracy_dependencies = [
        ruby
        graphviz
    ];

    services_dependencies = [
        postgresql93
   ];

   frontend_dependencies = [
        nodejs
   ];

   test_dependencies = [
        phantomjs
   ];

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
        rev = "5cccaf73d0aa4e46a4dbc71db7e6b55403d58097";
        sha256 = "08cfdea9c6b0c7c2243d64a83809841ac0a78e5e6b131adb2e859a4f1306630d";
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

  policycompass = buildEnv {
    name = "policycompass";
    paths = [
        python34env
        supervisordev34
        nginx
        devtools
        services_dependencies
        adhocracy_dependencies
        frontend_dependencies
        test_dependencies
        ];
  };
  in
rec {
  policycompass-env = stdenv.mkDerivation {
    name = "policycompass";
    buildInputs = [ policycompass ];
  };
}
