{
  description = "cc3dsfs - 3ds video capture software";
  inputs.nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";

  outputs = {
    self,
    nixpkgs,
    ...
  }: let
    eachSystem = nixpkgs.lib.genAttrs nixpkgs.lib.platforms.linux;
    pkgsFor = eachSystem (
      system: nixpkgs.legacyPackages.${system}.appendOverlays [self.overlays.default]
    );
  in {
    packages = eachSystem (system: {
      default = pkgsFor.${system}.cc3dsfs;
    });

    overlays = {
      default = final: prev: {
        cc3dsfs = final.callPackage ./nix/package.nix {
          version = "20260124";
        };
      };
    };
  };
}
