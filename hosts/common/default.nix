{
  config,
  lib,
  pkgs,
  ...
}: {
  imports = [
    ./users/root.nix
    ./users/stefan.nix
  ];

  sops.defaultSopsFile = ./secrets.yaml;

  sops.secrets.dnsmasq-hosts = lib.mkIf (config.networking.networkmanager.dns == "dnsmasq") {
    path = "/etc/NetworkManager/dnsmasq.d/hosts";
  };

  nix.channel.enable = false;

  programs.fish.enable = true;
  users.defaultUserShell = pkgs.fish;
  users.mutableUsers = false;
}
