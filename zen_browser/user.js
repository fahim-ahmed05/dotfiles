// TAB BEHAVIOR
user_pref("browser.tabs.loadBookmarksInBackground", true);
user_pref("browser.tabs.hoverPreview.enabled", true);

// WEBSITE PERMISSIONS
user_pref("permissions.default.xr", 2);
user_pref("permissions.default.desktop-notification", 2);
user_pref("permissions.default.geo", 2);
user_pref("permissions.default.camera", 2);
user_pref("permissions.default.microphone", 2);

// DOH & IPV6
user_pref("network.trr.mode", 3);
user_pref("network.trr.uri", "https://dns.adguard-dns.com/dns-query");
user_pref("network.trr.custom_uri", "https://dns.adguard-dns.com/dns-query");
user_pref("network.trr.bootstrapAddress", "94.140.14.14");

// BROWSING HISTORY
user_pref("privacy.history.custom", true);
user_pref("places.history.enabled", true);
user_pref("browser.formfill.enable", false);

// PICTURE-IN-PICTURE
user_pref("media.videocontrols.picture-in-picture.enable-when-switching-tabs.enabled", true);

// ZEN UI
user_pref("browser.shell.checkDefaultBrowser", false);
user_pref("zen.watermark.enabled", false)

