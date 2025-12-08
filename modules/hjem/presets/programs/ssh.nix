{
  config,
  lib,
  ...
}: let
  inherit (lib.modules) mkAfter mkIf;
  inherit (lib.options) mkEnableOption mkOption;
  inherit (lib.types) path;

  cfg = config.presets.programs.ssh;
in {
  options.presets.programs.ssh = {
    enable = mkEnableOption "ssh preset";

    identityFile = mkOption {
      type = path;
    };
  };

  config = mkIf cfg.enable {
    rum.programs.ssh = {
      enable = true;
      settings =
        mkAfter
        # ssh_config
        ''
          Host *
            ForwardAgent no
            AddKeysToAgent no
            UserKnownHostsFile ~/.ssh/known_hosts
            ControlPath ~/.ssh/master-%r@%n:%p
            IdentityFile ${cfg.identityFile}
            ControlPersist no
        '';
    };
  };
}
