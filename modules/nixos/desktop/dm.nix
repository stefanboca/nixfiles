{ config, lib, ... }:

let
  cfg = config.desktop;
in
{
  options.desktop = {
    dm = lib.mkOption {
      type = lib.types.enum [
        "sddm"
        "gdm"
        "cosmic-greeter"
      ];
      default = "sddm";
      description = "The display manager to use.";
    };
  };

  config = lib.mkIf cfg.enable {
    services = {
      displayManager = {
        cosmic-greeter.enable = lib.mkIf (cfg.dm == "cosmic-greeter") true;
        sddm = lib.mkIf (cfg.dm == "sddm") {
          enable = true;
          wayland.enable = true;
        };

        gdm = lib.mkIf (cfg.dm == "gdm") {
          enable = true;
          wayland = true;
        };
      };
    };
  };
}
