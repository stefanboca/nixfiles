{
  config,
  lib,
  ...
}:

let
  cfg = config.desktop.gaming;
in
{
  options.desktop.gaming = {
    enable = lib.mkEnableOption "Enable gaming.";
  };

  config = lib.mkIf cfg.enable {
    programs = {
      mangohud.enable = true;
    };
  };
}
