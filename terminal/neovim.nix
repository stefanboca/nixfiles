{
  config,
  pkgs,
  inputs,
  ...
}:

{
  home.sessionVariables = {
    SUDO_EDITOR = config.programs.neovim.package;
    VISUAL = "nvim";
  };

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

      # web
      pkgs.biome

      # pkgs.prettier
      pkgs.svelte-language-server
      pkgs.tailwindcss-language-server
      pkgs.vscode-langservers-extracted # vscode-{css, eslint, html, json, markdown}-language-server
      pkgs.vtsls

      # rust
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
      font = {
        normal = [ { family = "lilex"; } ];
        size = 10;
        features = {
          Lilex = [
            "+cv09"
            "+cv10"
            "+cv11"
            "+ss01"
            "+ss03"
          ];
        };
      };
    };
  };
}
