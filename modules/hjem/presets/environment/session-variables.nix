{
  config,
  lib,
  ...
}: let
  inherit (lib.modules) mkIf;
  inherit (lib.options) mkEnableOption;

  cacheDir = config.xdg.cache.directory;
  dataDir = config.xdg.data.directory;
  stateDir = config.xdg.state.directory;

  cfg = config.presets.environment.sessionVariables;
in {
  options.presets.environment.sessionVariables = {
    enable = mkEnableOption "session variables preset";
  };

  config.environment.sessionVariables = mkIf cfg.enable {
    LESS = "-FRXS";

    # make stuff xdg compliant
    CARGO_HOME = "${dataDir}/cargo";
    GNUPGHOME = "${dataDir}/gnupg";
    HISTFILE = "${stateDir}/bash_history";
    NODE_REPL_HISTORY = "${dataDir}/node_repl_history";
    NPM_CONFIG_CACHE = "${cacheDir}/npm";
    NPM_CONFIG_PREFIX = "${dataDir}/npm";
    PLATFORMIO_CORE_DIR = "${dataDir}/platformio";
    PYTHON_HISTORY = "${stateDir}/python_history";
    RUSTUP_HOME = "${dataDir}/rust";
    SQLITE_HISTORY = "${stateDir}/sqlite_history";
    WINEPREFIX = "${dataDir}/wine";
    _JAVA_OPTIONS = "-Djava.util.prefs.userRoot=${dataDir}/java";
  };
}
