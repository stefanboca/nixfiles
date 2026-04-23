{
  config,
  lib,
  pkgs,
  ...
}: let
  inherit (builtins) readFile;
  inherit (lib.meta) getExe getExe';
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
      pkgs.difftastic
      pkgs.git-lfs
      pkgs.meld
      pkgs.mergiraf
      pkgs.watchman
    ];

    files.".ssh/allowed_signers".text = ''
      ${cfg.email} ${signingKey}
    '';

    rum.programs = {
      gh = {
        enable = true;
        settings = {
          telemetry = "disabled";
        };
      };

      git = {
        enable = true;
        package = pkgs.gitFull;
        ignore =
          # gitignore
          ''
            *.scratch
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

          credential.helper = [
            (getExe' config.rum.programs.git.package "git-credential-libsecret")
            (getExe pkgs.git-credential-oauth)
          ];

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
            default-command = "status";
            diff-editor = "snv";
            diff-formatter = "difft";
            editor = "snv";
            log-word-wrap = true;
            merge-editor = "snv";
          };

          aliases = {
            d = ["diff"];
            l = ["log"];
            n = ["new"];
            rb = ["rebase"];
            s = ["show"];

            g = ["git"];
            gc = ["git" "clone"];
            gf = ["git" "fetch"];
            gp = ["git" "push"];
            gr = ["git" "remote"];
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
            behavior = "drop";
            backend = "ssh";
            backends.ssh.allowed-signers = "~/.ssh/allowed_signers";
          };

          git = {
            sign-on-push = true;
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

          revsets = {
            bookmark-advance-to = "@-";
          };

          templates = {
            git_push_bookmark = ''"sb/push-" ++ change_id.short()'';
            draft_commit_description = "builtin_draft_commit_description_with_diff";
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
