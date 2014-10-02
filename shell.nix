{ }:
let
   pkgs = import <nixpkgs> { };
   default = import ./default.nix { };
in
with pkgs;
rec {
  policycompass-env = stdenv.mkDerivation {
    name = "policycompass-env";
    buildInputs = [ default.policycompass ];
  };
}
