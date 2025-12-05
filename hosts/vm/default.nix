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
  };

  hjem = {
    specialArgs = {inherit inputs self;};
    extraModules = [inputs.hjem-rum.hjemModules.default] ++ builtins.attrValues self.hjemModules;
    users.stefan = {
      enable = true;
      rum.programs = {
        atuin = {
          enable = true;
          flags = ["--disable-up-arrow"];
          settings = {
            ctrl_n_shortcuts = true;
            enter_accept = true;
            sync.records = true;
            sync_frequency = "1h";
            workspaces = true;
            stats = {
              # Set commands where we should consider the subcommand for statistics. Eg, kubectl get vs just kubectl
              common_subcommands = ["cargo" "docker" "git" "ip" "jj" "nh" "nix" "nmcli" "npm" "pnpm" "podman" "port" "systemctl" "uv"];
              # Set commands that should be totally stripped and ignored from stats
              common_prefix = ["sudo"];
              # Set commands that will be completely ignored from stats
              ignored_commands = ["cd" "ls" "z" "eza"];
            };
          };
          integrations.fish.enable = true;
        };
        bat.enable = true;
        bottom.enable = true;
        git.enable = true;
        fish.enable = true;
        fzf = {
          enable = true;
          defaultOpts = ["--cycle" "--layout=reverse" "--border" "--height=-3" "--preview-window=wrap" "--highlight-line" "--info=inline-right" "--ansi"];
        };
        ghostty = {
          enable = true;
          settings = {
            auto-update = "off";
            shell-integration-features = true;
            image-storage-limit = 128 * 1024 * 1024; # 128 MB
            scrollback-limit = 128 * 1024 * 1024; # 128 MB
            quit-after-last-window-closed = true;
            quit-after-last-window-closed-delay = "5m";

            window-inherit-working-directory = true;
            window-theme = "ghostty";
            window-decoration = "none";
            gtk-tabs-location = "bottom";
            window-padding-x = 0;
            window-padding-y = 0;

            keybind = [
              "alt+t=toggle_tab_overview"
              "ctrl+shift+k=clear_screen"
              "ctrl+shift+backslash=new_split:right"
              "ctrl+shift+minus=new_split:down"
              "ctrl+shift+x=close_surface"

              "shift+up=goto_split:up"
              "shift+down=goto_split:down"
              "shift+left=goto_split:left"
              "shift+right=goto_split:right"
            ];
          };
          integrations.bat.enable = true;
        };
        starship = {
          enable = true;
          transience.enable = true;
          integrations.fish.enable = true;
        };
        zoxide = {
          enable = true;
          integrations.fish.enable = true;
        };
        vesktop = {
          enable = true;
        };
        spicetify = {
          enable = true;
        };
        nix-index = {
          enable = true;
          database = {
            cache.enable = true;
            comma.enable = true;
          };
          integrations.fish.enable = true;
        };
        gh = {
          enable = true;
          integrations.git.credentialHelper.enable = true;
        };
        jujutsu.enable = true;
        jjui.enable = true;
        ssh = {
          enable = true;
          settings =
            # ssh_config
            ''
              Host github.com
                User git
                HostName github.com
                IdentitiesOnly yes
                IdentityFile ~/.ssh/id_ed25519_git

              Host *
                ForwardAgent no
                AddKeysToAgent no
                UserKnownHostsFile ~/.ssh/known_hosts
                ControlPath ~/.ssh/master-%r@%n:%p
                ControlPersist no
            '';
        };
        dank-material-shell = {
          enable = true;

          audioWavelength.enable = true;
          brightnessControl.enable = true;
          clipboard.enable = true;
          systemMonitoring.enable = true;
          systemSound.enable = true;

          integrations.niri.enable = true;
        };
      };
      rum.desktops.niri = {
        enable = true;
        package = pkgs.niri-unstable;
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
