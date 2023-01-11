{

  inputs = {
    flake-utils.url = "github:numtide/flake-utils";
    idris2-lsp = {
      url = "github:idris-community/idris2-lsp";
      flake = false;
    };
    idris2 = {
      url = "github:idris-lang/Idris2";
      flake = false;
    };
    idris2-pkgs = {
      url = "github:jeroendehaas/idris2-pkgs";
      inputs.idris2.follows = "idris2";
      inputs.lsp.follows = "idris2-lsp";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = { self, flake-utils, nixpkgs, idris2-pkgs, ... }:
    flake-utils.lib.eachDefaultSystem (system:
      let
        pkgs = import nixpkgs {
          inherit system;
          overlays = [ idris2-pkgs.overlay ];
        };
      in {
        defaultPackage = pkgs.stdenvNoCC.mkDerivation rec {
          name = "docs";
          version = "0.6.0";
          src = ./src;
          nativeBuildInputs = [
            pkgs.dashing
            pkgs.idris2-pkgs.prelude.docs
            pkgs.idris2-pkgs.base.docs
            pkgs.idris2-pkgs.contrib.docs
          ];
          unpackPhase = "true";
          buildPhase = ''
            cp -r ${src}/* .
            cp -r ${pkgs.idris2-pkgs.prelude.docs}/share/doc/ prelude
            cp -r ${pkgs.idris2-pkgs.base.docs}/share/doc/ base
            cp -r ${pkgs.idris2-pkgs.contrib.docs}/share/doc/ contrib
            dashing build
          '';
          installPhase = ''
            mkdir -p $out
            cp -r idris2.docset $out/
          '';
        };
      });

}
