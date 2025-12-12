// BROWSER BEHAVIOR & UI
user_pref("browser.tabs.hoverPreview.enabled", true);
user_pref("browser.tabs.loadBookmarksInBackground", true);

// PERMISSIONS DEFAULTS
user_pref("permissions.default.xr", 2);
user_pref("permissions.default.desktop-notification", 2);
user_pref("permissions.default.geo", 2);
user_pref("permissions.default.camera", 2);
user_pref("permissions.default.microphone", 2);
user_pref("permissions.manager.defaultsUrl", "");
user_pref("media.autoplay.default", 5);

// DNS-OVER-HTTPS & IPv6
user_pref("network.trr.mode", 3);
user_pref("network.trr.uri", "https://dns.adguard-dns.com/dns-query");
user_pref("network.trr.custom_uri", "https://dns.adguard-dns.com/dns-query");
user_pref("network.trr.bootstrapAddress", "94.140.14.14");
user_pref("network.dns.disableIPv6", true);

// HTTPS-ONLY MODE
user_pref("dom.security.https_only_mode", true);

// ENHANCED PRIVACY FEATURES
user_pref("browser.contentblocking.category", "custom");
user_pref("privacy.trackingprotection.enabled", true);
user_pref("network.cookie.cookieBehavior", 1);
user_pref("privacy.trackingprotection.cryptomining.enabled", true);
user_pref("privacy.fingerprintingProtection", true);
user_pref("privacy.trackingprotection.fingerprinting.enabled", true);
user_pref("privacy.trackingprotection.allow_list.baseline.enabled", false);
user_pref("privacy.trackingprotection.allow_list.convenience.enabled", false);
user_pref("privacy.globalprivacycontrol.enabled", true);
user_pref("browser.privatebrowsing.resetPBM.enabled", true);
user_pref("security.mixed_content.block_display_content", true);
user_pref("network.auth.subresource-http-auth-allow", 1);

// BROWSING HISTORY
user_pref("browser.formfill.enable", false);
user_pref("privacy.history.custom", true);
user_pref("places.history.enabled", true);
user_pref("extensions.formautofill.creditCards.enabled", false);

// PICTURE-IN-PICTURE
user_pref("media.videocontrols.picture-in-picture.enable-when-switching-tabs.enabled", true);

// UI
user_pref("browser.shell.checkDefaultBrowser", false);
user_pref("browser.uitour.enabled", false);
user_pref("browser.aboutwelcome.enabled", false);
user_pref("startup.homepage_welcome_url", "");
user_pref("startup.homepage_welcome_url.additional", "");
user_pref("browser.aboutConfig.showWarning", false);

// DOWNLOADS
user_pref("browser.download.manager.addToRecentDocs", false);
user_pref("browser.download.alwaysOpenPanel", false);
user_pref("browser.download.always_ask_before_handling_new_types", false);
user_pref("browser.download.start_downloads_in_tmp_dir", true);

// PDF VIEWER
user_pref("browser.download.open_pdf_attachments_inline", false);
user_pref("pdfjs.enableScripting", false);

// EXPERIMENTS & PROMOTIONS
user_pref("signon.firefoxRelay.feature", "disabled");
