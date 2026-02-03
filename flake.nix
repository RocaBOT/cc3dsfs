{
  description = "nix flake for the cc3dsfs 3ds video capture software";
  inputs.nixpkgs.url = "github:nixos/nixpkgs?ref=nixos-25.11";

  outputs = {
    self,
    nixpkgs,
    ...
  }: let
    supportedSystems = [
      "x86_64-linux"
      "aarch64-linux"
      "x86_64-darwin"
      "aarch64-darwin"
    ];
    forAllSystems = nixpkgs.lib.genAttrs supportedSystems;
  in {
    packages = forAllSystems (
      system: let
        pkgs = import nixpkgs {
          inherit system;
        };
        sfml_src = pkgs.fetchFromGitHub {
          owner = "SFML";
          repo = "SFML";
          rev = "e533db99c8a83a6b81c47105964e10cbab421a0d";
          sha256 = "sha256:Jq5t0R5Ko3n85euEWcYN4OM+M6apumDs2cniOGP5aRo=";
        };
        libusb_src = pkgs.fetchFromGitHub {
          owner = "libusb";
          repo = "libusb-cmake";
          rev = "454554e1594ba966a259280e927e1a83052cfa4f";
          sha256 = "sha256:Mo4e3Iac8OXKVdgNeIToVyUAEAeeqYg/AJeDv0gC/4A=";
        };
        sheenbidi_src = pkgs.fetchFromGitHub {
          owner = "Tehreer";
          repo = "SheenBidi";
          rev = "v2.9.0";
          sha256 = "sha256:d4JttBe0aPZdihnMpmLUo9NuF7LUeZoeWZ3ItjMNwx8=";
        };
      in {
        default = pkgs.stdenv.mkDerivation {
          pname = "cc3dsfs";
          version = "2026.01.24";
          src = self;

          nativeBuildInputs = with pkgs; [
            cmake
          ];
          buildInputs = with pkgs; [
            libgcc
            git
            libxrandr.dev
            libxcursor.dev
            libgudev.dev
            flac.dev
            libvorbis.dev
            mesa-gl-headers
            libdrm.dev
            libgbm
            libxft.dev
            harfbuzz.dev
            xorg.xorgserver.dev
            libxi
          ];

          cmakeFlags = [
            "-DCMAKE_BUILD_TYPE=Release"
            "-DFETCHCONTENT_SOURCE_DIR_SFML=${sfml_src}"
            "-DFETCHCONTENT_SOURCE_DIR_LIBUSB=${libusb_src}"
            "-DFETCHCONTENT_SOURCE_DIR_SHEENBIDI=${sheenbidi_src}"
          ];

          configPhase = ''
            cmake -B build
          '';

          buildPhase = ''
            cmake --build . --config Release
          '';

          # cc3dsfs is in bin subdirectory
          installPhase = ''
            mkdir -p $out/bin
            install -Dm755 bin/cc3dsfs $out/bin/
            mkdir -p $out/etc/udev/rules.d
            cp ../usb_rules/*.rules $out/etc/udev/rules.d/
          '';
        };
      }
    );
  };
}
