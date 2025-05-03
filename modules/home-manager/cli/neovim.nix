# Requires cloning nvim config manually
# jj git clone --colocate git@github.com:stefanboca/nvim.git ~/.config/nvim

{
  config,
  inputs,
  lib,
  pkgs,
  ...
}:

let
  cfg = config.cli;
in
{
  config = lib.mkIf cfg.enable {
    home.sessionVariables = {
      # SUDO_EDITOR = "${config.programs.neovim.package}/bin/nvim"; # TODO: set EDITOR globally
      VISUAL = "nvim";
    };

    programs.neovim = {
      enable = true;
      defaultEditor = true;
      package = pkgs.neovim-nightly;

      extraLuaConfig = ''
        vim.loader.enable()
        require("config.lazy");
      '';

      extraPackages = [
        pkgs.harper

        # python
        pkgs.basedpyright
        pkgs.ruff
        pkgs.python313Packages.debugpy

        # nix
        pkgs.nil
        pkgs.nixfmt-rfc-style

        # shell
        pkgs.shfmt
        pkgs.bash-language-server
        pkgs.fish-lsp

        # web
        pkgs.biome
        pkgs.prettierd
        pkgs.svelte-language-server
        pkgs.tailwindcss-language-server
        pkgs.vscode-langservers-extracted # vscode-{css, eslint, html, json, markdown}-language-server
        pkgs.vtsls

        # rust
        # NOTE: rust-analyzer is managed by fenix
        pkgs.graphviz # for crate graph visualtization
        # pkgs.codelldb # TODO: how to get

        # docker
        pkgs.docker-compose-language-service
        pkgs.docker-language-server
        pkgs.hadolint

        # java
        pkgs.jdt-language-server

        # just
        pkgs.just-lsp

        # lua
        pkgs.emmylua_ls
        pkgs.lua-language-server
        pkgs.stylua

        # markdown
        pkgs.markdownlint-cli2
        pkgs.marksman

        # toml
        pkgs.taplo

        # typst
        pkgs.typstyle
        pkgs.tinymist

        # yaml
        pkgs.yaml-language-server

        # zig
        pkgs.zls
      ];
    };

    programs.neovide = {
      enable = true;
      settings = {
        fork = true;
        frame = "none";
        title-hidden = true;
      };
    };
  };
}
