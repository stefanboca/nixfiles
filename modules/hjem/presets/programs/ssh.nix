{
  config,
  lib,
  ...
}: let
  inherit (lib.modules) mkIf;
  inherit (lib.options) mkEnableOption;

  cfg = config.presets.programs.ssh;
in {
  options.presets.programs.ssh = {
    enable = mkEnableOption "ssh preset";
  };

  config = mkIf cfg.enable {
    rum.programs.ssh = {
      enable = true;
      settings =
        # ssh_config
        ''
          Host *
            ForwardAgent no
            AddKeysToAgent no
            UserKnownHostsFile ~/.ssh/known_hosts
            ControlPath ~/.ssh/master-%r@%n:%p
            IdentityFile ${../../../../home/stefan/keys/id_ed25519.pub}
            ControlPersist no
        '';
    };
  };
}
