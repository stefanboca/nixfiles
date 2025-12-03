{
  inputs = {
    nixpkgs.url = "https://channels.nixos.org/nixos-unstable/nixexprs.tar.xz";
    nixos-hardware.url = "github:NixOS/nixos-hardware";
    flake-parts.url = "github:hercules-ci/flake-parts";
    treefmt-nix.url = "github:numtide/treefmt-nix";
    treefmt-nix.inputs.nixpkgs.follows = "nixpkgs";

    disko.url = "github:nix-community/disko";
    disko.inputs.nixpkgs.follows = "nixpkgs";

    sops-nix.url = "github:Mic92/sops-nix";
    sops-nix.inputs.nixpkgs.follows = "nixpkgs";

    home-manager.url = "github:nix-community/home-manager";
    home-manager.inputs.nixpkgs.follows = "nixpkgs";

    nix-index-database.url = "github:nix-community/nix-index-database";
    nix-index-database.inputs.nixpkgs.follows = "nixpkgs";

    niri.url = "github:sodiboo/niri-flake";
    niri.inputs.nixpkgs.follows = "nixpkgs";
    dank-material-shell.url = "github:AvengeMedia/DankMaterialShell";
    dank-material-shell.inputs.nixpkgs.follows = "nixpkgs";

    catppuccin.url = "github:catppuccin/nix";
    catppuccin.inputs.nixpkgs.follows = "nixpkgs";

    spicetify-nix.url = "github:Gerg-L/spicetify-nix";
    spicetify-nix.inputs.nixpkgs.follows = "nixpkgs";

    fenix.url = "github:nix-community/fenix";
    fenix.inputs.nixpkgs.follows = "nixpkgs";

    firefox-nightly.url = "github:nix-community/flake-firefox-nightly";
    firefox-nightly.inputs.nixpkgs.follows = "nixpkgs";

    hjem.url = "github:feel-co/hjem";
    hjem.inputs.nixpkgs.follows = "nixpkgs";
    hjem-rum = {
      url = "github:snugnug/hjem-rum";
      inputs = {
        nixpkgs.follows = "nixpkgs";
        hjem.follows = "hjem";
      };
    };

    snv = {
      url = "github:stefanboca/nvim";
      inputs = {
        nixpkgs.follows = "nixpkgs";
        fenix.follows = "fenix";
        flake-parts.follows = "flake-parts";
      };
    };
  };

  outputs = {
    self,
    flake-parts,
    nixpkgs,
    ...
  } @ inputs:
    flake-parts.lib.mkFlake {inherit inputs;} {
      imports = [
        ./modules/flake/modules.nix
        ./modules/flake/nix.nix
        ./modules/flake/overlays.nix
        ./modules/flake/packages.nix
        ./modules/flake/shell.nix
      ];

      systems = ["x86_64-linux"];

      flake = {
        nixosConfigurations = {
          # TODO: find a better hostname
          laptop = nixpkgs.lib.nixosSystem {
            system = "x86_64-linux";
            modules = [self.nixosModules.laptop];
            specialArgs = {inherit self inputs;};
          };

          vm = nixpkgs.lib.nixosSystem {
            system = "x86_64-linux";
            specialArgs = {inherit self inputs;};
            modules = [
              inputs.hjem.nixosModules.default
              (
                {
                  pkgs,
                  modulesPath,
                  inputs,
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

                  nixpkgs.config = {allowUnfree = true;};

                  imports = ["${modulesPath}/virtualisation/qemu-vm.nix"];

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
                    # xserver.enable = true;
                    # displayManager.sddm = {
                    #   enable = true;
                    #   wayland.enable = true;
                    # };
                    # xserver.desktopManager.xfce = {
                    #   enable = true;
                    # };
                    # desktopManager.gnome.enable = true;
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
                    # niri.enable = true;
                  };

                  hjem = {
                    extraModules = [
                      inputs.hjem-rum.hjemModules.default
                      (import ./modules/hjem)
                    ];
                    specialArgs = {inherit self inputs;};
                    clobberByDefault = true;
                    users.stefan = {
                      enable = true;
                      files.".self".text = "${self}";
                      # rum.desktops.niri = {
                      #   enable = true;
                      #   config =
                      #     # kdl
                      #     ''
                      #       debug {
                      #         render-drm-device "/dev/dri/renderD128"
                      #       }
                      #     '';
                      # };
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
                          # package = pkgs.vesktop.override {withSystemVencord = true;};
                        };
                        spicetify = {
                          enable = true;
                          # enabledExtensions = with pkgs.spicePkgs.extensions; [
                          #   adblockify
                          #   bookmark
                          # ];
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
              )
            ];
          };
        };
      };

      perSystem = {
        self',
        lib,
        system,
        ...
      }: {
        treefmt = {
          flakeCheck = true;
          programs = {
            deadnix.enable = true;
            keep-sorted.enable = true;
            alejandra.enable = true;
          };
        };

        checks = let
          machinesPerSystem = {
            x86_64-linux = ["laptop"];
          };
          nixosMachines = lib.mapAttrs' (n: lib.nameValuePair "nixos-${n}") (
            lib.genAttrs (machinesPerSystem.${system} or []) (
              name: self.nixosConfigurations.${name}.config.system.build.toplevel
            )
          );

          packages = lib.mapAttrs' (n: lib.nameValuePair "package-${n}") self'.packages;
          devShells = lib.mapAttrs' (n: lib.nameValuePair "devShell-${n}") self'.devShells;
        in
          nixosMachines // packages // devShells;
      };
    };
}
