# Requires cloning nvim config manually
# jj git clone git@github.com:stefanboca/nvim.git ~/.config/nvim
{
  config,
  lib,
  modulesPath,
  pkgs,
  ...
}: let
  cfg = config.cli;
in {
  imports = [
    "${modulesPath}/programs/neovide.nix"
    "${modulesPath}/programs/neovim.nix"
  ];

  config = lib.mkIf cfg.enable {
    home.sessionVariables = {
      VISUAL = "nvim";
    };

    programs.neovim = {
      enable = true;
      defaultEditor = true;
      package = pkgs.neovim-nightly;

      extraPackages = with pkgs; [
        wl-clipboard
        inotify-tools
        # treesitter
        nodejs
        tree-sitter
        gcc
        ts_query_ls

        harper

        # c/cpp
        clang-tools

        # cmake
        cmake-lint
        neocmakelsp

        # glsl
        glsl_analyzer

        # lean
        lean4

        # koto
        koto-ls

        # python
        basedpyright
        ruff
        python313Packages.debugpy

        # nix
        alejandra
        deadnix
        nil
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
        dockerfmt
        hadolint

        # java
        jdt-language-server

        # just
        just-lsp

        # lua
        emmylua-ls
        lua-language-server
        stylua

        # markdown
        markdownlint-cli2
        marksman

        # toml
        taplo
        tombi

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
        # for snacks frecency db
        "--suffix"
        "LD_LIBRARY_PATH"
        ":"
        (lib.makeLibraryPath [pkgs.sqlite])
      ];

      withNodeJs = false;
      withPython3 = false;
      withRuby = false;
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
