{
  lib,
  modulesPath,
  pkgs,
  ...
}: {
  imports = [(modulesPath + "/virtualisation/qemu-vm.nix")];

  nixpkgs.hostPlatform = "x86_64-linux";

  virtualisation = {
    qemu.options = ["-nographic" "-serial" "mon:stdio"];
    cores = 4;
    memorySize = 4 * 1024;
  };
  system.stateVersion = lib.trivial.release;
  nix.settings = {
    trusted-users = ["@wheel"];
    experimental-features = ["flakes" "nix-command"];
  };

  programs.fish.enable = true;
  security.sudo.wheelNeedsPassword = false;
  users.users.nixos = {
    isNormalUser = true;
    hashedPassword = "";
    extraGroups = ["wheel"];
    shell = pkgs.fish;
  };

  documentation = {
    nixos.enable = false;
    enable = false;
  };
}
