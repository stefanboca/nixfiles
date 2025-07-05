{
  config,
  lib,
  pkgs,
  ...
}:

let
  cfg = config.cli;

  name = "Stefan Boca";
  email = "stefan.r.boca@gmail.com";
in
{
  config = lib.mkIf cfg.enable {
    home.packages = with pkgs; [
      difftastic # syntax-aware structural diff tool
      jjui # TUI for jujutsu
      mergiraf # syntax-aware structural merge driver
      meld # Visual diff and merge tool
    ];

    programs = {
      gh.enable = true; # github CLI

      git = {
        enable = true;
        lfs.enable = true;
        userName = name;
        userEmail = email;
        signing = {
          signByDefault = true;
          format = "ssh";
          key = "~/.ssh/id_ed25519_git.pub";
        };
        extraConfig = {
          gpg.ssh.allowedSignersFile = "~/.ssh/allowed_signers";
          url."ssh://git@github.com" = {
            insteadOf = "https://github.com";
          };
          init.defautlBranch = "main";
          pull.rebase = true;
        };
      };

      # better git
      jujutsu = {
        enable = true;

        settings = {
          user = { inherit name email; };

          ui = {
            default-command = "log";
            diff-formatter = "difft";
            editor = [
              "nvim"
              "--cmd"
              "let g:quit_on_write=1"
            ];
            log-word-wrap = true;
          };

          aliases = {
            tug = [
              "bookmark"
              "move"
              "--from"
              "closest_bookmark(@-)"
              "--to"
              "@-"
            ];

            cm = [ "commit" ];
            d = [ "diff" ];
            n = [ "new" ];
            rb = [ "rebase" ];
            s = [ "show" ];

            g = [ "git" ];
            gc = [
              "git"
              "clone"
              "--colocate"
            ];
            gp = [
              "git"
              "push"
            ];
            gf = [
              "git"
              "fetch"
            ];
            gr = [
              "git"
              "remote"
            ];

            c = [
              "log"
              "-r"
              "current_branch()"
            ];
            a = [
              "log"
              "-r"
              "all()"
            ];
          };

          revset-aliases = {
            "current_branch()" = "ancestors(immutable_heads()..@, 2)";
            "closest_bookmark(to)" = "heads(::to & bookmarks())";
          };

          merge-tools = {
            nvim = {
              program = "nvim";
              merge-args = [
                "--cmd"
                "let g:quit_on_write=1"
                "-d"
                "$output"
                "-M"
                "$left"
                "$base"
                "$right"
                "-c"
                "wincmd J"
                "-c"
                "set modifiable"
                "-c"
                "set write"
              ];
              diff-invocation-mode = "file-by-file";
              merge-tool-edits-conflict-markers = true;
              conflict-marker-style = "snapshot";
            };

            mergiraf = {
              program = "mergiraf";
              merge-args = [
                "merge"
                "$base"
                "$left"
                "$right"
                "-o"
                "$output"
                "--fast"
              ];
              merge-conflict-exit-codes = [ 1 ];
              conflict-marker-style = "git";
            };
          };

          signing = {
            behavior = "own";
            backend = "ssh";
            key = "~/.ssh/id_ed25519_git.pub";
            backends.ssh.allowed-signers = "~/.ssh/allowed_signers";
          };

          git = {
            push-bookmark-prefix = "sb/push-";
            private-commits = "description(glob:'wip:*') | description(glob:'private:*') | description(glob:'priv:*')";
          };

          core = {
            fsmonitor = "none";
            watchman.register-snapshot-trigger = true;
          };

          colors = {
            description = "cyan";
            divergent = "magenta";
            hidden = "yellow";
            "diff files len" = "yellow";
            "diff stat total_added" = "green";
            "diff stat total_removed" = "red";
          };

          template-aliases = {
            shell_prompt = ''
              separate(" ",
                change_id.shortest(),
                commit_id.shortest(),
                bookmarks.map(|x| truncate_end(10, x, label("bookmark", "…"))).join(" "),
                tags.map(|x| truncate_end(10, x, label("tag", "…"))).join(" "),
                truncate_end(24, description.first_line(), label("description", "…")),
                if(diff.files().len() > 0, diff.files().len() ++ label("diff files len", "m")),
                if(diff.stat().total_added() > 0, label("diff stat total_added", "+") ++ diff.stat().total_added()),
                if(diff.stat().total_removed() > 0, label("diff stat total_removed", "-") ++ diff.stat().total_removed()),
                label("conflict", if(conflict, "conflict")),
                label("divergent", if(divergent, "divergent")),
                label("hidden", if(hidden, "hidden")),
              )
            '';
          };
        };
      };
    };

    xdg.configFile."git/ignore".text = ''
      .jj
      *.scratch.*
    '';

    xdg.configFile."jjui/config.toml".source = (pkgs.formats.toml { }).generate "jjui-config" {
      preview.extra_args = [
        "--config"
        ''merge-tools.difft.diff-args=["--color=always", "--display=inline", "$left", "$right"]''
      ];
    };

    home.file.".ssh/allowed_signers".text =
      "* ${builtins.readFile ../../../home/stefan/keys/id_ed25519_git.pub}";
  };
}
