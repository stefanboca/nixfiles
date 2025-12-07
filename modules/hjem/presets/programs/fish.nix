{
  config,
  lib,
  pkgs,
  ...
}: let
  inherit (lib.modules) mkIf;
  inherit (lib.options) mkEnableOption;

  cfg = config.presets.programs.fish;
in {
  options.presets.programs.fish = {
    enable = mkEnableOption "fish preset";
  };

  config.rum.programs = mkIf cfg.enable {
    # TODO: explore starship prompt

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

      functions = {
        # disable greeting
        fish_greeting = "";
        # Vi-style bindings that inherit emacs-style bindings in all modes
        fish_hybrid_key_bindings =
          # fish
          ''
            for mode in default insert visual
                fish_default_key_bindings -M $mode
            end
            fish_vi_key_bindings --no-erase insert
          '';

        realify =
          # fish
          ''
            function realify --description="Replace symlink(s) with real file(s) in‑place"
                for file in $argv
                    if test -L "$file"
                        cp --remove-destination (readlink -f "$file") "$file"
                        chmod +w "$file"
                    else
                        echo "realify: $file is not a symlink" >&2
                    end
                end
            end
          '';

        # jj integration for tide
        _tide_item_jj =
          # fish
          ''
            command -q jj && jj --ignore-working-copy --at-op=@ root &>/dev/null || return 1
            _tide_print_item jj $tide_jj_icon' ' (jj log -r@ --ignore-working-copy --at-op=@ --no-pager --no-graph --color always -T shell_prompt)
          '';
        _tide_item_jj_or_git =
          # fish
          ''_tide_item_jj || _tide_item_git'';
      };

      plugins = {inherit (pkgs.fishPlugins) autopair git-abbr puffer tide;};

      earlyConfigFiles = {
        set_key_bindings =
          # fish
          ''
            set -U fish_key_bindings fish_hybrid_key_bindings
          '';
        configure_tide_prompt =
          # fish
          ''
            # configure tide prompt
            tide configure --auto --style=Lean --prompt_colors='True color' --show_time='24-hour format' --lean_prompt_height='Two lines' --prompt_connection=Solid --prompt_connection_andor_frame_color=Lightest --prompt_spacing=Sparse --icons='Few icons' --transient=No
            # add jj to prompt
            set -U tide_left_prompt_items pwd jj_or_git newline character
            # use theme colors instead of hardcoded for most stuff (but use default colors for PWD)
            set -U tide_character_color green
            set -U tide_character_color_failure red
            set -U tide_cmd_duration_color bryellow
            set -U tide_context_color_default normal
            set -U tide_context_color_root brred
            set -U tide_context_color_ssh yellow
            set -U tide_git_color_branch green
            set -U tide_git_color_conflicted red
            set -U tide_git_color_dirty yellow
            set -U tide_git_color_operation red
            set -U tide_git_color_staged yellow
            set -U tide_git_color_stash green
            set -U tide_git_color_untracked cyan
            set -U tide_git_color_upstream green
            set -U tide_private_mode_color normal
            set -U tide_status_color brgreen
            set -U tide_status_color_failure brred
            set -U tide_time_color green
            set -U tide_vi_mode_color_default blue
            set -U tide_vi_mode_color_insert brgreen
            set -U tide_vi_mode_color_replace bryellow
            set -U tide_vi_mode_color_visual brmagenta
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
      integrations.fish.enable = true;
    };

    zoxide = {
      enable = true;
      integrations.fish.enable = true;
    };
  };
}
