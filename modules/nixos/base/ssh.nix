{
  config,
  lib,
  ...
}: let
  cfg = config.base;
in {
  config = lib.mkIf cfg.enable {
    services.openssh.generateHostKeys = true;
  };
}
