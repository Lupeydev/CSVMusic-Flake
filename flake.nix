{
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    system.url = "github:nix-systems/default-linux";
  };

  outputs = { self, nixpkgs, systems, ... }:
  let
    eachSystem = nixpkgs.lib.genAttrs (import systems);
  in {
    packages = eachSystem (system:
    let
      pkgs = import nixpkgs {
        system = "${system}";
      };
      in {
        default = self.packages.${system}.csvmusic.stable;
        csvmusic = {
          stable = pkgs.callPackage ./default.nix {};
        };
      });
  };
}