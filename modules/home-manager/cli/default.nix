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
    ./vcs.nix
  ];

  options.cli = {
    enable = lib.mkEnableOption "Enable CLI configuration";
  };

  config = lib.mkIf cfg.enable {
    home.packages = [
      pkgs.ast-grep # syntax-aware structural grep
      pkgs.binsider # ELF analysis tool
      pkgs.devenv # developer environments
      pkgs.diskus # faster du -sh
      pkgs.duf # better df
      pkgs.dust # better du
      pkgs.glow # render markdown in the terminal
      pkgs.hexyl # cli hex viewer
      pkgs.hwatch # better watch
      pkgs.hyperfine # cli benchmarking tool
      pkgs.just # command runner
      pkgs.kondo # clean build dependencies and artifacts
      pkgs.nix-tree # browse dependency graphs of nix derivations
      pkgs.procs # better ps
      pkgs.rnr # batch rename files and directories
      pkgs.scc # count lines of code
      pkgs.sd # better sed
      pkgs.typos # source code spell checker
      pkgs.watchexec # execute commands in response to file modifications
      pkgs.xdg-ninja # check for unwanted files and directories in $HOME
      pkgs.xh # cli http client
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
      ripgrep.enable = true; # better grep
      # cheatsheets for shell commands
      tealdeer = {
        enable = true;
        enableAutoUpdates = false; # disable systemd auto-update service
        settings = {
          update = {
            auto_update = true; # enable auto-update upon running command
          };
        };
      };
    };

    home.sessionVariables =
      let
        inherit (config.xdg)
          cacheHome
          configHome
          dataHome
          stateHome
          ;
      in
      {
        LESS = "-FRXS";

        # make stuff xdg compliant
        CUDA_CACHE_PATH = "${cacheHome}/nv";
        GNUPGHOME = "${dataHome}/gnupg";
        NPM_CONFIG_PREFIX = "${dataHome}/npm";
        NPM_CONFIG_CACHE = "${cacheHome}/npm";
        CARGO_HOME = "${configHome}/cargo";
        RUSTUP_HOME = "${dataHome}/rust";
        PYTHON_HISTORY = "${stateHome}/python_history";
        SQLITE_HISTORY = "${stateHome}/sqlite_history";
        HISTFILE = "${stateHome}/bash_history";
      };
  };
}
