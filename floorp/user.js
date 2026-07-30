/*** HTTPS ***/
user_pref("dom.security.https_only_mode", true);
user_pref("dom.security.https_only_mode_error_page_user_suggestions", true);

/*** DNS over HTTPS (Quad9) ***/
user_pref("network.trr.mode", 2);
user_pref("network.trr.uri", "https://dns.quad9.net/dns-query");
user_pref("network.trr.custom_uri", "https://dns.quad9.net/dns-query");
user_pref("network.trr.bootstrapAddress", "9.9.9.9");

/*** IPv6 ***/
user_pref("network.dns.disableIPv6", true);

/*** Tracking Protection ***/
user_pref("browser.contentblocking.category", "strict");
user_pref("privacy.trackingprotection.enabled", true);
user_pref("privacy.fingerprintingProtection", true);
user_pref("privacy.globalprivacycontrol.enabled", true);

/*** Cookies ***/
user_pref("network.cookie.cookieBehavior", 1);

/*** Referrer Privacy ***/
user_pref("network.http.referer.XOriginTrimmingPolicy", 2);

/*** Disable Speculative Connections ***/
user_pref("network.prefetch-next", false);
user_pref("network.predictor.enabled", false);
user_pref("network.dns.disablePrefetch", true);
user_pref("network.dns.disablePrefetchFromHTTPS", true);
user_pref("browser.urlbar.speculativeConnect.enabled", false);
user_pref("browser.places.speculativeConnect.enabled", false);

/*** Telemetry ***/
user_pref("datareporting.policy.dataSubmissionEnabled", false);
user_pref("datareporting.healthreport.uploadEnabled", false);

user_pref("toolkit.telemetry.enabled", false);
user_pref("toolkit.telemetry.unified", false);
user_pref("toolkit.telemetry.archive.enabled", false);
user_pref("toolkit.telemetry.server", "data:,");

user_pref("toolkit.coverage.endpoint.base", "");
user_pref("toolkit.coverage.opt-out", true);

user_pref("app.normandy.enabled", false);
user_pref("app.normandy.api_url", "");

user_pref("browser.discovery.enabled", false);

user_pref("browser.newtabpage.activity-stream.telemetry", false);
user_pref("browser.newtabpage.activity-stream.feeds.telemetry", false);

/*** Firefox Experiments ***/
user_pref("app.shield.optoutstudies.enabled", false);

/*** AI ***/
user_pref("browser.ml.enable", false);
user_pref("browser.ml.chat.enabled", false);
user_pref("browser.ml.linkPreview.enabled", false);

/*** Permissions ***/
user_pref("permissions.default.geo", 2);
user_pref("permissions.default.camera", 2);
user_pref("permissions.default.microphone", 2);
user_pref("permissions.default.desktop-notification", 2);
user_pref("permissions.default.xr", 2);

/*** PDF ***/
user_pref("pdfjs.enableScripting", false);

/*** Downloads ***/
user_pref("browser.download.manager.addToRecentDocs", false);
user_pref("browser.download.start_downloads_in_tmp_dir", true);

/*** Forms ***/
user_pref("browser.formfill.enable", false);
user_pref("extensions.formautofill.creditCards.enabled", false);

/*** Containers ***/
user_pref("privacy.userContext.enabled", true);
user_pref("privacy.userContext.ui.enabled", true);

/*** Punycode ***/
user_pref("network.IDN_show_punycode", true);

/*** CSS ***/
user_pref("toolkit.legacyUserProfileCustomizations.stylesheets", true);

/*** UI ***/
user_pref("browser.aboutConfig.showWarning", false);
user_pref("browser.tabs.hoverPreview.enabled", true);
user_pref("browser.tabs.loadBookmarksInBackground", true);
user_pref("browser.ctrlTab.sortByRecentlyUsed", true);

/*** Fullscreen ***/
user_pref("full-screen-api.transition-duration.enter", "0 0");
user_pref("full-screen-api.transition-duration.leave", "0 0");
user_pref("full-screen-api.warning.timeout", 0);
user_pref("full-screen-api.warning.delay", -1);

/*** Search ***/
user_pref("browser.search.update", false);
user_pref("browser.urlbar.groupLabels.enabled", false);
user_pref("browser.urlbar.quicksuggest.enabled", false);

/*** New Tab ***/
user_pref("browser.aboutwelcome.enabled", false);
user_pref("browser.newtabpage.activity-stream.showSponsored", false);
user_pref("browser.newtabpage.activity-stream.showSponsoredTopSites", false);
user_pref("browser.newtabpage.activity-stream.showSearch", false);

/*** Session ***/
user_pref("browser.sessionstore.interval", 60000);
user_pref("browser.sessionstore.restore_pinned_tabs_on_demand", true);

/*** Crash Reports ***/
user_pref("browser.tabs.crashReporting.sendReport", false);
user_pref("breakpad.reportURL", "");

/*** OCSP ***/
user_pref("security.OCSP.enabled", 1);

/*** TLS ***/
user_pref("security.tls.enable_0rtt_data", false);

/*** Mixed Content ***/
user_pref("security.mixed_content.block_display_content", true);

/*** Picture-in-Picture ***/
user_pref("media.videocontrols.picture-in-picture.enable-when-switching-tabs.enabled", true);
