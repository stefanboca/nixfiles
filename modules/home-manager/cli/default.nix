{
  config,
  lib,
  pkgs,
  ...
}:

let
  cfg = config.cli;
in
{
  imports = [
    ./fish.nix
    ./langs.nix
    ./neovim.nix
    ./ssh.nix
    ./vcs.nix
  ];

  options.cli = {
    enable = lib.mkEnableOption "Enable CLI configuration";
  };

  config = lib.mkIf cfg.enable {
    home.packages = with pkgs; [
      ast-grep # syntax-aware structural grep
      bencher # benchmark isolation tool
      binsider # ELF analysis tool
      diskus # faster du -sh
      dua # disk usage analyzer
      duf # better df
      dust # better du
      fastfetch # system info (I use nixos btw)
      glow # render markdown in the terminal
      hexyl # cli hex viewer
      hwatch # better watch
      hyperfine # cli benchmarking tool
      just # command runner
      kondo # clean build dependencies and artifacts
      nix-diff # explain why two nix derivations differ
      nix-tree # browse dependency graphs of nix derivations
      procs # better ps
      rnr # batch rename files and directories
      scc # count lines of code
      sd # better sed
      typos # source code spell checker
      units # unit conversion tool
      watchexec # execute commands in response to file modifications
      wl-clipboard # cli clipboard utils
      xdg-ninja # check for unwanted files and directories in $HOME
      xh # cli http client
    ];

    programs = {
      bat.enable = true; # better cat
      bottom.enable = true; # system monitor
      btop.enable = true; # system monitor
      eza.enable = true; # better ls
      fd.enable = true; # better find
      # fuzzy finder
      fzf = {
        enable = true;
        defaultOptions = [
          "--cycle"
          "--layout=reverse"
          "--border"
          "--height=-3"
          "--preview-window=wrap"
          "--highlight-line"
          "--info=inline-right"
          "--ansi"
        ];
      };
      jq.enable = true; # transform json
      numbat.enable = true; # scientific calculator with physical units
      ripgrep.enable = true; # better grep
      # cheatsheets for shell commands
      tealdeer = {
        enable = true;
        enableAutoUpdates = false; # disable systemd auto-update service
        settings = {
          updates = {
            auto_update = true; # enable auto-update upon running command
          };
        };
      };
    };

    home.sessionVariables =
      let
        inherit (config.xdg) cacheHome dataHome stateHome;
      in
      {
        LESS = "-FRXS";

        # make stuff xdg compliant
        CARGO_HOME = "${dataHome}/cargo";
        GNUPGHOME = "${dataHome}/gnupg";
        HISTFILE = "${stateHome}/bash_history";
        NODE_REPL_HISTORY = "${dataHome}/node_repl_history";
        NPM_CONFIG_CACHE = "${cacheHome}/npm";
        NPM_CONFIG_PREFIX = "${dataHome}/npm";
        PLATFORMIO_CORE_DIR = "${dataHome}/platformio";
        PYTHON_HISTORY = "${stateHome}/python_history";
        RUSTUP_HOME = "${dataHome}/rust";
        SQLITE_HISTORY = "${stateHome}/sqlite_history";
        WINEPREFIX = "${dataHome}/wine";
        _JAVA_OPTIONS = "-Djava.util.prefs.userRoot=${dataHome}/java";
      };
  };
}
