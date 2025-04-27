{ pkgs, ... }:

{
  users.users.stefan = {
    description = "Stefan Boca";
    isNormalUser = true;
    shell = pkgs.fish;
    extraGroups = [
      "wheel"
      "video"
    ];
    password = "temporarypassword"; # FIXME:
  };

  # FIXME: using a hardcoded hostname for now, for testing in vm
  home-manager.users.stefan = import ../../../home/stefan/laptop.nix;
  # home-manager.users.stefan = import ../../../home/stefan/${config.networking.hostName}.nix;
}
