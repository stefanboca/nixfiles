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
      pkgs.mergiraf # syntax-aware structural merge driver
      pkgs.lazyjj # TUI for jujutsu
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
      jujutsu.enable = true; # better git
    };

    xdg.configFile = {
      "git/ignore".text = ''
        .jj
        *.scratch.*
      '';
      "git/allowed_signers".text =
        ''stefan.r.boca@gmail.com ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIC9wCJxy/++oRXAekKU/R6byETPBBOOfHpaoYje3r+Ci doctorwho@pc-doctorwho-ux8402'';
      "jj/config.toml".source = ./jj.toml; # TODO: port to nix?
    };
  };
}
