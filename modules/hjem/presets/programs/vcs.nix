{
  config,
  lib,
  pkgs,
  ...
}: let
  inherit (builtins) readFile;
  inherit (lib.modules) mkIf;
  inherit (lib.strings) trim;
  inherit (lib.options) mkEnableOption mkOption;
  inherit (lib.types) singleLineStr path;

  signingKey = trim (readFile cfg.signingKeyFile);

  cfg = config.presets.programs.vcs;
in {
  options.presets.programs.vcs = {
    enable = mkEnableOption "vcs preset";

    name = mkOption {
      type = singleLineStr;
      default = "stefan";
    };

    email = mkOption {
      type = singleLineStr;
      default = "stefan.r.boca@gmail.com";
    };

    signingKeyFile = mkOption {
      type = path;
    };
  };

  config = mkIf cfg.enable {
    packages = [
      pkgs.git-lfs
      pkgs.difftastic
      pkgs.mergiraf
      pkgs.meld
      pkgs.watchman
    ];

    files.".ssh/allowed_signers".text = ''
      ${cfg.email} ${signingKey}
    '';

    rum.programs = {
      gh = {
        enable = true;
        integrations.git.credentialHelper.enable = true;
      };

      git = {
        enable = true;
        ignore =
          # gitignore
          ''
            *.scratch.*
          '';
        settings = {
          user = {
            inherit (cfg) name email;
            inherit signingKey;
          };
          init.defaultBranch = "main";
          pull.rebase = true;

          gpg = {
            format = "ssh";
            ssh = {
              program = lib.getExe' pkgs.openssh "ssh-keygen";
              allowedSignersFile = "~/.ssh/allowed_signers";
            };
          };
          commit.gpgSign = true;
          tag.gpgSign = true;

          filter.lfs = {
            required = true;
            clean = "git-lfs clean -- %f";
            process = "git-lfs filter-process";
            smudge = "git-lfs smudge -- %f";
          };
        };
      };

      jujutsu = {
        enable = true;

        settings = {
          user = {inherit (cfg) name email;};

          ui = {
            default-command = "log";
            diff-editor = "snv";
            diff-formatter = "difft";
            editor = "snv";
            log-word-wrap = true;
            merge-editor = "snv";
          };

          aliases = {
            tug = ["bookmark" "move" "--from" "closest_bookmark(@-)" "--to" "@-"];

            cm = ["commit"];
            d = ["diff"];
            n = ["new"];
            rb = ["rebase"];
            s = ["show"];

            g = ["git"];
            gc = ["git" "clone"];
            gf = ["git" "fetch"];
            gp = ["git" "push"];
            gr = ["git" "remote"];

            clone = ["git" "clone"];
            fetch = ["git" "fetch"];
            push = ["git" "push"];

            c = ["log" "-r" "current_branch()"];
            a = ["log" "-r" "all()"];
          };

          revset-aliases = {
            "current_branch()" = "ancestors(immutable_heads()..@, 2)";
            "closest_bookmark(to)" = "heads(::to & bookmarks())";
          };

          merge-tools = {
            snv = {
              program = "snv";
              edit-args = ["-c" "DiffEditor $left $right $output"];
              merge-args = ["-c" "let g:jj_diffconflicts_marker_length=$marker_length" "-c" "let g:autoformat_disable=v:true" "-c" "JJDiffConflicts!" "$output" "$base" "$left" "$right"];
              merge-tool-edits-conflict-markers = true;
            };
          };

          signing = {
            key = signingKey;
            behavior = "own";
            backend = "ssh";
            backends.ssh.allowed-signers = "~/.ssh/allowed_signers";
          };

          git = {
            private-commits = "description(glob:'wip:*') | description(glob:'private:*') | description(glob:'priv:*')";
          };

          colors = {
            description = "cyan";
            divergent = "magenta";
            hidden = "yellow";
            "diff files len" = "yellow";
            "diff stat total_added" = "green";
            "diff stat total_removed" = "red";
          };

          templates.git_push_bookmark = ''"sb/push-" ++ change_id.short()'';

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

          fsmonitor = {
            backend = "watchman";
            watchman.register-snapshot-trigger = true;
          };
        };
      };

      jjui = {
        enable = true;
        settings = {
          preview = let
            args = ["--color" "always" "--config" ''merge-tools.difft.diff-args=["--color=always", "--width=$width", "--display=inline", "$left", "$right"]'' "-r" "$change_id"];
          in {
            revision_command = ["show"] ++ args;
            file_command = ["diff"] ++ args ++ ["$file"];
          };
        };
      };
    };
  };
}
