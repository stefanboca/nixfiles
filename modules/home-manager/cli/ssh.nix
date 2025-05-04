{ config, lib, ... }:

let
  inherit (lib) mkIf;
  cfg = config.cli;
in
{
  config = mkIf cfg.enable {
    # ensure public keys are present
    home.file = {
      ".ssh/id_ed25519.pub".source = ../../../home/stefan/keys/id_ed25519.pub;
      ".ssh/id_ed25519_git.pub".source = ../../../home/stefan/keys/id_ed25519_git.pub;
    };

    programs.ssh = {
      enable = true;
      matchBlocks = {
        "github.com" = {
          hostname = "github.com";
          user = "git";
          identityFile = "~/.ssh/id_ed25519_git";
          identitiesOnly = true;
        };
      };
      extraConfig = ''SetEnv TERM=xterm-256color'';
    };
  };
}
