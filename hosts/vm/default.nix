{
  lib,
  modulesPath,
  pkgs,
  ...
}: {
  imports = [(modulesPath + "/virtualisation/qemu-vm.nix")];

  virtualisation = {
    qemu.options = ["-nographic" "-serial" "mon:stdio"];
    cores = 4;
    memorySize = 4 * 1024;
  };
  system.stateVersion = lib.trivial.release;
  nix = {
    settings.trusted-users = ["root" "nixos"];
    extraOptions = "experimental-features = nix-command flakes";
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
