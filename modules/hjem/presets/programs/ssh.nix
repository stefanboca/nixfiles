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
    files = {
      ".ssh/id_ed25519.pub".source = ../../../../home/stefan/keys/id_ed25519.pub;
      ".ssh/id_ed25519_git.pub".source = ../../../../home/stefan/keys/id_ed25519_git.pub;
    };

    rum.programs.ssh = {
      enable = true;
      settings =
        # ssh_config
        ''
          Host github.com
            IdentitiesOnly yes
            User git
            HostName github.com
            IdentityFile ~/.ssh/id_ed25519_git


          Host *
            ForwardAgent no
            AddKeysToAgent no
            UserKnownHostsFile ~/.ssh/known_hosts
            ControlPath ~/.ssh/master-%r@%n:%p
            ControlPersist no
        '';
    };
  };
}
