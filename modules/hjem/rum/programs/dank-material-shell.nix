{
  config,
  inputs,
  lib,
  pkgs,
  ...
}: let
  inherit (lib.lists) optional optionals;
  inherit (lib.modules) mkIf;
  inherit (lib.options) mkEnableOption mkPackageOption;

  inherit (pkgs.stdenv.hostPlatform) system;
  dmsPkgs = inputs.dank-material-shell.packages.${system};

  cfg = config.rum.programs.dank-material-shell;
in {
  options.rum.programs.dank-material-shell = {
    enable = mkEnableOption "DankMaterialShell";

    package = mkPackageOption dmsPkgs "dms-shell" {};

    audioWavelength.enable = mkEnableOption "audio wavelength";
    calendarEvents.enable = mkEnableOption "calendar events";
    clipboard.enable = mkEnableOption "clipboard";
    dynamicTheming.enable = mkEnableOption "dynamic theming";
    systemMonitoring = {
      enable = mkEnableOption "system monitoring";
      package = mkPackageOption pkgs "dgop" {};
    };
    systemSound.enable = mkEnableOption "system sound";
    vpn.enable = mkEnableOption "vpn";

    integrations = {
      niri.enable = mkEnableOption "DankMaterialShell integration with niri";
    };
  };

  config = mkIf cfg.enable {
    packages =
      [cfg.package]
      ++ optional cfg.systemMonitoring.enable cfg.systemMonitoring.package
      ++ optionals cfg.clipboard.enable [pkgs.cliphist pkgs.wl-clipboard]
      ++ optionals cfg.vpn.enable [pkgs.glib pkgs.networkmanager]
      ++ optional cfg.dynamicTheming.enable pkgs.mutagen
      ++ optional cfg.audioWavelength.enable pkgs.cava
      ++ optional cfg.calendarEvents.enable pkgs.khal;

    rum.programs.quickshell = {
      enable = true;
      package = dmsPkgs.quickshell;
      extraBuildInputs = [
        pkgs.qt6.qtmultimedia
      ];
      configs.dms = "${cfg.package}/share/quickshell/dms";
    };

    rum.desktops.niri.spawn-at-startup = mkIf cfg.integrations.niri.enable (
      [["dms" "run"]]
      ++ optional cfg.clipboard.enable ["wl-paste" "--watch" "cliphist" "store"]
    );
  };
}
