{
  config,
  lib,
  pkgs,
  ...
}: let
  inherit (lib.meta) getExe;
  inherit (lib.modules) mkIf;
  inherit (lib.options) mkEnableOption mkOption;
  inherit (lib.strings) toInt;
  inherit (lib.types) lines;

  source = pkgs.writeText "ssh-config" cfg.settings;

  validate = pkgs.runCommandLocal "ssh-validate" {} ''
    mkdir -p $out

    set +e
    ${getExe pkgs.openssh} -G -F ${source} dummyhost > $out/stdout 2>&1
    exitcode=$?
    set -e

    echo $exitcode > $out/exitcode
  '';

  validateStdout = builtins.readFile "${validate}/stdout";
  validateExitCode = toInt (builtins.readFile "${validate}/exitcode");
  isValid = validateExitCode == 0;

  cfg = config.rum.programs.ssh;
in {
  options.rum.programs.ssh = {
    enable = mkEnableOption "ssh";

    settings = mkOption {
      type = lines;
      default = "";
    };

    validate.enable = mkEnableOption "validate ssh config" // {default = true;};
  };

  config = mkIf cfg.enable {
    files.".ssh/config" = mkIf (cfg.settings != "") {
      text = cfg.settings;
    };

    assertions = [
      (mkIf cfg.validate.enable {
        assertion = isValid;
        message = ''
          SSH config is invalid:

          ${validateStdout}
        '';
      })
    ];
  };
}
