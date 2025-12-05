{
  config,
  pkgs,
  lib,
  options,
  ...
}: let
  inherit (lib.attrsets) optionalAttrs mapAttrs;
  inherit (lib.modules) literalExpression mergeEqualOption mkIf mkOptionType;
  inherit (lib.options) mkDefault mkOption;
  inherit (lib.strings) isConvertibleWithToString;
  inherit (lib.types) attrsOf lines path singleLineStr submodule;

  xdgConfigDir = config.xdg.config.directory;
  cfg = config.sops;
in {
  options.sops = {
    templates = mkOption {
      description = "Templates for secret files";
      type = attrsOf (
        submodule (
          {config, ...}: {
            options = {
              name = mkOption {
                type = singleLineStr;
                default = config._module.args.name;
                description = ''
                  Name of the file used in /run/secrets/rendered
                '';
              };
              path = mkOption {
                description = "Path where the rendered file will be placed";
                type = singleLineStr;
                default = "${xdgConfigDir}/sops-nix/secrets/rendered/${config.name}";
              };
              content = mkOption {
                type = lines;
                default = "";
                description = ''
                  Content of the file
                '';
              };
              mode = mkOption {
                type = singleLineStr;
                default = "0400";
                description = ''
                  Permissions mode of the rendered secret file in octal.
                '';
              };
              file = mkOption {
                type = path;
                default = pkgs.writeText config.name config.content;
                defaultText = literalExpression ''pkgs.writeText config.name config.content'';
                example = "./configuration-template.conf";
                description = ''
                  File used as the template. When this value is specified, `sops.templates.<name>.content` is ignored.
                '';
              };
            };
          }
        )
      );
      default = {};
    };
    placeholder = mkOption {
      type = attrsOf (
        mkOptionType {
          name = "coercibleToString";
          description = "value that can be coerced to string";
          check = isConvertibleWithToString;
          merge = mergeEqualOption;
        }
      );
      default = {};
      visible = false;
    };
  };

  config = optionalAttrs (options ? sops.secrets) (
    mkIf (cfg.templates != {}) {
      sops.placeholder = mapAttrs (name: _: mkDefault "<SOPS:${builtins.hashString "sha256" name}:PLACEHOLDER>") cfg.secrets;
    }
  );
}
