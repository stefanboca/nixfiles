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
