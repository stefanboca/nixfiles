{
  inputs,
  lib,
  self,
}: {
  # TODO: find a better hostname
  laptop = lib.nixosSystem {
    specialArgs = {inherit inputs self;};
    modules = [
      ./laptop
      self.nixosModules.catppuccin
      self.nixosModules.extensions
      self.nixosModules.presets
      inputs.secrets.nixosModules.common
      inputs.secrets.nixosModules.laptop

      inputs.disko.nixosModules.disko
      inputs.hjem.nixosModules.default
      inputs.noctalia-shell.nixosModules.default
      inputs.sops-nix.nixosModules.sops
      inputs.watt.nixosModules.default

      inputs.nixos-hardware.nixosModules.asus-battery
      inputs.nixos-hardware.nixosModules.common-cpu-intel
      inputs.nixos-hardware.nixosModules.common-gpu-nvidia
      inputs.nixos-hardware.nixosModules.common-pc-ssd
    ];
  };

  vm = lib.nixosSystem {
    specialArgs = {inherit inputs self;};
    modules = [
      ./vm
      self.nixosModules.catppuccin
      self.nixosModules.presets

      inputs.hjem.nixosModules.default
    ];
  };
}
