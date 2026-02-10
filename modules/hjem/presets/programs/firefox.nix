{
  config,
  lib,
  ...
}: let
  inherit (lib.modules) mkIf;
  inherit (lib.options) mkEnableOption;

  cfg = config.presets.programs.firefox;
in {
  options.presets.programs.firefox = {
    enable = mkEnableOption "firefox preset";
  };

  config = mkIf cfg.enable {
    environment.sessionVariables.BROWSER = "firefox-nightly";

    rum.programs.firefox = {
      enable = true;

      # TODO: search (seems like a pain in the ass)

      profiles.stefan = {
        name = "Stefan";
        default = true;
        files."user.js".text =
          # js
          ''
            // keep-sorted start
            user_pref("browser.aboutConfig.showWarning", false);
            user_pref("browser.bookmarks.restore_default_bookmarks", false);
            user_pref("browser.contentblocking.category", "strict");
            user_pref("browser.download.useDownloadDir", false);
            user_pref("browser.formfill.enable", false);
            user_pref("browser.newtabpage.activity-stream.feeds.section.topstories", false);
            user_pref("browser.newtabpage.activity-stream.feeds.telemetry", false);
            user_pref("browser.newtabpage.activity-stream.feeds.topsites", false);
            user_pref("browser.newtabpage.activity-stream.showSponsored", false);
            user_pref("browser.newtabpage.activity-stream.showSponsoredTopSites", false);
            user_pref("browser.newtabpage.activity-stream.showWeather", false);
            user_pref("browser.newtabpage.activity-stream.telemetry", false);
            user_pref("browser.ping-centre.telemetry", false);
            user_pref("browser.search.suggest.enabled", false);
            user_pref("browser.startup.page", 3);
            user_pref("browser.tabs.closeWindowWithLastTab", false);
            user_pref("browser.tabs.groups.smart.userEnabled", false);
            user_pref("browser.toolbars.bookmarks.visibility", false);
            user_pref("browser.urlbar.suggest.quicksuggest.sponsored", false);
            user_pref("browser.urlbar.update2.engineAliasRefresh", false);
            user_pref("cookiebanners.bannerClicking.enabled", true);
            user_pref("cookiebanners.service.mode", 1);
            user_pref("cookiebanners.service.privateBrowsing.mode", 1);
            user_pref("datareporting.healthreport.uploadEnabled", false);
            user_pref("datareporting.policy.dataSubmissionEnabled", false);
            user_pref("datareporting.sessions.current.clean", true);
            user_pref("devtools.onboarding.telemetry.logged", false);
            user_pref("dom.forms.autocomplete.formautofill", false);
            user_pref("dom.private-attribution.submission.enabled", false);
            user_pref("dom.security.https_only_mode", true);
            user_pref("extensions.formautofill.addresses.enabled", false);
            user_pref("extensions.formautofill.creditCards.enabled", false);
            user_pref("extensions.update.autoUpdateDefault", false);
            user_pref("extensions.webextensions.ExtensionStorageIDB.enabled", false);
            user_pref("general.autoScroll", true);
            user_pref("intl.accept_languages", "en-US");
            user_pref("network.lna.block_trackers", true); // block third-party trackers from accessing localhost and local network resources
            user_pref("privacy.clearOnShutdown_v2.browsingHistoryAndDownloads", false);
            user_pref("privacy.clearOnShutdown_v2.formdata", true);
            user_pref("privacy.fingerprintingProtection", true);
            user_pref("privacy.globalprivacycontrol.enabled", true);
            user_pref("privacy.history.custom", true);
            user_pref("privacy.query_stripping.enabled", true);
            user_pref("privacy.query_stripping.enabled.pbmode", true);
            user_pref("privacy.sanitize.sanitizeOnShutdown", true);
            user_pref("privacy.trackingprotection.constentmanager.skip.pbmode.enabled", false);
            user_pref("privacy.trackingprotection.emailtracking.enabled", true);
            user_pref("privacy.trackingprotection.enabled", true);
            user_pref("privacy.trackingprotection.socialtracking.enabled", true);
            user_pref("security.OCSP.enabled", 0);
            user_pref("sidebar.revamp", true);
            user_pref("sidebar.verticalTabs", true);
            user_pref("sidebar.visibility", "expand-on-hover");
            user_pref("signon.autofillForms", false);
            user_pref("signon.firefoxRelay.feature", "disabled");
            user_pref("signon.generation.enabled", false);
            user_pref("signon.management.page.breach-alerts.enabled", false);
            user_pref("signon.rememberSignons", false);
            user_pref("toolkit.telemetry.archive.enabled", false);
            user_pref("toolkit.telemetry.bhrPing.enabled", false);
            user_pref("toolkit.telemetry.enabled", false);
            user_pref("toolkit.telemetry.firstShutdownPing.enabled", false);
            user_pref("toolkit.telemetry.hybridContent.enabled", false);
            user_pref("toolkit.telemetry.newProfilePing.enabled", false);
            user_pref("toolkit.telemetry.reportingpolicy.firstRun", false);
            user_pref("toolkit.telemetry.shutdownPingSender.enabled", false);
            user_pref("toolkit.telemetry.unified", false);
            user_pref("toolkit.telemetry.updatePing.enabled", false);
            // keep-sorted end
          '';

        # TODO:
        # search = {
        #   force = true;
        #   default = "ddg";
        #   engines = {
        #     "Github" = {
        #       urls = [{template = "https://github.com/search?type=repositories&q={searchTerms}";}];
        #       icon = "https://github.githubassets.com/favicons/favicon.svg";
        #       definedAliases = ["gh"];
        #     };
        #     "NixOS Wiki" = {
        #       urls = [{template = "https://nixos.wiki/index.php?search={searchTerms}";}];
        #       icon = "https://nixos.wiki/favicon.png";
        #       definedAliases = ["nw"];
        #     };
        #     "Nix Packages" = {
        #       urls = [{template = "https://search.nixos.org/packages?channel=unstable&query={searchTerms}";}];
        #       icon = "${pkgs.nixos-icons}/share/icons/hicolor/scalable/apps/nix-snowflake.svg";
        #       definedAliases = ["nxp"];
        #     };
        #     "Nix Options" = {
        #       urls = [{template = "https://search.nixos.org/options?channel=unstable&query={searchTerms}";}];
        #       icon = "${pkgs.nixos-icons}/share/icons/hicolor/scalable/apps/nix-snowflake.svg";
        #       definedAliases = ["nxo"];
        #     };
        #     "Noogle" = {
        #       urls = [{template = "https://noogle.dev/q?term={searchTerms}";}];
        #       icon = "${pkgs.nixos-icons}/share/icons/hicolor/scalable/apps/nix-snowflake.svg";
        #       definedAliases = ["nx"];
        #     };
        #     "Home Manager" = {
        #       urls = [{template = "https://home-manager-options.extranix.com/?release=master&query={searchTerms}";}];
        #       icon = "https://home-manager-options.extranix.com/images/favicon.png";
        #       definedAliases = ["hm"];
        #     };
        #     "Crates" = {
        #       urls = [{template = "https://crates.io/search?q={searchTerms}";}];
        #       icon = "https://crates.io/favicon.ico";
        #       definedAliases = ["crates"];
        #     };
        #     "DocsRS" = {
        #       urls = [{template = "https://docs.rs/releases/search?query={searchTerms}";}];
        #       icon = "https://docs.rs/favicon.ico";
        #       definedAliases = ["drs" "docsrs"];
        #     };
        #     "Rust" = {
        #       urls = [{template = "https://doc.rust-lang.org/std/?search={searchTerms}";}];
        #       icon = "https://doc.rust-lang.org/favicon.ico";
        #       definedAliases = ["rs"];
        #     };
        #   };
        # };
      };
    };
  };
}
