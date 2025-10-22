// TAB BEHAVIOR
user_pref("browser.tabs.loadBookmarksInBackground", true);
user_pref("browser.tabs.hoverPreview.enabled", true);
user_pref("browser.tabs.closeWindowWithLastTab", false);
user_pref("browser.ctrlTab.sortByRecentlyUsed", true);

// WEBSITE PERMISSION
user_pref("permissions.default.xr", 2);
user_pref("permissions.default.desktop-notification", 2);
user_pref("permissions.default.geo", 2);
user_pref("permissions.default.camera", 2);
user_pref("permissions.default.microphone", 2);
user_pref("permissions.manager.defaultsUrl", "");
user_pref("media.autoplay.default", 5);

// DOH & IPV6
user_pref("network.trr.mode", 3);
user_pref("network.trr.uri", "https://dns.adguard-dns.com/dns-query");
user_pref("network.trr.custom_uri", "https://dns.adguard-dns.com/dns-query");
user_pref("network.trr.bootstrapAddress", "94.140.14.14");
user_pref("network.dns.disableIPv6", true);

// TRACKING PROTECTION
user_pref("browser.contentblocking.category", "custom");
user_pref("privacy.trackingprotection.enabled", true);
user_pref("network.cookie.cookieBehavior", 1);
user_pref("privacy.trackingprotection.cryptomining.enabled", true);
user_pref("privacy.trackingprotection.fingerprinting.enabled", true);
user_pref("privacy.trackingprotection.fingerprinting.probable.enabled", true);
user_pref("privacy.trackingprotection.allow_list.baseline.enabled", false);
user_pref("privacy.trackingprotection.allow_list.convenience.enabled", false);
user_pref("privacy.trackingprotection.socialtracking.enabled", true);
user_pref("privacy.trackingprotection.antifraud.skip.enabled", true);
user_pref("privacy.trackingprotection.consentmanager.skip.enabled", true);
user_pref("privacy.trackingprotection.emailtracking.enabled", true);
user_pref("privacy.antitracking.isolateContentScriptResources", true);

// HTTPS-ONLY MODE
user_pref("dom.security.https_only_mode", true);

// BROWSING HISTORY
user_pref("privacy.history.custom", true);
user_pref("places.history.enabled", true);
user_pref("browser.formfill.enable", false);
user_pref("extensions.formautofill.creditCards.enabled", false);

// PICTURE-IN-PICTURE
user_pref("media.videocontrols.picture-in-picture.enable-when-switching-tabs.enabled", true);

// ZEN
user_pref("zen.watermark.enabled", false)
user_pref("zen.view.experimental-no-window-controls", true);

// UI
user_pref("browser.shell.checkDefaultBrowser", false);
user_pref("browser.uitour.enabled", false);
user_pref("browser.aboutwelcome.enabled", false);
user_pref("startup.homepage_welcome_url", "");
user_pref("startup.homepage_welcome_url.additional", "");
user_pref("browser.aboutConfig.showWarning", false);
user_pref("toolkit.legacyUserProfileCustomizations.stylesheets", true);

// MOZILLA
user_pref("signon.firefoxRelay.feature", "disabled");
user_pref("browser.firefox-view.feature-tour", '{"screen":"","complete":true}');

// SEARCH
user_pref("browser.search.suggest.enabled", true);
user_pref("browser.search.suggest.enabled.private", true);

// DOWNLOAD
user_pref("browser.download.alwaysOpenPanel", false);
user_pref("browser.download.autohideButton", true);
user_pref("browser.download.always_ask_before_handling_new_types", false);
user_pref("browser.download.start_downloads_in_tmp_dir", true);

// PDF
user_pref("pdfjs.enableScripting", false);
user_pref("browser.download.open_pdf_attachments_inline", false);

