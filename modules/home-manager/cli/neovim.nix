# Requires cloning nvim config manually
# jj git clone --colocate git@github.com:stefanboca/nvim.git ~/.config/nvim

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
        require("my.config.lazy");
      '';

      extraPackages = with pkgs; [
        nodejs
        tree-sitter

        harper

        # cmake
        cmake-lint
        neocmakelsp

        # python
        basedpyright
        ruff
        python313Packages.debugpy

        # nix
        nil
        nixfmt-rfc-style
        statix

        # shell
        shfmt
        bash-language-server
        fish-lsp

        # web
        biome
        prettierd
        svelte-language-server
        tailwindcss-language-server
        vscode-langservers-extracted # vscode-{css, eslint, html, json, markdown}-language-server
        vtsls

        # rust
        # NOTE: rust-analyzer is managed by fenix
        graphviz # for crate graph visualtization

        # docker
        docker-language-server
        hadolint

        # java
        jdt-language-server

        # just
        just-lsp

        # lua
        emmylua_ls
        lua-language-server
        stylua

        # markdown
        markdownlint-cli2
        marksman

        # toml
        taplo

        # typst
        typstyle
        tinymist

        # yaml
        yaml-language-server

        # zig
        zls
      ];

      extraWrapperArgs = [
        # codelldb for rust
        "--suffix"
        "PATH"
        ":"
        "${pkgs.vscode-extensions.vadimcn.vscode-lldb}/share/vscode/extensions/vadimcn.vscode-lldb/adapter"
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
