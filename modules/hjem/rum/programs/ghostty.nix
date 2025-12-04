{
  config,
  lib,
  ...
}: let
  inherit (lib.modules) mkIf;
  inherit (lib.options) mkEnableOption;

  cfg = config.rum.programs.ghostty;
in {
  options.rum.programs.ghostty = {
    integrations = {
      bat.enable = mkEnableOption "ghostty integration with bat";
    };
  };

  config = mkIf cfg.enable {
    rum.programs.bat = mkIf cfg.integrations.bat.enable {
      flags = [''--map-syntax="${config.xdg.config.directory}/ghostty/config:Ghostty Config"''];
      syntaxes."ghostty.sublime-syntax" = "${cfg.package}/share/bat/syntaxes/ghostty.sublime-syntax";
    };
  };
}
