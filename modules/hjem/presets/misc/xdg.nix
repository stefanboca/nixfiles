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

  cfg = config.presets.misc.xdg;
in {
  options.presets.misc.xdg = {
    enable = mkEnableOption "xdg directories preset";
  };

  config = mkIf cfg.enable {
    environment.sessionVariables = {
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

    xdg.config.files."go/env".text = ''
      GOPATH=${config.xdg.data.directory}/go;
    '';

    rum.misc.gtk.gtk2Location = ".config/gtk-2.0/gtkrc";
  };
}
