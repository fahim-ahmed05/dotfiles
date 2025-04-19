// GENERAL
user_pref("content.notify.interval", 100000);

// GFX
user_pref("gfx.canvas.accelerated.cache-size", 512);
user_pref("gfx.content.skia-font-cache-size", 20);

// DISK CACHE
user_pref("browser.cache.disk.enable", false);

// MEDIA CACHE 
user_pref("media.memory_cache_max_size", 65536);
user_pref("media.cache_readahead_limit", 7200);
user_pref("media.cache_resume_threshold", 3600);

// IMAGE CACHE 
user_pref("image.mem.decode_bytes_at_a_time", 32768);

// DNS CACHE
user_pref("network.dnsCacheEntries", 1000);
user_pref("network.dnsCacheExpiration", 3600);

// NETWORK 
user_pref("network.http.max-connections", 1800);
user_pref("network.http.max-persistent-connections-per-server", 10);
user_pref("network.http.max-urgent-start-excessive-connections-per-host", 5);
user_pref("network.http.pacing.requests.enabled", false);
user_pref("network.ssl_tokens_cache_capacity", 10240);

// SECURITY
user_pref("network.dns.disableIPv6", true);
user_pref("dom.security.https_only_mode", true);

// SPECULATIVE LOADING 
user_pref("network.dns.disablePrefetch", true);
user_pref("network.dns.disablePrefetchFromHTTPS", true);
user_pref("network.prefetch-next", false);
user_pref("network.predictor.enabled", false);
user_pref("network.predictor.enable-prefetch", false);

// DNS OVER HTTPS
user_pref("network.trr.mode", 3);
user_pref("network.trr.uri", "https://dns.adguard-dns.com/dns-query");
user_pref("network.trr.custom_uri", "https://dns.adguard-dns.com/dns-query");
user_pref("network.trr.bootstrapAddress", "94.140.14.14");

// SMOOTH SCROLLING
user_pref("apz.overscroll.enabled", true);
user_pref("general.smoothScroll", true);
user_pref("general.smoothScroll.msdPhysics.continuousMotionMaxDeltaMS", 12);
user_pref("general.smoothScroll.msdPhysics.enabled", true);
user_pref("general.smoothScroll.msdPhysics.motionBeginSpringConstant", 600);
user_pref("general.smoothScroll.msdPhysics.regularSpringConstant", 650);
user_pref("general.smoothScroll.msdPhysics.slowdownMinDeltaMS", 25);
user_pref("general.smoothScroll.msdPhysics.slowdownMinDeltaRatio", "2");
user_pref("general.smoothScroll.msdPhysics.slowdownSpringConstant", 250);
user_pref("general.smoothScroll.currentVelocityWeighting", "1");
user_pref("general.smoothScroll.stopDecelerationWeighting", "1");
user_pref("mousewheel.default.delta_multiplier_y", 300);

// WEBSITE PERMISSIONS
user_pref("permissions.default.xr", 2);
user_pref("permissions.default.desktop-notification", 2);
user_pref("permissions.default.geo", 2);
user_pref("media.autoplay.default", 0);

// MOZILLA UI 
user_pref("browser.aboutConfig.showWarning", false);
user_pref("browser.preferences.experimental.hidden", false);
user_pref("browser.preferences.moreFromMozilla", false);

// THEME ADJUSTMENTS 
user_pref("toolkit.legacyUserProfileCustomizations.stylesheets", true);
user_pref("widget.windows.mica", true);
user_pref("widget.windows.mica.popups", true);

// FULLSCREEN NOTICE 
user_pref("full-screen-api.transition-duration.enter", "0 0");
user_pref("full-screen-api.transition-duration.leave", "0 0");
user_pref("full-screen-api.warning.timeout", 0);

// URL BAR 
user_pref("browser.urlbar.suggest.calculator", true);
user_pref("browser.urlbar.unitConversion.enabled", true);

// TAB BEHAVIOR
user_pref("browser.tabs.closeWindowWithLastTab", true);
user_pref("browser.tabs.loadBookmarksInBackground", true);
user_pref("browser.tabs.hoverPreview.enabled", true);
user_pref("browser.ctrlTab.sortByRecentlyUsed", false);

// BROWSING HISTORY
user_pref("privacy.history.custom", true);
user_pref("places.history.enabled", true);
user_pref("browser.formfill.enable", false);

// TRACKING PROTECTION
user_pref("browser.contentblocking.category", "custom");
user_pref("network.cookie.cookieBehavior", 1);
user_pref("privacy.trackingprotection.enabled", true);
user_pref("privacy.trackingprotection.pbmode.enabled", true);
user_pref("privacy.trackingprotection.cryptomining.enabled", true);
user_pref("privacy.trackingprotection.fingerprinting.enabled", true);
user_pref("privacy.antitracking.fingerprinting.enforced", true);

// DOWNLOADS
user_pref("browser.download.manager.addToRecentDocs", false);
user_pref("browser.download.alwaysOpenPanel", false);
user_pref("browser.download.always_ask_before_handling_new_types", false);

// ACCESSIBILITY
user_pref("browser.urlbar.update2.engineAliasRefresh", true);
user_pref("layout.word_select.eat_space_to_next_word", false);
user_pref("ui.key.menuAccessKeyFocuses", false);
user_pref("media.videocontrols.picture-in-picture.enable-when-switching-tabs.enabled", true);