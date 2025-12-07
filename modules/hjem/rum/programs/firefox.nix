{
  config,
  hjem-lib,
  lib,
  name,
  pkgs,
  ...
}: let
  inherit (lib.attrsets) attrsToList listToAttrs mapAttrs' mapAttrsToList mergeAttrsList nameValuePair optionalAttrs;
  inherit (lib.lists) filter imap0 length;
  inherit (lib.modules) mkIf;
  inherit (lib.options) literalExpression mkEnableOption mkOption mkPackageOption;
  inherit (lib.trivial) id pipe;
  inherit (lib.types) attrsOf singleLineStr submodule bool;

  username = name;

  ini = pkgs.formats.ini {};

  profileType = submodule ({name, ...}: {
    options = {
      name = mkOption {
        type = singleLineStr;
        default = name;
      };

      default = mkOption {
        type = bool;
        default = false;
      };

      files = mkOption {
        type = attrsOf (hjem-lib.fileTypeRelativeTo {
          rootDir = "${config.directory}/.mozilla/firefox/${name}";
          clobberDefault = config.clobberFiles;
          clobberDefaultText = literalExpression "config.hjem.users.${username}.clobberFiles";
        });
        default = {};
      };
    };
  });

  profilesIni =
    (pipe cfg.profiles [
      attrsToList
      (imap0 (id: attrs:
        nameValuePair "Profile${toString id}" {
          Name = attrs.value.name;
          Path = attrs.name;
          Default =
            if attrs.value.default
            then 1
            else 0;
          IsRelative = 1;
        }))
      listToAttrs
    ])
    // {
      General = {
        StartWithLastProfile = 1;
        Version = 2;
      };
    };

  # HACK: manually copy over all the file attrs
  # surely there's a better way I haven't discovered yet...
  mapFiles = name:
    mapAttrs' (path: file:
      nameValuePair ".mozilla/firefox/${name}/${path}" (
        {inherit (file) clobber enable executable source;}
        # text and generator do not need to be passed; they are brought up through source.
        // optionalAttrs (file.permissions != null) {inherit (file) permissions;}
        // optionalAttrs (file.uid != null) {inherit (file) uid;}
        // optionalAttrs (file.gid != null) {inherit (file) gid;}
        // optionalAttrs (file.value != null) {inherit (file) value;}
      ));
  profileFiles = mergeAttrsList (mapAttrsToList (name: profile: mapFiles name profile.files) cfg.profiles);

  cfg = config.rum.programs.firefox;
in {
  options.rum.programs.firefox = {
    enable = mkEnableOption "firefox";
    package = mkPackageOption pkgs "firefox-nightly-bin" {nullable = true;};

    profiles = mkOption {
      type = attrsOf profileType;
      default = {};
    };
  };

  config = mkIf cfg.enable {
    packages = mkIf (cfg.package != null) [cfg.package];
    files =
      profileFiles
      // {
        ".mozilla/firefox/profiles.ini" = {
          source = ini.generate "firefox-profiles.ini" profilesIni;
        };
      };

    assertions = [
      {
        assertion = cfg.profiles == {} || length (filter id (mapAttrsToList (_: profile: profile.default) cfg.profiles)) == 1;
        message = "rum.programs.firefox: exactly one profile must be default.";
      }
    ];
  };
}
