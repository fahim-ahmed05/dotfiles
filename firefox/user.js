// DNS-OVER-HTTPS
user_pref("network.trr.mode", 3);
user_pref("network.trr.uri", "https://dns.quad9.net/dns-query");
user_pref("network.trr.custom_uri", "https://dns.quad9.net/dns-query");
user_pref("network.trr.bootstrapAddress", "9.9.9.9");

// HTTPS-ONLY MODE
user_pref("dom.security.https_only_mode", true);
user_pref("dom.security.https_only_mode_error_page_user_suggestions", true);

// ENHANCED PRIVACY FEATURES
user_pref("browser.contentblocking.category", "custom");
user_pref("privacy.trackingprotection.enabled", true);
user_pref("network.cookie.cookieBehavior", 1);
user_pref("privacy.trackingprotection.cryptomining.enabled", true);
user_pref("privacy.fingerprintingProtection", true);
user_pref("privacy.trackingprotection.fingerprinting.enabled", true);
user_pref("privacy.globalprivacycontrol.enabled", true);
user_pref("browser.privatebrowsing.resetPBM.enabled", true);
user_pref("network.auth.subresource-http-auth-allow", 1);

// TELEMETRY & DATA COLLECTION
user_pref("datareporting.policy.dataSubmissionEnabled", false);
user_pref("datareporting.healthreport.uploadEnabled", false);
user_pref("toolkit.telemetry.unified", false);
user_pref("toolkit.telemetry.enabled", false);
user_pref("toolkit.telemetry.server", "data:,");
user_pref("toolkit.telemetry.archive.enabled", false);
user_pref("toolkit.telemetry.newProfilePing.enabled", false);
user_pref("toolkit.telemetry.shutdownPingSender.enabled", false);
user_pref("toolkit.telemetry.updatePing.enabled", false);
user_pref("toolkit.telemetry.bhrPing.enabled", false);
user_pref("toolkit.telemetry.firstShutdownPing.enabled", false);
user_pref("toolkit.telemetry.coverage.opt-out", true);
user_pref("toolkit.coverage.endpoint.base", "");
user_pref("browser.newtabpage.activity-stream.feeds.telemetry", false);
user_pref("browser.newtabpage.activity-stream.telemetry", false);
user_pref("breakpad.reportURL", "");
user_pref("browser.tabs.crashReporting.sendReport", false);
user_pref("security.csp.reporting.enabled", false);
user_pref("privacy.antitracking.isolateContentScriptResources", true);

// BROWSER BEHAVIOR & UI
user_pref("browser.tabs.hoverPreview.enabled", true);
user_pref("browser.tabs.loadBookmarksInBackground", true);
user_pref("browser.tabs.closeWindowWithLastTab", true);
user_pref("browser.ctrlTab.sortByRecentlyUsed", true);
user_pref("browser.bookmarks.openInTabClosesMenu", false);
user_pref("layout.word_select.eat_space_to_next_word", false);
user_pref("ui.key.menuAccessKeyFocuses", false);
user_pref("editor.truncate_user_pastes", false);
user_pref("browser.shell.checkDefaultBrowser", false);
user_pref("browser.aboutConfig.showWarning", false);
user_pref("browser.menu.showViewImageInfo", true);
user_pref("browser.tabs.warnOnClose", false);
user_pref("browser.translations.automaticallyPopup", false);
user_pref("browser.startup.homepage_override.mstone", "ignore");
user_pref("toolkit.legacyUserProfileCustomizations.stylesheets", true);
user_pref("svg.context-properties.content.enabled", true);
user_pref("browser.newtabpage.activity-stream.newtabLayouts.variant-a", false);
user_pref("browser.newtabpage.activity-stream.newtabLayouts.variant-b", false);
user_pref("browser.startup.blankWindow", false);
user_pref("findbar.highlightAll", true);
user_pref("browser.sessionstore.restore_pinned_tabs_on_demand", true);

// BROWSING HISTORY
user_pref("browser.formfill.enable", false);
user_pref("privacy.history.custom", true);
user_pref("places.history.enabled", true);
user_pref("extensions.formautofill.creditCards.enabled", false);

// PERMISSIONS DEFAULTS
user_pref("permissions.default.xr", 2);
user_pref("permissions.default.desktop-notification", 2);
user_pref("permissions.default.geo", 2);
user_pref("permissions.default.camera", 2);
user_pref("permissions.default.microphone", 2);
user_pref("permissions.manager.defaultsUrl", "");
user_pref("media.autoplay.default", 5);

// NEW TAB PAGE & HOMEPAGE
user_pref("browser.newtabpage.activity-stream.default.sites", "");
user_pref("browser.newtabpage.activity-stream.showSponsoredTopSites", false);
user_pref("browser.newtabpage.activity-stream.feeds.section.topstories", false);
user_pref("browser.newtabpage.activity-stream.showSponsored", false);
user_pref("browser.aboutwelcome.enabled", false);
user_pref("startup.homepage_welcome_url", "");
user_pref("startup.homepage_welcome_url.additional", "");
user_pref("browser.firefox-view.feature-tour", '{"screen":"","complete":true}');
user_pref("browser.newtabpage.activity-stream.showSponsoredCheckboxes", false);
user_pref("browser.newtabpage.activity-stream.showSearch", false);
user_pref("browser.newtabpage.activity-stream.section.highlights.includeBookmarks", false);
user_pref("browser.newtabpage.activity-stream.section.highlights.includeDownloads", false);

// DOWNLOADS
user_pref("browser.download.manager.addToRecentDocs", false);
user_pref("browser.download.alwaysOpenPanel", false);
user_pref("browser.download.always_ask_before_handling_new_types", false);
user_pref("browser.download.start_downloads_in_tmp_dir", true);

// PDF VIEWER
user_pref("browser.download.open_pdf_attachments_inline", false);
user_pref("pdfjs.enableScripting", false);

// EXPERIMENTS & PROMOTIONS
user_pref("toolkit.coverage.opt-out", true);
user_pref("datareporting.usage.uploadEnabled", false);
user_pref("extensions.getAddons.cache.enabled", false);
user_pref("app.shield.optoutstudies.enabled", false);
user_pref("app.normandy.enabled", false);
user_pref("app.normandy.api_url", "");
user_pref("browser.privatebrowsing.vpnpromourl", "");
user_pref("extensions.getAddons.showPane", false);
user_pref("extensions.htmlaboutaddons.recommendations.enabled", false);
user_pref("browser.discovery.enabled", false);
user_pref("browser.newtabpage.activity-stream.asrouter.userprefs.cfr.addons", false);
user_pref("browser.newtabpage.activity-stream.asrouter.userprefs.cfr.features", false);
user_pref("browser.preferences.moreFromMozilla", false);
user_pref("signon.firefoxRelay.feature", "disabled");

// ADDRESS BAR & SEARCH
user_pref("browser.urlbar.trimHttps", true);
user_pref("browser.urlbar.untrimOnUserInteraction.featureGate", true);
user_pref("browser.search.update", false);
user_pref("browser.search.separatePrivateDefault.ui.enabled", true);
user_pref("network.IDN_show_punycode", true);
user_pref("browser.search.suggest.enabled.private", true);
user_pref("browser.urlbar.groupLabels.enabled", false);
user_pref("browser.urlbar.trending.featureGate", false);
user_pref("browser.urlbar.quicksuggest.enabled", false);

// SIDEBAR
user_pref("sidebar.position_start", false);

// PICTURE-IN-PICTURE
user_pref("media.videocontrols.picture-in-picture.enable-when-switching-tabs.enabled", true);

// AI INTEGRATION
user_pref("browser.ml.enable", false);
user_pref("browser.ml.chat.enabled", false);
user_pref("browser.ml.chat.menu", false);
user_pref("browser.tabs.groups.smart.enabled", false);
user_pref("browser.ml.linkPreview.enabled", false);

