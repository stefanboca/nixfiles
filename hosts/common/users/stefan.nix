{
  config,
  lib,
  pkgs,
  ...
}: {
  users.users.stefan = {
    description = "Stefan Boca";
    isNormalUser = true;
    shell = pkgs.fish;
    extraGroups =
      ["wheel" "video" "audio"]
      ++ lib.optional config.programs.wireshark.enable "wireshark"
      ++ lib.optional config.networking.networkmanager.enable "networkmanager";
  };

  home-manager.users.stefan = import ../../../home/stefan/${config.networking.hostName}.nix;
}
