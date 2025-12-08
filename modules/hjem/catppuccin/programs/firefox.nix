{catppuccinLib}: {
  config,
  lib,
  ...
}: let
  inherit (lib.attrsets) attrNames hasAttr mapAttrs optionalAttrs;
  inherit (lib.lists) foldl' optional;
  inherit (lib.modules) mkDefault mkIf;
  inherit (lib.options) mkOption;
  inherit (lib.types) attrsOf submodule;

  inherit (config.catppuccin) sources;

  mkProfileOptions = {enableDefault ? null}:
    catppuccinLib.mkCatppuccinOption (
      {
        name = "firefox";
        accentSupport = true;
      }
      // (optionalAttrs (enableDefault != null) {default = enableDefault;})
    );

  firefoxCfg = config.rum.programs.firefox;
  cfg = config.catppuccin.programs.firefox;
in {
  options = {
    catppuccin.programs.firefox =
      (mkProfileOptions {})
      // {
        profiles = mkOption {
          type = attrsOf (
            submodule {
              options = mkProfileOptions {
                enableDefault = cfg.enable;
              };
              config = {
                flavor = mkDefault cfg.flavor;
                accent = mkDefault cfg.accent;
              };
            }
          );
          default = mapAttrs (_: _: {}) firefoxCfg.profiles;
          defaultText = "<profiles declared in `rum.programs.firefox.profiles`>";
          description = "Catppuccin settings for Firefox profiles.";
        };
      };

    rum.programs.firefox.profiles = mkOption {
      type = attrsOf (
        submodule (
          {name, ...}: let
            profile = cfg.profiles.${name};
          in {
            config = mkIf (cfg.profiles ? ${name} && profile.enable) {
              files."browser-extension-data/FirefoxColor@mozilla.com/storage.js".source = "${sources.firefox}/${profile.flavor}/catppuccin-${profile.flavor}-${profile.accent}.json";
            };
          }
        )
      );
    };
  };

  config = {
    warnings = foldl' (
      acc: name:
        acc
        ++ optional (!(hasAttr name firefoxCfg.profiles))
        "Firefox profile '${name}' is defined in 'catppuccin.programs.firefox', but not 'rum.programs.firefox'. This will have no effect."
    ) [] (attrNames cfg.profiles);
  };
}
