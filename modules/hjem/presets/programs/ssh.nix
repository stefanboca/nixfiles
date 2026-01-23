{
  config,
  lib,
  ...
}: let
  inherit (lib.modules) mkAfter mkBefore mkIf mkMerge;
  inherit (lib.options) mkEnableOption;

  cfg = config.presets.programs.ssh;
in {
  options.presets.programs.ssh = {
    enable = mkEnableOption "ssh preset";
  };

  config = mkIf cfg.enable {
    rum.programs.ssh = {
      enable = true;
      settings = mkMerge [
        (mkBefore
          # ssh_config
          ''Include config.d/*'')
        (mkAfter
          # ssh_config
          ''
            Host *
              # keep-sorted start
              AddKeysToAgent yes
              BatchMode no
              CheckHostIp yes
              ControlPath ~/.ssh/control-%r@%h:%p
              ControlPersist 3s
              ForwardAgent no
              IdentitiesOnly yes
              KbdInteractiveAuthentication no
              PasswordAuthentication no
              PubkeyAuthentication no
              StrictHostKeyChecking ask
              UpdateHostKeys yes
              VisualHostKey yes
              # keep-sorted end
          '')
      ];
    };
  };
}
