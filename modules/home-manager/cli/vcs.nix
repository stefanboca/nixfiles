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
    home.packages = [
      pkgs.difftastic # syntax-aware structural diff tool
      pkgs.jjui # TUI for jujutsu
      pkgs.lazyjj # TUI for jujutsu
      pkgs.mergiraf # syntax-aware structural merge driver
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
          key = "~/.ssh/id_ed25519_git.pub";
        };
        extraConfig = {
          gpg.ssh.allowedSignersFile = "~/.ssh/allowed_signers";
          init = {
            defautlBranch = "main";
          };
          pull = {
            rebase = true;
          };
        };
      };

      gh.enable = true; # github CLI
      jujutsu.enable = true; # better git
    };

    xdg.configFile = {
      "git/ignore".text = ''
        .jj
        *.scratch.*
      '';
      "jj/config.toml".source = ./jj.toml; # TODO: port to nix?
    };

    home.file.".ssh/allowed_signers".text =
      "* ${builtins.readFile ../../../home/stefan/keys/id_ed25519_git.pub}";
  };
}
