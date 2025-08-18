{
  config,
  lib,
  pkgs,
  ...
}:

let
  cfg = config.desktop.gaming;

  steam-run-libs = pkgs.runCommand "steam-run-libs" { } ''
    mkdir $out
    ln -s ${pkgs.steam-run.fhsenv}/usr/lib64 $out/lib
  '';
in
{
  options.desktop.gaming = {
    enable = lib.mkEnableOption "Enable the gaming module.";
  };

  config = lib.mkIf cfg.enable {
    environment.systemPackages = with pkgs; [
      gamemode
      mangohud
      prismlauncher
    ];

    programs = {
      steam = {
        enable = true;
        protontricks.enable = true;
      };

      nix-ld = {
        enable = true;
        libraries = [ steam-run-libs ];
      };
    };
  };
}
