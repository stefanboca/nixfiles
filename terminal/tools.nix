{ config, pkgs, ... }:

{
  home.packages = [
    pkgs.procs # better ps
    pkgs.sd # better sed
    pkgs.dust # better du

    pkgs.difftastic # structural diff tool
    pkgs.just # command runner

    pkgs.devenv
    pkgs.zizmor # github actions static analysis tool
    # languages
    pkgs.zig
  ];

  programs = {
    # git.enable = true;
    # gh.enable = true; # github CLI
    jujutsu.enable = true;

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
      # tokyonight-moon
      # TODO: refactor color schemes
      colors = {
        bg = "#1e2030";
        "bg+" = "#2d3f76";
        border = "#589ed7";
        fg = "#c8d3f5";
        gutter = "#1e2030";
        header = "#ff966c";
        hl = "#65bcff";
        "hl+" = "#65bcff";
        info = "#545c7e";
        marker = "#ff007c";
        pointer = "#ff007c";
        prompt = "#65bcff";
        query = "#c8d3f5:regular";
        scrollbar = "#589ed7";
        separator = "#ff966c";
        spinner = "#ff007c";
      };
    };

    bottom.enable = true; # system monitor
    ripgrep.enable = true; # better grep
    bat.enable = true; # better cat
    fd.enable = true; # better find
    eza.enable = true; # better ls
    zoxide.enable = true; # better cd
    jq.enable = true; # transform json
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

    # languages
    uv.enable = true;
    go = {
      enable = true;
      goPath = "${config.xdg.dataHome}/go";
    };
  };

  # make stuff xdg compliant
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
}
