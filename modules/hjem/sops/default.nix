{
  config,
  lib,
  pkgs,
  inputs,
  ...
}: let
  inherit (lib.attrsets) mapAttrsToList;
  inherit (lib.path) hasStorePathPrefix;
  inherit (lib.modules) mergeEqualOption mkIf mkOptionType;
  inherit (lib.options) literalExpression mkOption;
  inherit (lib.strings) concatStringsSep escapeShellArg optionalString;
  inherit (lib.types) attrsOf bool either enum ints listOf nullOr package path str submodule;

  sops-install-secrets = cfg.package;
  secretType = submodule (
    {name, ...}: {
      options = {
        name = mkOption {
          type = str;
          default = name;
          description = ''
            Name of the file used in /run/user/*/secrets
          '';
        };

        key = mkOption {
          type = str;
          default =
            if cfg.defaultSopsKey != null
            then cfg.defaultSopsKey
            else name;
          description = ''
            Key used to lookup in the sops file.
            No tested data structures are supported right now.
            This option is ignored if format is binary.
            "" means whole file.
          '';
        };

        path = mkOption {
          type = str;
          default = "${cfg.defaultSymlinkPath}/${name}";
          description = ''
            Path where secrets are symlinked to.
            If the default is kept no other symlink is created.
            `%r` is replaced by $XDG_RUNTIME_DIR on linux or `getconf
            DARWIN_USER_TEMP_DIR` on darwin.
          '';
        };

        format = mkOption {
          type = enum [
            "yaml"
            "json"
            "binary"
            "ini"
            "dotenv"
          ];
          default = cfg.defaultSopsFormat;
          description = ''
            File format used to decrypt the sops secret.
            Binary files are written to the target file as is.
          '';
        };

        mode = mkOption {
          type = str;
          default = "0400";
          description = ''
            Permissions mode of the in octal.
          '';
        };

        sopsFile = mkOption {
          type = path;
          default = cfg.defaultSopsFile;
          defaultText = literalExpression "\${config.sops.defaultSopsFile}";
          description = ''
            Sops file the secret is loaded from.
          '';
        };
      };
    }
  );

  pathNotInStore = mkOptionType {
    name = "pathNotInStore";
    description = "path not in the Nix store";
    descriptionClass = "noun";
    check = x: !hasStorePathPrefix (/. + x);
    merge = mergeEqualOption;
  };

  manifestFor = suffix: secrets: templates:
    pkgs.writeTextFile {
      name = "manifest${suffix}.json";
      text = builtins.toJSON {
        secrets = builtins.attrValues secrets;
        templates = builtins.attrValues templates;
        secretsMountPoint = cfg.defaultSecretsMountPoint;
        symlinkPath = cfg.defaultSymlinkPath;
        keepGenerations = cfg.keepGenerations;
        gnupgHome = null;
        sshKeyPaths = [];
        ageKeyFile = cfg.age.keyFile;
        ageSshKeyPaths = cfg.age.sshKeyPaths;
        placeholderBySecretName = cfg.placeholder;
        userMode = true;
        logging = {
          keyImport = builtins.elem "keyImport" cfg.log;
          secretChanges = builtins.elem "secretChanges" cfg.log;
        };
      };
      checkPhase = ''
        ${sops-install-secrets}/bin/sops-install-secrets -check-mode=${
          if cfg.validateSopsFiles
          then "sopsfile"
          else "manifest"
        } "$out"
      '';
    };

  manifest = manifestFor "" cfg.secrets cfg.templates;

  escapedAgeKeyFile = escapeShellArg cfg.age.keyFile;

  script = toString (
    pkgs.writeShellScript "sops-nix-user" (
      optionalString cfg.age.generateKey ''
        if [[ ! -f ${escapedAgeKeyFile} ]]; then
          echo generating machine-specific age key...
          ${pkgs.coreutils}/bin/mkdir -p $(${pkgs.coreutils}/bin/dirname ${escapedAgeKeyFile})
          # age-keygen sets 0600 by default, no need to chmod.
          ${pkgs.age}/bin/age-keygen -o ${escapedAgeKeyFile}
        fi
      ''
      + ''
        ${sops-install-secrets}/bin/sops-install-secrets -ignore-passwd ${manifest}
      ''
    )
  );

  cfg = config.sops;
in {
  options.sops = {
    secrets = mkOption {
      type = attrsOf secretType;
      default = {};
      description = ''
        Secrets to decrypt.
      '';
    };

    defaultSopsFile = mkOption {
      type = path;
      description = ''
        Default sops file used for all secrets.
      '';
    };

    defaultSopsFormat = mkOption {
      type = str;
      default = "yaml";
      description = ''
        Default sops format used for all secrets.
      '';
    };

    defaultSopsKey = mkOption {
      type = nullOr str;
      default = null;
      description = ''
        Default key used to lookup in all secrets.
        This option is ignored if format is binary.
        "" means whole file.
      '';
    };

    validateSopsFiles = mkOption {
      type = bool;
      default = true;
      description = ''
        Check all sops files at evaluation time.
        This requires sops files to be added to the nix store.
      '';
    };

    defaultSymlinkPath = mkOption {
      type = str;
      default = "${config.xdg.config.directory}/sops-nix/secrets";
      description = ''
        Default place where the latest generation of decrypt secrets
        can be found.
      '';
    };

    defaultSecretsMountPoint = mkOption {
      type = str;
      default = "%r/secrets.d";
      description = ''
        Default place where generations of decrypted secrets are stored.
      '';
    };

    keepGenerations = mkOption {
      type = ints.unsigned;
      default = 1;
      description = ''
        Number of secrets generations to keep. Setting this to 0 disables pruning.
      '';
    };

    log = mkOption {
      type = listOf (enum ["keyImport" "secretChanges"]);
      default = [
        "keyImport"
        "secretChanges"
      ];
      description = "What to log";
    };

    environment = mkOption {
      type = attrsOf (either str path);
      default = {};
      description = ''
        Environment variables to set before calling sops-install-secrets.

        To properly quote strings with quotes use lib.escapeShellArg.
      '';
    };

    package = mkOption {
      type = package;
      default = (pkgs.callPackage inputs.sops-nix {}).sops-install-secrets;
      description = ''
        sops-install-secrets package to use.
      '';
    };

    age = {
      keyFile = mkOption {
        type = nullOr pathNotInStore;
        default = null;
        example = "/home/someuser/.age-key.txt";
        description = ''
          Path to age key file used for sops decryption.
        '';
      };

      generateKey = mkOption {
        type = bool;
        default = false;
        description = ''
          Whether or not to generate the age key. If this
          option is set to false, the key must already be
          present at the specified location.
        '';
      };

      sshKeyPaths = mkOption {
        type = listOf path;
        default = [];
        description = ''
          Paths to ssh keys added as age keys during sops description.
        '';
      };
    };
  };

  config = mkIf (cfg.secrets != {}) {
    assertions = [
      {
        assertion = cfg.age.keyFile != null || cfg.age.sshKeyPaths != [];
        message = "No key source configured for sops.";
      }
    ];

    # TODO: reload on reactivation
    # see https://github.com/feel-co/hjem/issues/63
    systemd.services.sops-nix = {
      description = "sops-nix activation";
      wantedBy = ["default.target"];
      serviceConfig = {
        Type = "oneshot";
        Environment = concatStringsSep " " (mapAttrsToList (name: value: "'${name}=${value}'") cfg.environment);
        ExecStart = script;
      };
    };
  };
}
