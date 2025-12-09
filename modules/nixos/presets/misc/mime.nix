{
  config,
  lib,
  ...
}: let
  inherit (lib.modules) mkIf;
  inherit (lib.options) mkEnableOption;

  cfg = config.presets.mime;
in {
  options.presets.mime = {
    enable = mkEnableOption "mime preset";
  };

  config = mkIf cfg.enable {
    xdg.mime = let
      firefox = ["firefox-nightly.desktop" "firefox.desktop"];
    in {
      defaultApplications = {
        "application/pdf" = "org.gnome.Evince.desktop";
        "application/xhtml+xml" = firefox;
        "text/html" = firefox;
        "text/plain" = "gnome-text-editor.desktop";
        "text/rtf" = "writer.desktop";
        "x-scheme-handler/discord" = "vesktop.desktop";
        "x-scheme-handler/http" = firefox;
        "x-scheme-handler/https" = firefox;
        "x-scheme-handler/prusaslicer" = "PrusaSlicer.desktop";
      };
      addedAssociations = {
        "model/3mf" = "PrusaSlicer.desktop";
        "x-scheme-handler/discord" = "vesktop.desktop";
        "x-scheme-handler/prusaslicer" = "PrusaSlicer.desktop";
      };
    };
  };
}
