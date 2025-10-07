{pkgs, ...}: {
  programs.firefox = {
    enable = true;
    package = pkgs.firefox-nightly-bin;

    profiles = {
      stefan = {
        name = "Stefan";
        isDefault = true;
        extensions.force = true;

        settings = {
          "browser.aboutConfig.showWarning" = false;
          "browser.bookmarks.restore_default_bookmarks" = false;
          "browser.contentblocking.category" = "strict";
          "browser.download.useDownloadDir" = false;
          "browser.formfill.enable" = false;
          "browser.newtabpage.activity-stream.feeds.section.topstories" = false;
          "browser.newtabpage.activity-stream.feeds.telemetry" = false;
          "browser.newtabpage.activity-stream.feeds.topsites" = false;
          "browser.newtabpage.activity-stream.showSponsored" = false;
          "browser.newtabpage.activity-stream.showSponsoredTopSites" = false;
          "browser.newtabpage.activity-stream.showWeather" = false;
          "browser.newtabpage.activity-stream.telemetry" = false;
          "browser.startup.page" = 3;
          "browser.ping-centre.telemetry" = false;
          "browser.tabs.closeWindowWithLastTab" = false;
          "browser.tabs.groups.smart.userEnabled" = false;
          "browser.toolbars.bookmarks.visibility" = false;
          "browser.urlbar.suggest.quicksuggest.sponsored" = false;
          "browser.urlbar.update2.engineAliasRefresh" = false;
          "cookiebanners.bannerClicking.enabled" = true;
          "cookiebanners.service.mode" = 1;
          "cookiebanners.service.privateBrowsing.mode" = 1;
          "datareporting.healthreport.uploadEnabled" = false;
          "datareporting.policy.dataSubmissionEnabled" = false;
          "datareporting.sessions.current.clean" = true;
          "devtools.onboarding.telemetry.logged" = false;
          "dom.forms.autocomplete.formautofill" = false;
          "dom.private-attribution.submission.enabled" = false;
          "dom.security.https_only_mode" = true;
          "extensions.formautofill.addresses.enabled" = false;
          "extensions.formautofill.creditCards.enabled" = false;
          "extensions.update.autoUpdateDefault" = false;
          "general.autoScroll" = true;
          "privacy.clearOnShutdown_v2.browsingHistoryAndDownloads" = false;
          "privacy.clearOnShutdown_v2.formdata" = true;
          "privacy.fingerprintingProtection" = true;
          "privacy.globalprivacycontrol.enabled" = true;
          "privacy.history.custom" = true;
          "privacy.query_stripping.enabled" = true;
          "privacy.query_stripping.enabled.pbmode" = true;
          "privacy.sanitize.sanitizeOnShutdown" = true;
          "privacy.trackingprotection.constentmanager.skip.pbmode.enabled" = false;
          "privacy.trackingprotection.emailtracking.enabled" = true;
          "privacy.trackingprotection.enabled" = true;
          "privacy.trackingprotection.socialtracking.enabled" = true;
          "security.OCSP.enabled" = 0;
          "sidebar.revamp" = true;
          "sidebar.verticalTabs" = true;
          "sidebar.visibility" = "expand-on-hover";
          "signon.autofillForms" = false;
          "signon.firefoxRelay.feature" = "disabled";
          "signon.generation.enabled" = false;
          "signon.management.page.breach-alerts.enabled" = false;
          "signon.rememberSignons" = false;
          "toolkit.telemetry.archive.enabled" = false;
          "toolkit.telemetry.bhrPing.enabled" = false;
          "toolkit.telemetry.enabled" = false;
          "toolkit.telemetry.firstShutdownPing.enabled" = false;
          "toolkit.telemetry.hybridContent.enabled" = false;
          "toolkit.telemetry.newProfilePing.enabled" = false;
          "toolkit.telemetry.reportingpolicy.firstRun" = false;
          "toolkit.telemetry.shutdownPingSender.enabled" = false;
          "toolkit.telemetry.unified" = false;
          "toolkit.telemetry.updatePing.enabled" = false;
        };

        search = {
          force = true;
          default = "ddg";
          engines = {
            "Github" = {
              urls = [{template = "https://github.com/search?type=repositories&q={searchTerms}";}];
              icon = "https://github.githubassets.com/favicons/favicon.svg";
              definedAliases = ["gh"];
            };
            "NixOS Wiki" = {
              urls = [{template = "https://nixos.wiki/index.php?search={searchTerms}";}];
              icon = "https://nixos.wiki/favicon.png";
              definedAliases = ["nw"];
            };
            "Nix Packages" = {
              urls = [{template = "https://search.nixos.org/packages?channel=unstable&query={searchTerms}";}];
              icon = "${pkgs.nixos-icons}/share/icons/hicolor/scalable/apps/nix-snowflake.svg";
              definedAliases = ["nxp"];
            };
            "Nix Options" = {
              urls = [{template = "https://search.nixos.org/options?channel=unstable&query={searchTerms}";}];
              icon = "${pkgs.nixos-icons}/share/icons/hicolor/scalable/apps/nix-snowflake.svg";
              definedAliases = ["nxo"];
            };
            "Noogle" = {
              urls = [{template = "https://noogle.dev/q?term={searchTerms}";}];
              icon = "${pkgs.nixos-icons}/share/icons/hicolor/scalable/apps/nix-snowflake.svg";
              definedAliases = ["nx"];
            };
            "Home Manager" = {
              urls = [{template = "https://home-manager-options.extranix.com/?release=master&query={searchTerms}";}];
              icon = "https://home-manager-options.extranix.com/images/favicon.png";
              definedAliases = ["hm"];
            };
            "Crates" = {
              urls = [{template = "https://crates.io/search?q={searchTerms}";}];
              icon = "https://crates.io/favicon.ico";
              definedAliases = ["crates"];
            };
            "DocsRS" = {
              urls = [{template = "https://docs.rs/releases/search?query={searchTerms}";}];
              icon = "https://docs.rs/favicon.ico";
              definedAliases = ["drs" "docsrs"];
            };
            "Rust" = {
              urls = [{template = "https://doc.rust-lang.org/std/?search={searchTerms}";}];
              icon = "https://doc.rust-lang.org/favicon.ico";
              definedAliases = ["rs"];
            };
          };
        };
      };
    };
  };

  xdg.mimeApps.defaultApplications = let
    firefox = "firefox-nightly.desktop";
  in {
    "text/html" = [firefox];
    "text/xml" = [firefox];
    "x-scheme-handler/http" = [firefox];
    "x-scheme-handler/https" = [firefox];

    "x-scheme-handler/about" = [firefox];
    "x-scheme-handler/unknown" = [firefox];
    "x-scheme-handler/webcal" = [firefox];
  };

  catppuccin.firefox.profiles.stefan.enable = true;
}
