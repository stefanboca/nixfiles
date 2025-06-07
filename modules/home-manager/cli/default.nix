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
      age # encryption
      ast-grep # syntax-aware structural grep
      binsider # ELF analysis tool
      diskus # faster du -sh
      dua # disk usage analyzer
      duf # better df
      dust # better du
      glow # render markdown in the terminal
      hexyl # cli hex viewer
      hwatch # better watch
      hyperfine # cli benchmarking tool
      just # command runner
      kondo # clean build dependencies and artifacts
      nix-tree # browse dependency graphs of nix derivations
      procs # better ps
      rnr # batch rename files and directories
      scc # count lines of code
      sd # better sed
      sops # secrets manager
      typos # source code spell checker
      watchexec # execute commands in response to file modifications
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
      # TODO: move to nixos
      nh = {
        enable = true;
        flake = lib.mkDefault "${config.home.homeDirectory}/data/nixfiles";
      };
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
        CUDA_CACHE_PATH = "${cacheHome}/nv"; # TODO: make global / check if needed
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
