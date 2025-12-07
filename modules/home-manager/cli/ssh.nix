{
  config,
  lib,
  modulesPath,
  ...
}: let
  inherit (lib) mkIf;
  cfg = config.cli;
in {
  imports = [
    (modulesPath + "/programs/ssh.nix")
  ];

  config = mkIf cfg.enable {
    # ensure public keys are present
    home.file = {
      ".ssh/id_ed25519.pub".source = ../../../home/stefan/keys/id_ed25519.pub;
      ".ssh/id_ed25519_git.pub".source = ../../../home/stefan/keys/id_ed25519_git.pub;
    };

    programs.ssh = {
      enable = true;
      enableDefaultConfig = false;
      matchBlocks = {
        "*" = {
          forwardAgent = lib.mkDefault false;
          addKeysToAgent = lib.mkDefault "no";
          userKnownHostsFile = lib.mkDefault "~/.ssh/known_hosts";
          controlPath = lib.mkDefault "~/.ssh/master-%r@%n:%p";
          controlPersist = lib.mkDefault "no";
        };
      };
    };
  };
}
