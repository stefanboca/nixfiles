{
  config,
  inputs,
  pkgs,
  ...
}:

{
  imports = [ ./terminal ];
  home.username = "doctorwho";
  home.homeDirectory = "/home/doctorwho";
  home.preferXdgDirectories = true;
  home.stateVersion = "25.05";

  fonts.fontconfig.enable = true;
  nixGL.packages = inputs.nixgl.packages;
  programs.home-manager.enable = true;

  home.packages = [
    pkgs.lilex

    pkgs.zig

    pkgs.procs

    pkgs.difftastic
    pkgs.devenv
    pkgs.just
    pkgs.dust
    pkgs.zizmor
  ];

  programs = {
    bottom.enable = true;

    # git.enable = true;
    # gh.enable = true;
    jujutsu.enable = true;

    bat.enable = true;
    fd.enable = true;
    jq.enable = true;
    ripgrep.enable = true;
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

    eza.enable = true;
    zoxide.enable = true;

    tealdeer.enable = true;
  };
}
