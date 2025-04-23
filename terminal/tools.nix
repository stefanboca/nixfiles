{
  config,
  pkgs,
  ...
}:

{
  home.packages = [
    pkgs.procs # better ps
    pkgs.sd # better sed
    pkgs.dust # better du

    pkgs.binsider # ELF analysis tool
    pkgs.cargo-machete
    pkgs.cargo-udeps
    pkgs.cargo-cache
    pkgs.cargo-nextest
    pkgs.cargo-wizard
    pkgs.cargo-watch
    pkgs.hexyl
    pkgs.hwatch
    pkgs.kondo
    pkgs.lazyjj
    pkgs.ra-multiplex
    pkgs.typst
    pkgs.typos
    pkgs.watchexec
    pkgs.xh
    pkgs.rnr
    # pkgs.watchman # for jj

    pkgs.scc

    pkgs.ast-grep # syntax-aware structural grep
    pkgs.difftastic # syntax-aware structural diff tool
    pkgs.mergiraf # syntax-aware structural merge driver
    pkgs.just # command runner

    pkgs.devenv
    pkgs.zizmor # github actions static analysis tool
    # languages
    (pkgs.fenix.complete.withComponents [
      "cargo"
      "clippy"
      "rust-src"
      "rustc"
      "rustfmt"
      "rust-analyzer"
    ])
    pkgs.zig
  ];

  programs = {
    git = {
      enable = true;
      lfs.enable = true;
      userName = "Stefan Boca";
      userEmail = "stefan.r.boca@gmail.com";
      signing = {
        signByDefault = true;
        format = "ssh";
        key = "~/.ssh/id_ed25519.pub"; # TODO: nixify
      };
      extraConfig = {
        gpg = {
          ssh = {
            allowedSignersFile = "~/.config/git/allowed_signers"; # TODO: nixify
          };
        };
        init = {
          defautlBranch = "main";
        };
        pull = {
          rebase = true;
        };
      };
    };
    gh.enable = true; # github CLI
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

  xdg.configFile = {
    "git/ignore".text = ''
      .jj
      *.scratch.*
    '';
    "git/allowed_signers".text =
      ''stefan.r.boca@gmail.com ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIC9wCJxy/++oRXAekKU/R6byETPBBOOfHpaoYje3r+Ci doctorwho@pc-doctorwho-ux8402'';
    "jj/config.toml".source = ./jj.toml; # TODO: consider making symlink with mkOutOfStoreSymlink
    "cargo/config.toml".text = ''
      [net]
      git-fetch-with-cli = true
    '';
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
