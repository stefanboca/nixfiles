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
      extraGroups =
        ["wheel" "video" "audio"]
        ++ lib.optional config.programs.wireshark.enable "wireshark"
        ++ lib.optional config.networking.networkmanager.enable "networkmanager";
    };
  };
}
