{
  description = "actus-core flake";

  inputs = {
    flake-utils.url = "github:numtide/flake-utils";
    nixpkgs.follows = "haskell-nix/nixpkgs-unstable";

    haskell-nix = {
      url = "github:input-output-hk/haskell.nix";
    };

    actus-tests = {
      url = "github:actusfrf/actus-tests";
      flake = false;
    };
  };

  outputs = { self, nixpkgs, flake-utils, haskell-nix, actus-tests }:
    flake-utils.lib.eachSystem [ "x86_64-linux" "x86_64-darwin" ] (system:
    let
      overlays = [ haskell-nix.overlay
        (final: prev: {
          actusCore =
            final.haskell-nix.project' {
              src = ./.;
              compiler-nix-name = "ghc8107";
              shell.tools = {
                cabal = {};
              };
              shell.buildInputs = with pkgs; [
                nixpkgs-fmt
              ];
              shell.shellHook = ''
                export ACTUS_TEST_DATA_DIR=${actus-tests}/tests/
                '';
            };
        })
      ];
      pkgs = import nixpkgs { inherit system overlays; inherit (haskell-nix) config; };
      flake = pkgs.actusCore.flake {
      };
    in flake // {
      packages.default = flake.packages."actus-core:lib:actus-core";
    });
}
