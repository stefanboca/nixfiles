{
  config,
  lib,
  pkgs,
  ...
}: let
  inherit (lib.modules) mkIf;
  inherit (lib.options) mkEnableOption;

  cfg = config.presets.programs.vesktop;
in {
  options.presets.programs.vesktop = {
    enable = mkEnableOption "vesktop preset";
  };

  config.rum.programs.vesktop = mkIf cfg.enable {
    enable = true;
    package = pkgs.vesktop.override {
      withMiddleClickScroll = true;
      withSystemVencord = true;
    };
  };
}
