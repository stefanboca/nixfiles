{
  config,
  lib,
  modulesPath,
  osConfig,
  ...
}: let
  cfg = config.desktop.gaming;
in {
  imports = [
    "${modulesPath}/programs/mangohud.nix"
  ];

  options.desktop.gaming.enable = lib.mkEnableOption "Enable gaming." // {default = osConfig.desktop.gaming.enable or false;};

  config = lib.mkIf cfg.enable {
    programs = {
      mangohud.enable = true;
    };
  };
}
