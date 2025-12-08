{
  config,
  lib,
  pkgs,
  ...
}: let
  inherit (lib.modules) mkIf;
  inherit (lib.options) mkEnableOption;

  cfg = config.presets.programs.cli;
in {
  options.presets.programs.cli = {
    enable = mkEnableOption "cli preset";
  };

  config = mkIf cfg.enable {
    environment.sessionVariables = {
      LESS = "-FRXS";
    };

    packages = with pkgs; [
      # keep-sorted start
      ast-grep # syntax-aware structural grep
      bencher # benchmark isolation tool
      binsider # ELF analysis tool
      bluetui # TUI for managing bluetooth devices
      bottom
      btop
      diskus # faster du -sh
      dua # disk usage analyzer
      duf # better df
      dust # better du
      eza
      fastfetch # system info (I use nixos btw)
      fd
      glow # render markdown in the terminal
      hexyl # cli hex viewer
      hwatch # better watch
      hyperfine # cli benchmarking tool
      jq
      just # command runner
      kondo # clean build dependencies and artifacts
      nix-diff # explain why two nix derivations differ
      nix-inspect # TUI for inspecting nix configs and other expressions
      nix-tree # browse dependency graphs of nix derivations
      numbat
      procs # better ps
      ripgrep
      rnr # batch rename files and directories
      scc # count lines of code
      sd # better sed
      typos # source code spell checker
      units # unit conversion tool
      watchexec # execute commands in response to file modifications
      wl-clipboard # cli clipboard utils
      xdg-ninja # check for unwanted files and directories in $HOME
      xh # cli http client
      # keep-sorted end
    ];

    rum.programs = {
      bat.enable = true;
      fzf = {
        enable = true;
        defaultOpts = ["--cycle" "--layout=reverse" "--border" "--height=-3" "--preview-window=wrap" "--highlight-line" "--info=inline-right" "--ansi"];
      };
      tealdeer = {
        enable = true;
        settings = {
          updates.auto_update = true;
        };
      };
    };
  };
}
