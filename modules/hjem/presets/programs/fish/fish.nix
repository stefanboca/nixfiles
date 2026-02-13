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
    # The following are all vendored plugins. They're added to `packages`
    # instead of using `rum.programs.fish.plugins`, in order to avoid IFD,
    # which the rum module uses to check if they're vendored (and then, if they
    # are, adds them to `packages` anyways).
    packages = with pkgs.fishPlugins; [
      autopair
      git-abbr
      puffer
    ];

    rum.programs = {
      fish = {
        enable = true;

        abbrs = {
          sc = "systemctl --system";
          scu = "systemctl --user";

          nd = "nix develop -c fish";
          nf = "nix flake";
          nfu = "nix flake update";
          nrs = "nh os switch";
          ns = "nix shell";
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
            # commands where the subcommand should be considered
            common_subcommands = ["cargo" "docker" "git" "ip" "jj" "nh" "nix" "nmcli" "npm" "pnpm" "podman" "systemctl" "uv"];
            # command prefixes that should be stripped and ignored
            common_prefix = ["sudo" "run0"];
            # commands that will be completely ignored from stats
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
