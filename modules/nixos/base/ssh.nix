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
      enable = true; # enable to generate ssh keys
      startWhenNeeded = true;
      openFirewall = false;
    };

    # disable sshd
    systemd.sockets.sshd = {
      enable = lib.mkForce false;
      wantedBy = lib.mkForce [ ];
    };
  };
}
