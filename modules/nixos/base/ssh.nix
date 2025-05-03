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
      hostKeys = [
        {
          path = "/etc/ssh/ssh_host_ed25519_key";
          type = "ed25519";
        }
      ];
    };
  };
}
