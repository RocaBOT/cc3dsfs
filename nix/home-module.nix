{lib, ...}: {
  options.programs.cc3dsfs = {
    enable = lib.mkEnableOption "c3dsfs configuration";
  };
}
