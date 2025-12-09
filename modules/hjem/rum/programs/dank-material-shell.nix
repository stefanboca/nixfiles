{
  config,
  lib,
  pkgs,
  ...
}: let
  inherit (lib.meta) getExe getExe';
  inherit (lib.lists) optional optionals;
  inherit (lib.modules) mkIf;
  inherit (lib.options) mkEnableOption mkPackageOption;

  cfg = config.rum.programs.dank-material-shell;
in {
  options.rum.programs.dank-material-shell = {
    enable = mkEnableOption "DankMaterialShell";

    package = mkPackageOption pkgs.dmsPkgs "dms-shell" {};

    audioWavelength.enable = mkEnableOption "audio wavelength";
    brightnessControl.enable = mkEnableOption "brightness control";
    calendarEvents.enable = mkEnableOption "calendar events";
    clipboard.enable = mkEnableOption "clipboard";
    colorPicker.enable = mkEnableOption "color picker";
    dynamicTheming.enable = mkEnableOption "dynamic theming";
    systemMonitoring = {
      enable = mkEnableOption "system monitoring";
      package = mkPackageOption pkgs.dmsPkgs "dgop" {};
    };
    systemSound.enable = mkEnableOption "system sound";
    vpn.enable = mkEnableOption "vpn";

    integrations = {
      niri.enable = mkEnableOption "DankMaterialShell integration with niri";
    };
  };

  config = mkIf cfg.enable {
    packages =
      [
        cfg.package
        pkgs.ddcutil
        pkgs.material-symbols
        pkgs.inter
        pkgs.fira-code
      ]
      ++ optional cfg.systemMonitoring.enable cfg.systemMonitoring.package
      ++ optionals cfg.clipboard.enable [pkgs.cliphist pkgs.wl-clipboard]
      ++ optionals cfg.vpn.enable [pkgs.glib pkgs.networkmanager]
      ++ optional cfg.brightnessControl.enable pkgs.brightnessctl
      ++ optional cfg.colorPicker.enable pkgs.hyprpicker
      ++ optional cfg.dynamicTheming.enable pkgs.mutagen
      ++ optional cfg.audioWavelength.enable pkgs.cava
      ++ optional cfg.calendarEvents.enable pkgs.khal;

    rum.programs.quickshell = {
      enable = true;
      package = pkgs.dmsPkgs.quickshell;
      extraBuildInputs = [
        pkgs.qt6.qtmultimedia
      ];
      configs.dms = "${cfg.package}/share/quickshell/dms";
    };

    rum.desktops.niri.spawn-at-startup = mkIf cfg.integrations.niri.enable (
      [[(getExe cfg.package) "run"]]
      ++ optional cfg.clipboard.enable [(getExe' pkgs.wl-clipboard "wl-paste") "--watch" (getExe pkgs.cliphist) "store"]
    );
  };
}
