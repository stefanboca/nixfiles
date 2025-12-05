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
      source = pkgs.writeTextFile {
        name = "ssh-config";
        text = cfg.settings;
        checkPhase = ''
          ${getExe pkgs.openssh} -G -F "$target" dummyhost
        '';
      };
    };
  };
}
