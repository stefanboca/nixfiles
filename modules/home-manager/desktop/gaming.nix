{
  config,
  lib,
  modulesPath,
  ...
}: let
  cfg = config.desktop.gaming;
in {
  imports = [
    "${modulesPath}/programs/mangohud.nix"
  ];

  options.desktop.gaming = {
    enable = lib.mkEnableOption "Enable gaming.";
  };

  config = lib.mkIf cfg.enable {
    programs = {
      mangohud.enable = true;
    };
  };
}
