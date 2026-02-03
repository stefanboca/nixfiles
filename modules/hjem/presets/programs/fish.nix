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

        functions = {
          # disable greeting
          fish_greeting = "";

          realify =
            pkgs.writeText "realify.fish"
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

          # HACK: for now, prompt is configured manually by calling this function
          # configure_tide_prompt =
          #   # fish
          #   ''
          #     # configure tide prompt
          #     tide configure --auto --style=Lean --prompt_colors='True color' --show_time='24-hour format' --lean_prompt_height='Two lines' --prompt_connection=Solid --prompt_connection_andor_frame_color=Lightest --prompt_spacing=Sparse --icons='Few icons' --transient=No
          #     # add jj to prompt
          #     set -U tide_left_prompt_items pwd jj_or_git newline character
          #     # use theme colors instead of hardcoded for most stuff (but use default colors for PWD)
          #     set -U tide_character_color green
          #     set -U tide_character_color_failure red
          #     set -U tide_cmd_duration_color bryellow
          #     set -U tide_context_color_default normal
          #     set -U tide_context_color_root brred
          #     set -U tide_context_color_ssh yellow
          #     set -U tide_git_color_branch green
          #     set -U tide_git_color_conflicted red
          #     set -U tide_git_color_dirty yellow
          #     set -U tide_git_color_operation red
          #     set -U tide_git_color_staged yellow
          #     set -U tide_git_color_stash green
          #     set -U tide_git_color_untracked cyan
          #     set -U tide_git_color_upstream green
          #     set -U tide_private_mode_color normal
          #     set -U tide_status_color brgreen
          #     set -U tide_status_color_failure brred
          #     set -U tide_time_color green
          #     set -U tide_vi_mode_color_default blue
          #     set -U tide_vi_mode_color_insert brgreen
          #     set -U tide_vi_mode_color_replace bryellow
          #     set -U tide_vi_mode_color_visual brmagenta
          #   '';

          # jj integration for tide
          # _tide_item_jj =
          #   # fish
          #   ''
          #     command -q jj && jj --ignore-working-copy --at-op=@ root &>/dev/null || return 1
          #     _tide_print_item jj $tide_jj_icon' ' (jj log -r@ --ignore-working-copy --at-op=@ --no-pager --no-graph --color always -T shell_prompt)
          #   '';
          # _tide_item_jj_or_git =
          #   # fish
          #   ''_tide_item_jj || _tide_item_git'';

          fish_jj_prompt =
            # fish
            ''
              # If jj isn't installed, there's nothing we can do
              # Return 1 so the calling prompt can deal with it
              if not command -sq jj
                  return 1
              end
              set -l info "$(
                jj log 2>/dev/null --no-graph --ignore-working-copy --at-operation=@ --color=always --revisions=@ --template shell_prompt
              )"
              or return 1
              if test -n "$info"
                  printf ' %s' $info
              end

            '';

          fish_prompt =
            # fish
            ''
              set -l __fish_last_status $status
              set -l normal (set_color $fish_color_option)

              # Color the prompt differently when we're root
              set -l color_cwd $fish_color_cwd
              set -l suffix '❯'
              if test "$fish_key_bindings" = fish_vi_key_bindings
                  or test "$fish_key_bindings" = fish_hybrid_key_bindings
                  switch $fish_bind_mode
                      case default
                          set suffix '❮'
                      case replace replace_one
                          set suffix '▶'
                      case visual
                          set suffix V
                  end
              end
              if functions -q fish_is_root_user; and fish_is_root_user
                  if set -q fish_color_cwd_root
                      set color_cwd $fish_color_cwd_root
                  end
                  set suffix '#'
              end

              set -l suffix_color $normal
              if not contains $__fish_last_status 0
                  set suffix_color (set_color $fish_color_status)
              end

              echo
              echo -s (prompt_login)' ' (set_color $color_cwd) (prompt_pwd --dir-length 0) $normal (fish_vcs_prompt)
              echo -n -s $suffix_color $suffix " "
            '';

          fish_right_prompt =
            #fish
            ''
              set -l last_pipestatus $pipestatus
              set -lx __fish_last_status $status # Export for __fish_print_pipestatus.

              set -l normal (set_color $fish_color_option)

              # Write pipestatus
              # If the status was carried over (if no command is issued or if `set` leaves the status untouched), don't bold it.
              set -l bold_flag --bold
              set -q __fish_prompt_status_generation; or set -g __fish_prompt_status_generation $status_generation
              if test $__fish_prompt_status_generation = $status_generation
                  set bold_flag
              end
              set __fish_prompt_status_generation $status_generation
              set -l status_color (set_color $fish_color_status)
              set -l statusb_color (set_color $bold_flag $fish_color_status)
              set -l prompt_status (__fish_print_pipestatus "" "" "|" "$status_color" "$statusb_color" $last_pipestatus)

              echo -n -s $prompt_status $normal " "(date +%T)
            '';
        };

        earlyConfigFiles = {
          configure_interactive =
            # fish
            ''
              status is-interactive || exit 0
              set -g fish_key_bindings fish_hybrid_key_bindings
              functions -e fish_mode_prompt
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
  };
}
