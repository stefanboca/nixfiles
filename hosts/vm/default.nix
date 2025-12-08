{
  inputs,
  modulesPath,
  pkgs,
  self,
  ...
}: {
  nix = {
    package = pkgs.nixVersions.latest;
    channel.enable = false;
    settings = {
      allowed-users = ["root" "@wheel"];
      experimental-features = ["nix-command" "flakes"];
      substituters = ["https://cache.nixos.org"];
      trusted-public-keys = ["cache.nixos.org-1:6NCHdD59X431o0gWypbMrAURkbJ16ZPMQFGspcDShjY="];
      trusted-users = ["root" "@wheel"];
      use-xdg-base-directories = true;
    };
  };

  nixpkgs = {
    overlays = builtins.attrValues self.overlays;
    config = {
      allowUnfree = true;
    };
    hostPlatform = "x86_64-linux";
  };

  imports = [(modulesPath + "/virtualisation/qemu-vm.nix")];
  virtualisation.qemu.options = [
    "-enable-kvm"
    "-vga none"
    "-device virtio-gpu-gl-pci"
    "-display gtk,gl=on"
  ];

  system = {
    nixos-init.enable = true;
    etc.overlay.enable = true;
    stateVersion = "26.05";
    tools.nixos-generate-config.enable = false;
  };

  hardware.graphics.enable = true;

  boot = {
    loader = {
      limine.enable = true;
      efi.canTouchEfiVariables = true;
    };
    tmp.useTmpfs = true;
    initrd.systemd.enable = true;
  };

  systemd.services.nix-daemon.environment.TMPDIR = "/var/tmp";

  services = {
    dbus.implementation = "broker";
    irqbalance.enable = true;
    userborn.enable = true;
  };

  users = {
    mutableUsers = false;
    users.stefan = {
      extraGroups = ["wheel" "tty"];
      isNormalUser = true;
      password = "password";
      shell = pkgs.fish;
    };
  };

  environment.defaultPackages = [];

  programs = {
    fish.enable = true;
    command-not-found.enable = false;
    niri = {
      enable = true;
      package = pkgs.niri-unstable;
    };
  };

  hjem = {
    specialArgs = {inherit inputs self;};
    extraModules = [inputs.hjem-rum.hjemModules.default] ++ builtins.attrValues self.hjemModules;
    clobberByDefault = true;
    users.stefan = {
      enable = true;
      catppuccin = {
        enable = true;
        misc.cursors = {
          enable = true;
          integrations = {
            gtk.enable = true;
            niri.enable = true;
          };
        };
        misc.gtk.icon.enable = true;
        programs = {
          atuin.enable = true;
          bat.enable = true;
          eza.enable = true;
          firefox.enable = true;
          vesktop.enable = true;
        };
      };
      presets = {
        desktops.niri.enable = true;
        development.rust.enable = true;
        misc.xdg.enable = true;
        misc.gtk.enable = true;
        programs = {
          cli.enable = true;
          firefox.enable = true;
          fish.enable = true;
          ghostty.enable = true;
          neovim.enable = true;
          spicetify.enable = true;
          ssh.enable = true;
          vcs.enable = true;
          vesktop.enable = true;
        };
      };
    };
  };

  documentation = {
    enable = false;
    dev.enable = false;
    doc.enable = false;
    info.enable = false;
    man.enable = false;
    nixos.enable = false;
  };
}
