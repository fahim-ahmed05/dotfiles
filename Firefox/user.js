// DOH
user_pref("network.trr.mode", 3);
user_pref("network.trr.uri", "https://dns.adguard-dns.com/dns-query");
user_pref("network.trr.custom_uri", "https://dns.adguard-dns.com/dns-query");
user_pref("network.trr.bootstrapAddress", "94.140.14.14");

// IPv6
user_pref("network.dns.disableIPv6", true);

// Font Rendering
user_pref("gfx.webrender.quality.force-subpixel-aa-where-possible", true);
user_pref("gfx.font_rendering.cleartype_params.rendering_mode", 5);
user_pref("gfx.font_rendering.cleartype_params.cleartype_level", 100);
user_pref("gfx.font_rendering.cleartype_params.gamma", 1750);
user_pref("gfx.font_rendering.cleartype_params.enhanced_contrast", 100);
user_pref("gfx.font_rendering.cleartype_params.pixel_structure", 1);
user_pref("dom.text_fragments.enabled", true);
user_pref("gfx.font_rendering.cleartype_params.force_gdi_classic_for_families", "");
user_pref("gfx.font_rendering.directwrite.use_gdi_table_loading", false);

// Bookmark Bar
user_pref("browser.tabs.loadBookmarksInBackground", true);

// Full Screen
user_pref("full-screen-api.allow-trusted-requests-only", false);

// Smooth Scrolling
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

// Website Permission
user_pref("permissions.default.desktop-notification", 2);
user_pref("permissions.default.geo", 2);