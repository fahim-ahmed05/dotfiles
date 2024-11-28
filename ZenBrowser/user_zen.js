// DNS Over HTTPS
user_pref("network.trr.mode", 3); // Use DNS over HTTPS (DoH) as primary resolver
user_pref("network.trr.uri", "https://dns.adguard-dns.com/dns-query"); // DoH URI
user_pref("network.trr.custom_uri", "https://dns.adguard-dns.com/dns-query"); // Custom DoH URI
user_pref("network.trr.bootstrapAddress", "94.140.14.14"); // Adguard IP for DoH bootstrap

// IPv6 Preference
user_pref("network.dns.disableIPv6", true); // Disable IPv6 for DNS resolution

// Font Rendering
user_pref("gfx.webrender.quality.force-subpixel-aa-where-possible", true); // Force subpixel AA for WebRender
user_pref("gfx.font_rendering.cleartype_params.rendering_mode", 5); // Set ClearType rendering mode
user_pref("gfx.font_rendering.cleartype_params.cleartype_level", 100); // ClearType level
user_pref("gfx.font_rendering.cleartype_params.gamma", 1750); // ClearType gamma level
user_pref("gfx.font_rendering.cleartype_params.enhanced_contrast", 100); // ClearType enhanced contrast
user_pref("gfx.font_rendering.cleartype_params.pixel_structure", 1); // ClearType pixel structure
user_pref("dom.text_fragments.enabled", true); // Enable text fragments

// Bookmark Bar
user_pref("browser.tabs.loadBookmarksInBackground", true); // Load bookmarks in background

// Full Screen
user_pref("full-screen-api.allow-trusted-requests-only", false);  // Allow any extension to toggle full screen

// Smooth Scrolling
user_pref("apz.overscroll.enabled", true); // Enable overscroll effect
user_pref("general.smoothScroll", true); // Enable smooth scrolling
user_pref("general.smoothScroll.msdPhysics.continuousMotionMaxDeltaMS", 12); // Continuous motion max delta
user_pref("general.smoothScroll.msdPhysics.enabled", true); // Enable MSD physics for scrolling
user_pref("general.smoothScroll.msdPhysics.motionBeginSpringConstant", 600); // Begin spring constant
user_pref("general.smoothScroll.msdPhysics.regularSpringConstant", 650); // Regular spring constant
user_pref("general.smoothScroll.msdPhysics.slowdownMinDeltaMS", 25); // Min delta for slowdown
user_pref("general.smoothScroll.msdPhysics.slowdownSpringConstant", 250); // Slowdown spring constant
user_pref("general.smoothScroll.currentVelocityWeighting", "1"); // Current velocity weighting
user_pref("general.smoothScroll.stopDecelerationWeighting", "1"); // Stop deceleration weighting
user_pref("mousewheel.default.delta_multiplier_y", 300); // Mousewheel scroll speed
