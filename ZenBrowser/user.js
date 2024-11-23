user_pref("network.trr.mode", 3); // Use DNS over HTTPS (DoH) as primary resolver
user_pref("network.trr.uri", "https://dns.adguard-dns.com/dns-query"); // DoH URI
user_pref("network.trr.custom_uri", "https://dns.adguard-dns.com/dns-query"); // Custom DoH URI
user_pref("network.trr.bootstrapAddress", "94.140.14.14"); // Adguard IP for DoH bootstrap

user_pref("network.dns.disableIPv6", true); // Disable IPv6 for DNS resolution

user_pref("browser.tabs.loadBookmarksInBackground", true); // Load bookmarks in background