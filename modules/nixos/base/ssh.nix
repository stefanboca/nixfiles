{
  config,
  lib,
  ...
}:

let
  cfg = config.base;
in
{
  config = lib.mkIf cfg.enable {
    services.openssh = {
      enable = true; # enable to generate keys
      hostKeys = [
        {
          path = "/etc/ssh/ssh_host_ed25519_key";
          type = "ed25519";
        }
        {
          path = "/etc/ssh/ssh_host_rsa_key";
          type = "rsa";
          bits = 4096;
        }
      ];
    };

    systemd.services.sshd = {
      enable = lib.mkDefault false; # disable the unit
      masked = lib.mkDefault true; # prevent accidental starts
    };
  };
}
