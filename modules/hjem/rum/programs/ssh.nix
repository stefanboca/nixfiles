{
  config,
  lib,
  pkgs,
  ...
}: let
  inherit (lib.meta) getExe;
  inherit (lib.modules) mkIf;
  inherit (lib.options) mkEnableOption mkOption;
  inherit (lib.types) lines;

  validatedConfig =
    pkgs.runCommandWith {
      name = "ssh-config";
      runLocal = true;
      derivationArgs = {
        config = cfg.settings;
        passAsFile = ["config"];
      };
    }
    # bash
    ''
      ${getExe pkgs.openssh} -G -F $configPath dummyhost
      cp $configPath $out
    '';

  cfg = config.rum.programs.ssh;
in {
  options.rum.programs.ssh = {
    enable = mkEnableOption "ssh";

    settings = mkOption {
      type = lines;
      default = "";
    };
  };

  config = mkIf cfg.enable {
    files.".ssh/config" = mkIf (cfg.settings != "") {
      source = validatedConfig;
    };
  };
}
