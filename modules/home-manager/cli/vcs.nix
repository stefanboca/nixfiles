{
  config,
  lib,
  modulesPath,
  pkgs,
  ...
}: let
  cfg = config.cli;

  name = "Stefan Boca";
  email = "stefan.r.boca@gmail.com";
  key = "~/.ssh/id_ed25519_git.pub";
in {
  imports = [
    "${modulesPath}/programs/gh.nix"
    "${modulesPath}/programs/git.nix"
    "${modulesPath}/programs/jjui.nix"
    "${modulesPath}/programs/jujutsu.nix"

    # dependencies of git.nix
    "${modulesPath}/programs/delta.nix"
    "${modulesPath}/programs/diff-highlight.nix"
    "${modulesPath}/programs/diff-so-fancy.nix"
    "${modulesPath}/programs/difftastic.nix"
    "${modulesPath}/programs/patdiff.nix"
    "${modulesPath}/programs/riff.nix"

    # dependency of jujutsu.nix
    "${modulesPath}/programs/emacs.nix"
  ];

  config = lib.mkIf cfg.enable {
    home.packages = with pkgs; [
      difftastic # syntax-aware structural diff tool
      jjui # TUI for jujutsu
      mergiraf # syntax-aware structural merge driver
      meld # Visual diff and merge tool
      watchman
    ];

    programs = {
      gh.enable = true; # github CLI

      git = {
        enable = true;
        lfs.enable = true;
        settings = {
          gpg.ssh.allowedSignersFile = "~/.ssh/allowed_signers";
          init.defautlBranch = "main";
          pull.rebase = true;
          url."ssh://git@github.com" = {insteadOf = "https://github.com";};
          user = {inherit name email;};
        };
        signing = {
          inherit key;
          signByDefault = true;
          format = "ssh";
        };
      };

      # better git
      jujutsu = {
        enable = true;

        settings = {
          user = {inherit name email;};

          ui = {
            default-command = "log";
            diff-editor = "nvim";
            diff-formatter = "difft";
            editor = ["nvim"];
            log-word-wrap = true;
            merge-editor = "nvim";
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
            nvim = {
              program = "nvim";
              edit-args = ["-c" "DiffEditor $left $right $output"];
              merge-args = ["-c" "let g:jj_diffconflicts_marker_length=$marker_length" "-c" "let g:autoformat_disable=v:true" "-c" "JJDiffConflicts!" "$output" "$base" "$left" "$right"];
              merge-tool-edits-conflict-markers = true;
            };
          };

          signing = {
            inherit key;
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

    xdg.configFile."git/ignore".text = ''
      .jj
      *.scratch.*
    '';

    home.file.".ssh/allowed_signers".text = "* ${builtins.readFile ../../../home/stefan/keys/id_ed25519_git.pub}";
  };
}
