{
  config,
  lib,
  pkgs,
  ...
}: let
  inherit (lib.attrsets) genAttrs;
  inherit (lib.meta) getExe;
  inherit (lib.modules) mkIf;
  inherit (lib.options) mkEnableOption mkOption mkPackageOption;
  inherit (lib.types) listOf package str;

  yaml = pkgs.formats.yaml {};

  cfg = config.rum.programs.gh;
in {
  options.rum.programs.gh = {
    enable = mkEnableOption "gh";

    package = mkPackageOption pkgs "gh" {nullable = true;};

    settings = mkOption {
      inherit (yaml) type;
      default = {};
    };

    hosts = mkOption {
      inherit (yaml) type;
      default = {};
    };

    extensions = mkOption {
      type = listOf package;
      default = [];
    };

    integrations = {
      git.credentialHelper = {
        enable = mkEnableOption "gh integration as git credential helper";
        hosts = mkOption {
          type = listOf str;
          default = [
            "https://github.com"
            "https://gist.github.com"
          ];
        };
      };
    };
  };

  config = mkIf cfg.enable {
    packages = mkIf (cfg.package != null) [cfg.package];
    xdg.config.files = {
      "gh/config.yaml" = mkIf (cfg.settings != {}) {
        source = yaml.generate "gh-config.yaml" ({version = 1;} // cfg.settings);
      };
      "gh/hosts.yaml" = mkIf (cfg.hosts != {}) {
        source = yaml.generate "gh-hosts.yaml" cfg.settings;
      };
    };

    xdg.data.files."gh/extensions" = mkIf (cfg.extensions != []) {
      source = pkgs.linkFarm "gh-extensions" (
        map (pkg: {
          name = pkg.pname;
          path = "${pkg}/bin";
        })
        cfg.extensions
      );
    };

    rum.programs.git.settings.credential = mkIf cfg.integrations.git.credentialHelper.enable (
      genAttrs cfg.integrations.git.credentialHelper.hosts (_: {helper = "${getExe cfg.package} auth git-credential";})
    );
  };
}
