{
  inputs.nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
  inputs.flake-utils.url = "github:numtide/flake-utils";
  inputs.flake-compat = {
    url = "github:NixOS/flake-compat";
    flake = false;
  };
  outputs =
    {
      self,
      nixpkgs,
      flake-utils,
      ...
    }:
    with flake-utils.lib;
    eachDefaultSystem (
      system:
      let
        pkgs = import nixpkgs {
          inherit system;
          overlays = [ self.overlays.default ];
        };
      in
      with pkgs;
      {
        devShells.default =
          with haskell.lib;
          (addBuildTools (haskellPackages.mlkih) [
            haskell-language-server
            cabal-install
          ]).envFunc
            { };
      }
    )
    // {
      overlays.default = final: prev: {
        haskellPackages = prev.haskellPackages.override (old: {
          overrides = final.lib.composeExtensions (old.overrides or (_: _: { })) (
            hself: hsuper: {
              mlkih = prev.haskellPackages.callCabal2nix "mlkih" ./. { };
            }
          );
        });
      };
    };
}
