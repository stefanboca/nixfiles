{
  config,
  lib,
  pkgs,
  ...
}: let
  inherit (lib.modules) mkIf;
  inherit (lib.options) mkEnableOption mkOption;
  inherit (lib.types) path singleLinStr;

  allowedSignersFile = pkgs.writeText "allowed_signers" ''
    ${cfg.email} ${builtins.readFile cfg.signingKeyFile}
  '';

  cfg = config.presets.programs.vcs;
in {
  options.presets.programs.vcs = {
    enable = mkEnableOption "vcs preset";

    name = mkOption {
      type = singleLinStr;
      default = "stefan";
    };

    email = mkOption {
      type = singleLinStr;
      default = "stefan.r.boca@gmail.com";
    };

    signingKeyFile = mkOption {
      type = path;
      default = ../../../../home/stefan/keys/id_ed25519_git.pub;
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

    rum.programs = {
      gh.enable = true;

      git = {
        enable = true;
        ignores = [".jj" "*.scratch.*"];
        settings = {
          user = {
            inherit (cfg) name email;
            signingKey = cfg.signingKeyFile;
          };
          init.defautlBranch = "main";
          pull.rebase = true;

          url."ssh://git@github.com" = {insteadOf = "https://github.com";};

          gpg = {
            format = "ssh";
            ssh = {
              program = lib.getExe' pkgs.openssh "ssh-keygen";
              inherit allowedSignersFile;
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
            key = cfg.signingKeyFile;
            behavior = "own";
            backend = "ssh";
            backends.ssh.allowed-signers = allowedSignersFile;
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
