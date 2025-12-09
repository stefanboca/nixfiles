{
  config,
  lib,
  ...
}: let
  inherit (lib.modules) mkAfter mkIf;
  inherit (lib.options) mkEnableOption mkOption;
  inherit (lib.strings) optionalString;
  inherit (lib.types) nullOr oneOf path str;

  cfg = config.presets.programs.ssh;
in {
  options.presets.programs.ssh = {
    enable = mkEnableOption "ssh preset";

    identityFile = mkOption {
      type = nullOr (oneOf [path str]);
      default = null;
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
            ControlPersist no
            ${optionalString (cfg.identityFile != null) "IdentityFile ${cfg.identityFile}"}
        '';
    };
  };
}
