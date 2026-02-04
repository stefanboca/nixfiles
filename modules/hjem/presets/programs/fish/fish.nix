{
  config,
  lib,
  pkgs,
  ...
}: let
  inherit (builtins) attrNames readDir;
  inherit (lib.attrsets) genAttrs' nameValuePair;
  inherit (lib.modules) mkIf;
  inherit (lib.options) mkEnableOption;

  configs = attrNames (readDir ./conf.d);
  configFiles = genAttrs' configs (file: nameValuePair "fish/conf.d/${file}" {source = ./conf.d + "/${file}";});

  functions = attrNames (readDir ./functions);
  functionFiles = genAttrs' functions (file: nameValuePair "fish/functions/${file}" {source = ./functions + "/${file}";});

  cfg = config.presets.programs.fish;
in {
  options.presets.programs.fish = {
    enable = mkEnableOption "fish preset";
  };

  config = mkIf cfg.enable {
    # TODO: explore starship prompt

    # The following are all vendored plugins. They're added to `packages`
    # instead of using `rum.programs.fish.plugins`, in order to avoid IFD,
    # which the rum module uses to check if they're vendored (and then, if they
    # are, adds them to `packages`).
    packages = with pkgs.fishPlugins; [
      autopair
      git-abbr
      puffer
      # tide
    ];

    rum.programs = {
      fish = {
        enable = true;

        abbrs = {
          sc = "sudo systemctl --system";
          scu = "systemctl --user";

          nb = "nix build";
          nd = "nix develop -c fish";
          nf = "nix flake";
          nfu = "nix flake update";
          nhb = "nh home build";
          nhs = "nh home switch";
          nr = "nix run";
          nrr = "nh os repl";
          nrs = "nh os switch";
          ns = "nix search";
          nsh = "nix shell";

          ls = "eza";
          ll = "eza -l";
          la = "eza -a";
          lt = "eza --tree";
          lla = "eza -la";

          c = "cargo";
          j = "jj";
          ju = "jjui";
          nv = "neovide";
          o = "xdg-open";
          s = "snv";
          se = "sudoedit";
        };

        earlyConfigFiles = {
          configure_interactive =
            # fish
            ''
              status is-interactive || exit 0
              set -g fish_key_bindings fish_hybrid_key_bindings
              fish_config theme choose catppuccin-mocha
            '';
        };
      };

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

      nix-index = {
        enable = true;
        database = {
          cache.enable = true;
          comma.enable = true;
        };
      };

      zoxide = {
        enable = true;
        integrations.fish.enable = true;
      };
    };

    xdg.config.files = configFiles // functionFiles;
  };
}
