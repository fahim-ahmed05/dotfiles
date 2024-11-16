// =============================================
// General Settings
// =============================================
user_pref("content.notify.interval", 100000); // Set content notification interval

// =============================================
// Graphics (GFX) Settings
// =============================================
user_pref("gfx.canvas.accelerated.cache-items", 4096); // Canvas cache items for acceleration
user_pref("gfx.canvas.accelerated.cache-size", 512); // Canvas cache size for acceleration
user_pref("gfx.content.skia-font-cache-size", 20); // Skia font cache size
user_pref("media.av1.enabled", true); // Enable AV1 video codec
user_pref("gfx.canvas.accelerated", true); // Enable canvas acceleration
// user_pref("image.jxl.enabled", false); // Disable JPEG XL support

// =============================================
// Cache Settings
// =============================================
user_pref("browser.cache.jsbc_compression_level", 3); // JavaScript bytecode cache compression level
user_pref("media.memory_cache_max_size", 65536); // Maximum size for media memory cache
user_pref("media.cache_readahead_limit", 7200); // Media cache read-ahead limit
user_pref("media.cache_resume_threshold", 3600); // Media cache resume threshold
user_pref("image.mem.decode_bytes_at_a_time", 32768); // Image decode bytes at a time
user_pref("browser.sessionhistory.max_total_viewers", 4); // Max session history viewers
user_pref("network.dnsCacheEntries", 1000); // DNS cache entries

// =============================================
// Network Settings
// =============================================
user_pref("network.http.max-connections", 1800); // Maximum HTTP connections
user_pref("network.http.max-persistent-connections-per-server", 10); // Max persistent connections per server
user_pref("network.http.max-urgent-start-excessive-connections-per-host", 5); // Max urgent start excessive connections
user_pref("network.http.pacing.requests.enabled", false); // Disable HTTP request pacing
user_pref("network.dnsCacheExpiration", 3600); // DNS cache expiration time
user_pref("network.ssl_tokens_cache_capacity", 10240); // SSL tokens cache capacity
user_pref("network.trr.mode", 3); // Use DNS over HTTPS (DoH) as primary resolver
user_pref("network.trr.uri", "https://base.dns.mullvad.net/dns-query"); // Mullvad DoH URI
user_pref("network.trr.custom_uri", "https://base.dns.mullvad.net/dns-query"); // Custom Mullvad DoH URI
user_pref("network.dns.disableIPv6", true); // Disable IPv6 for DNS resolution
user_pref("network.trr.bootstrapAddress", "194.242.2.4"); // Mullvad IP for DoH bootstrap

// =============================================
// Prefetching Settings
// =============================================
user_pref("network.dns.disablePrefetch", true); // Disable DNS prefetching
user_pref("network.dns.disablePrefetchFromHTTPS", true); // Disable HTTPS DNS prefetching
user_pref("network.prefetch-next", false); // Disable link prefetching
user_pref("network.predictor.enabled", false); // Disable network predictor
user_pref("network.predictor.enable-prefetch", false); // Disable predictor prefetching

// =============================================
// Experimental Settings
// =============================================
user_pref("layout.css.grid-template-masonry-value.enabled", true); // Enable CSS masonry layout
user_pref("dom.enable_web_task_scheduling", true); // Enable web task scheduling
user_pref("dom.security.sanitizer.enabled", true); // Enable DOM sanitizer for security

// =============================================
// Telemetry & Data Collection
// =============================================
user_pref("datareporting.policy.dataSubmissionEnabled", false); // Disable data submission
user_pref("datareporting.healthreport.uploadEnabled", false); // Disable health report upload
user_pref("toolkit.telemetry.unified", false); // Disable unified telemetry
user_pref("toolkit.telemetry.enabled", false); // Disable telemetry
user_pref("toolkit.telemetry.server", "data:,"); // Set empty server for telemetry
user_pref("toolkit.telemetry.archive.enabled", false); // Disable telemetry archive
user_pref("toolkit.telemetry.newProfilePing.enabled", false); // Disable new profile ping
user_pref("toolkit.telemetry.shutdownPingSender.enabled", false); // Disable shutdown ping sender
user_pref("toolkit.telemetry.updatePing.enabled", false); // Disable update ping
user_pref("toolkit.telemetry.bhrPing.enabled", false); // Disable browser hang report
user_pref("toolkit.telemetry.firstShutdownPing.enabled", false); // Disable first shutdown ping
user_pref("toolkit.telemetry.coverage.opt-out", true); // Opt-out of telemetry coverage
user_pref("toolkit.coverage.opt-out", true); // Opt-out of coverage studies
user_pref("toolkit.coverage.endpoint.base", ""); // Empty endpoint for coverage studies
user_pref("browser.newtabpage.activity-stream.feeds.telemetry", false); // Disable new tab telemetry
user_pref("browser.newtabpage.activity-stream.telemetry", false); // Disable activity stream telemetry
user_pref("breakpad.reportURL", ""); // Disable crash report URL
user_pref("browser.tabs.crashReporting.sendReport", false); // Disable crash reporting
user_pref("browser.crashReports.unsubmittedCheck.autoSubmit2", false); // Disable auto submit crash reports
user_pref("app.shield.optoutstudies.enabled", false); // Disable Shield studies
user_pref("app.normandy.enabled", false); // Disable Normandy experiments
user_pref("app.normandy.api_url", ""); // Empty Normandy API URL
user_pref("default-browser-agent.enabled", false); // Disable default browser agent

// =============================================
// User Interface (UI) Settings
// =============================================
user_pref("browser.privatebrowsing.vpnpromourl", ""); // Disable VPN promo in private browsing
user_pref("extensions.getAddons.showPane", false); // Hide add-ons pane
user_pref("extensions.htmlaboutaddons.recommendations.enabled", false); // Disable add-on recommendations
user_pref("browser.discovery.enabled", false); // Disable Discovery Pane
user_pref("browser.shell.checkDefaultBrowser", false); // Disable default browser check
user_pref("browser.newtabpage.activity-stream.asrouter.userprefs.cfr.addons", false); // Disable add-ons CFR
user_pref("browser.newtabpage.activity-stream.asrouter.userprefs.cfr.features", false); // Disable features CFR
user_pref("browser.preferences.moreFromMozilla", false); // Disable "More from Mozilla" in preferences
user_pref("browser.aboutConfig.showWarning", false); // Disable about:config warning
user_pref("browser.aboutwelcome.enabled", false); // Disable welcome page
user_pref("browser.tabs.loadBookmarksInBackground", true); // Load bookmarks in background
user_pref("toolkit.legacyUserProfileCustomizations.stylesheets", true); // Enable userChrome/userContent CSS
user_pref("browser.compactmode.show", true); // Enable compact mode option
user_pref("full-screen-api.warning.delay", -1); // Remove full-screen warning delay
user_pref("full-screen-api.warning.timeout", 0); // Remove full-screen warning timeout
user_pref("browser.messaging-system.whatsNewPanel.enabled", false); // Disable "What's New" panel
user_pref("browser.startup.homepage_override.mstone", "ignore"); // Ignore startup homepage override
user_pref("browser.profiles.enabled", true); // Enable profile management
user_pref("browser.privateWindowSeparation.enabled", false); // Disable private window separation
user_pref("browser.menu.showViewImageInfo", true); // Enable view image info option
user_pref("browser.zoom.full", true); // Enable full zoom
user_pref("browser.uitour.enabled", false); // Disable UITour

// =============================================
// Tab Settings
// =============================================
user_pref("browser.tabs.hoverPreview.enabled", true); // Enable tab hover preview
user_pref("browser.tabs.hoverPreview.showThumbnails", true); // Show thumbnails in tab hover
user_pref("browser.tabs.tabmanager.enabled", false); // Disable tab manager

// =============================================
// URL Bar Settings
// =============================================
user_pref("browser.urlbar.suggest.calculator", true); // Enable calculator in URL bar
user_pref("browser.urlbar.unitConversion.enabled", true); // Enable unit conversion in URL bar
user_pref("browser.urlbar.trimURLs", true); // Trim URLs in the address bar
user_pref("browser.urlbar.trimHttps", true); // Trim HTTPS in the address bar
user_pref("browser.urlbar.untrimOnUserInteraction.featureGate", true); // Untrim URL on interaction
user_pref("browser.privatebrowsing.searchSuggest", true); // Enable search suggestions in private window
user_pref("browser.urlbar.showSearchSuggestionsFirst", true); // Show search suggestions first
user_pref("browser.urlbar.update2.engineAliasRefresh", true); // Enable search engine alias refresh

// =============================================
// Download Settings
// =============================================
user_pref("permissions.default.desktop-notification", 2); // Block desktop notifications
user_pref("browser.download.manager.addToRecentDocs", false); // Do not add downloads to recent docs
user_pref("browser.download.useDownloadDir", true); // Do not ask where to download
user_pref("browser.download.dir", "C:\\Users\\Fahim\\Downloads\\Firefox"); // Download folder
user_pref("browser.helperApps.neverAsk.saveToDisk", "application/pdf"); // Set PDF to download automatically
user_pref("browser.download.promptForDownload", false); // Disable prompt for download location
// =============================================
// Translation Settings
// =============================================
user_pref("browser.translations.enable", true); // Enable in-browser translations
user_pref("browser.translations.autoTranslate", true); // Enable automatic translations

// =============================================
// Cookie Banner Handling
// =============================================
user_pref("cookiebanners.service.mode", 1); // Set cookie banner mode for normal browsing
user_pref("cookiebanners.service.mode.privateBrowsing", 1); // Set cookie banner mode for private browsing

// =============================================
// Font Rendering Settings
// =============================================
user_pref("gfx.webrender.quality.force-subpixel-aa-where-possible", true); // Force subpixel AA for WebRender
user_pref("gfx.font_rendering.cleartype_params.rendering_mode", 5); // Set ClearType rendering mode
user_pref("gfx.font_rendering.cleartype_params.cleartype_level", 100); // ClearType level
user_pref("gfx.font_rendering.cleartype_params.gamma", 1750); // ClearType gamma level
user_pref("gfx.font_rendering.cleartype_params.enhanced_contrast", 100); // ClearType enhanced contrast
user_pref("gfx.font_rendering.cleartype_params.pixel_structure", 1); // ClearType pixel structure
user_pref("dom.text_fragments.enabled", true); // Enable text fragments

// =============================================
// Scrolling Settings
// =============================================
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

// =============================================
// Privacy Settings
// =============================================
user_pref("extensions.postDownloadThirdPartyPrompt", false); // Disable third-party prompt after downloads
user_pref("security.mixed_content.block_display_content", true); // Block mixed display content
// user_pref("dom.security.https_first", true); // Enforce HTTPS first
user_pref("dom.security.https_only_mode", true); // Enable HTTPS-Only Mode in all windows
user_pref("dom.security.https_only_mode_pbm", true); // Enable HTTPS-Only Mode in private windows only
user_pref("network.cookie.sameSite.noneRequiresSecure", true); // Enforce secure sameSite cookies
user_pref("browser.download.start_downloads_in_tmp_dir", true); // Start downloads in temp directory
user_pref("browser.helperApps.deleteTempFileOnExit", true); // Delete temp files on exit
user_pref("privacy.globalprivacycontrol.enabled", true); // Enable Global Privacy Control
user_pref("security.OCSP.enabled", 0); // Disable OCSP
user_pref("security.remote_settings.crlite_filters.enabled", true); // Enable CRLite filters
user_pref("security.pki.crlite_mode", 2); // Set CRLite mode
user_pref("security.ssl.treat_unsafe_negotiation_as_broken", true); // Treat unsafe SSL negotiation as broken
user_pref("browser.xul.error_pages.expert_bad_cert", true); // Show expert options for bad certs
user_pref("security.tls.enable_0rtt_data", false); // Disable 0-RTT data
user_pref("media.peerconnection.ice.proxy_only_if_behind_proxy", true); // ICE only behind proxy
user_pref("media.peerconnection.ice.default_address_only", true); // ICE default address only
user_pref("browser.safebrowsing.downloads.remote.enabled", false); // Disable Safe Browsing for downloads
user_pref("browser.firefoxRelay.enabled", false); // Disable Firefox Relay suggestion

// =============================================
// Tracking Protection Settings
// =============================================
// user_pref("browser.contentblocking.category", "strict"); // Set content blocking to strict
user_pref("urlclassifier.trackingSkipURLs", "*.reddit.com, *.twitter.com, *.twimg.com, *.tiktok.com"); // Skip tracking for selected URLs
user_pref("urlclassifier.features.socialtracking.skipURLs", "*.instagram.com, *.twitter.com, *.twimg.com"); // Skip social tracking for selected URLs
user_pref("privacy.trackingprotection.mode", 3); // Enable Custom Enhanced Tracking Protection (ETP) mode
user_pref("privacy.trackingprotection.enabled", true); // Enable tracking protection
user_pref("privacy.trackingprotection.socialtracking.enabled", true); // Enable social tracking protection
user_pref("privacy.trackingprotection.cryptomining.enabled", true); // Enable cryptomining protection
user_pref("privacy.trackingprotection.fingerprinting.enabled", true); // Enable fingerprinting protection
user_pref("privacy.donottrackheader.enabled", true); // Send "Do Not Track" signal to websites
user_pref("privacy.trackingprotection.custom.cookies", 1); // Block third-party cookies
user_pref("privacy.trackingprotection.custom.cryptominers", 1); // Block cryptominers
user_pref("privacy.trackingprotection.custom.fingerprinters", 1); // Block fingerprinters
user_pref("network.cookie.cookieBehavior", 5); // Block third-party cookies

// =============================================
// Extension Settings
// =============================================
user_pref("extensions.enabledScopes", 5); // Restrict extension installation to user and application scopes

// =============================================
// Home Page Settings
// =============================================
user_pref("browser.startup.homepage", "about:blank");// Set homepage and new windows to a blank page
user_pref("browser.startup.page", 0); // 0 = Blank page, 1 = Homepage, 2 = Last visited page, 3 = Resume previous session
user_pref("browser.newtabpage.enabled", false); // Disable new tab page content
user_pref("browser.newtab.url", "about:blank"); // Set new tabs to a blank page
user_pref("browser.newtabpage.activity-stream.feeds.section.topstories", false); // Disable recommended stories
user_pref("browser.newtabpage.activity-stream.feeds.section.highlights", false); // Disable highlights
user_pref("browser.newtabpage.activity-stream.showSearch", false); // Disable search bar on new tab
user_pref("browser.newtabpage.activity-stream.feeds.topsites", false); // Disable shortcuts (top sites)
user_pref("browser.newtabpage.activity-stream.showSponsored", false); // Disable sponsored shortcuts
user_pref("browser.newtabpage.activity-stream.feeds.recent", false); // Disable recent activity (visited pages, bookmarks, downloads)
user_pref("browser.newtabpage.activity-stream.showRecentSaves", false); // Disable Pocket saves in recent activity
user_pref("browser.newtabpage.activity-stream.newtabWallpapers.enabled", false); // Disable wallpapers on New Tab
user_pref("browser.newtabpage.activity-stream.default.sites", ""); // Clear default topsites
// user_pref("browser.toolbars.bookmarks.visibility", "always"); // Bookmarks Toolbar visibility

// =============================================
// Site Permission Settings
// =============================================
user_pref("media.autoplay.default", 5); // 0 = Allow all, 1 = Block non-muted media (default), 5 = Block all
user_pref("permissions.default.geo", 2); // Disable location access
user_pref("permissions.default.camera", 2); // Disable camera access
user_pref("permissions.default.microphone", 2); // Disable microphone access
user_pref("permissions.default.xr", 2); // Block requests for XR (Extended Reality) device access

// =============================================
// Virtual Reality (VR) Settings
// =============================================

user_pref("dom.vr.enabled", false); // Disable Virtual Reality (VR) support
user_pref("dom.webvr.enabled", false); // Disable WebVR support
user_pref("dom.webxr.enabled", false); // Disable WebXR support (for AR/VR devices)

// =============================================
// PDF Settings
// =============================================
user_pref("pdfjs.disabled", true);
user_pref("pdfjs.enableScripting", false); // Disable PDF scripting

// =============================================
// Firefox Labs Settings
// =============================================
// user_pref("browser.tabs.firefox-view-labs.enabled", true); // Enable Firefox Labs features
// user_pref("media.videocontrols.picture-in-picture.auto-toggle", true); // Enable Picture-in-Picture to auto-open on tab switch
// user_pref("browser.tabs.firefox-view-labs.ai_chatbot.enabled", true); // Enable AI Chatbot (ChatGPT integration, if available in Firefox Labs)
// user_pref("browser.tabs.firefox-view-labs.ai_chatbot.show_prompts_on_text_select", false); // Disable "Show prompts on text select" for the AI Chatbot
// user_pref("image.jxl.enabled", true); // Enable JPEG-XL support in Firefox