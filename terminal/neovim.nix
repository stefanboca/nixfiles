# Requires cloning nvim config manually
# jj git clone --colocate git@github.com:stefanboca/nvim.git ~/.config/nvim

{
  config,
  pkgs,
  inputs,
  ...
}:

{
  home.sessionVariables = {
    SUDO_EDITOR = config.programs.neovim.package; # TODO: why doesn't this work?
    VISUAL = "nvim";
  };

  # TODO: set theme

  programs.neovim = {
    enable = true;
    defaultEditor = true;
    package = inputs.neovim-nightly-overlay.packages.${pkgs.system}.default;

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

      # lua
      pkgs.stylua
      pkgs.lua-language-server
      inputs.emmylua-analyzer-rust.packages.${pkgs.system}.emmylua_ls

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
      font =
        let
          inherit (config.stylix) fonts;
        in
        {
          normal = [ { family = fonts.monospace.name; } ];
          size = fonts.sizes.terminal;
          features = (
            if fonts.monospace.name == "Lilex" then
              {
                Lilex = [
                  "+cv09"
                  "+cv10"
                  "+cv11"
                  "+ss01"
                  "+ss03"
                ];
              }
            else
              { }
          );
        };
    };
  };
}
