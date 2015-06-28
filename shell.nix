{ nixpkgs ? import <nixpkgs> {}
, hscompiler ? "ghc7101"
, ... }:
let

  hsenv   = nixpkgs.pkgs.haskell;
  stdenv  = nixpkgs.pkgs.stdenv;
  hspkgsF = p: with p; [
    aeson
    wreq
    path
    doctest
    optparse-applicative
    transformers
  ];
  ghc = hsenv.packages.${hscompiler}.ghcWithPackages hspkgsF;

in
stdenv.mkDerivation {
  name = "funops-cli";
  buildInputs = [ ghc ];
  shellHook = ''
    eval $(grep export ${ghc}/bin/ghc)
  '';
}
