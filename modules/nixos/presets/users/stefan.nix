{
  config,
  lib,
  pkgs,
  ...
}: let
  inherit (lib.modules) mkIf;
  inherit (lib.options) mkEnableOption;

  cfg = config.presets.users.stefan;
in {
  options.presets.users.stefan = {
    enable = mkEnableOption "stefan preset";
  };

  config = mkIf cfg.enable {
    users.users.stefan = {
      description = "Stefan Boca";
      isNormalUser = true;
      shell = pkgs.fish;
      extraGroups = [
        # keep-sorted start
        "audio"
        "dialout"
        "docker"
        "lp"
        "networkmanager"
        "podman"
        "scanner"
        "video"
        "virtualbox"
        "wheel"
        "wireshark"
        # keep-sorted end
      ];
      autoSubUidGidRange = true;
    };
  };
}
