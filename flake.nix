{
  description = "cc3dsfs - 3ds video capture software";
  inputs.nixpkgs.url = "github:nixos/nixpkgs?ref=nixos-25.11";

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

    homeModules.default = {
      pkgs,
      lib,
      ...
    }: {
      imports = [./nix/home-module.nix];
      programs.cc3dsfs.package =
        lib.mkDefault
        self.packages.${pkgs.stdenv.hostPlatform.system}.default;
      services.udev.packages = self.packages.${pkgs.stdenv.hostPlatform.system}.default;
    };
  };
}
