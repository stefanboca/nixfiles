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
        # keep-sorted start
        "application/pdf" = "org.gnome.Evince.desktop";
        "application/xhtml+xml" = firefox;
        "image/jpeg" = "org.gnome.Loupe.desktop";
        "image/png" = "org.gnome.Loupe.desktop";
        "image/svg" = "org.gnome.Loupe.desktop";
        "image/svg+xml" = "org.gnome.Loupe.desktop";
        "text/html" = firefox;
        "text/plain" = "gnome-text-editor.desktop";
        "text/rtf" = "writer.desktop";
        "x-scheme-handler/discord" = "vesktop.desktop";
        "x-scheme-handler/http" = firefox;
        "x-scheme-handler/https" = firefox;
        "x-scheme-handler/prusaslicer" = "PrusaSlicer.desktop";
        # keep-sorted end
      };
      addedAssociations = {
        # keep-sorted start
        "model/3mf" = "PrusaSlicer.desktop";
        "x-scheme-handler/discord" = "vesktop.desktop";
        "x-scheme-handler/prusaslicer" = "PrusaSlicer.desktop";
        # keep-sorted end
      };
    };
  };
}
