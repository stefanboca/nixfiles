{
  inputs,
  modulesPath,
  pkgs,
  self,
  ...
}: {
  imports = [(modulesPath + "/virtualisation/qemu-vm.nix")];

  virtualisation.qemu.options = [
    "-enable-kvm"
    "-vga none"
    "-device virtio-gpu-gl-pci"
    "-display gtk,gl=on"
  ];

  nixpkgs.hostPlatform = "x86_64-linux";
  system.stateVersion = "26.05";

  users.users.stefan.password = "password";

  services.displayManager.sddm = {
    enable = true;
    wayland.enable = true;
  };

  catppuccin = {
    enable = true;
    accent = "teal";
  };
  presets = {
    common.enable = true;
    desktop.enable = true;
    gaming.enable = true;
    programs.niri.enable = true;
    users.stefan.enable = true;
  };

  hjem = {
    linker = inputs.hjem.packages.${pkgs.stdenv.hostPlatform.system}.smfh;
    specialArgs = {inherit inputs self;};
    extraModules = [self.hjemModules.stefan];
    clobberByDefault = true;

    users.stefan = {
      enable = true;
      presets.users.stefan.enable = true;
    };
  };
}
