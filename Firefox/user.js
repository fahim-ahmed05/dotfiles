// General
user_pref("content.notify.interval", 100000);

// GFX
user_pref("gfx.canvas.accelerated.cache-items", 4096);
user_pref("gfx.canvas.accelerated.cache-size", 512);
user_pref("gfx.content.skia-font-cache-size", 20);
user_pref("media.av1.enabled", true);
user_pref("gfx.canvas.accelerated", true);
user_pref("image.jxl.enabled", false);

// Cache
user_pref("browser.cache.jsbc_compression_level", 3);
user_pref("media.memory_cache_max_size", 65536);
user_pref("media.cache_readahead_limit", 7200);
user_pref("media.cache_resume_threshold", 3600);
user_pref("image.mem.decode_bytes_at_a_time", 32768);
user_pref("browser.sessionhistory.max_total_viewers", 4);
user_pref("network.dnsCacheEntries", 1000);

// Network
user_pref("network.http.max-connections", 1800);
user_pref("network.http.max-persistent-connections-per-server", 10);
user_pref("network.http.max-urgent-start-excessive-connections-per-host", 5);
user_pref("network.http.pacing.requests.enabled", false);
user_pref("network.dnsCacheExpiration", 3600);
user_pref("network.ssl_tokens_cache_capacity", 10240);
user_pref("network.trr.mode", 2);
user_pref("network.trr.custom_uri", "https://dns.adguard-dns.com/dns-query");
user_pref("network.dns.disableIPv6", true);

// Prefetch
user_pref("network.dns.disablePrefetch", true);
user_pref("network.dns.disablePrefetchFromHTTPS", true);
user_pref("network.prefetch-next", false);
user_pref("network.predictor.enabled", false);
user_pref("network.predictor.enable-prefetch", false);

// Experimental
user_pref("layout.css.grid-template-masonry-value.enabled", true);
user_pref("dom.enable_web_task_scheduling", true);
user_pref("dom.security.sanitizer.enabled", true);

// Telemetry
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
user_pref("toolkit.coverage.opt-out", true);
user_pref("toolkit.coverage.endpoint.base", "");
user_pref("browser.newtabpage.activity-stream.feeds.telemetry", false);
user_pref("browser.newtabpage.activity-stream.telemetry", false);
user_pref("breakpad.reportURL", "");
user_pref("browser.tabs.crashReporting.sendReport", false);
user_pref("browser.crashReports.unsubmittedCheck.autoSubmit2", false);
user_pref("browser.shopping.experience2023.enabled", false);
user_pref("browser.shopping.experience2023.ads.exposure", false);
user_pref("app.shield.optoutstudies.enabled", false);
user_pref("app.normandy.enabled", false);
user_pref("app.normandy.api_url", "");
user_pref("default-browser-agent.enabled", false);

// UI
user_pref("browser.privatebrowsing.vpnpromourl", "");
user_pref("extensions.getAddons.showPane", false);
user_pref("extensions.htmlaboutaddons.recommendations.enabled", false);
user_pref("browser.discovery.enabled", false);
user_pref("browser.shell.checkDefaultBrowser", false);
user_pref("browser.newtabpage.activity-stream.asrouter.userprefs.cfr.addons", false);
user_pref("browser.newtabpage.activity-stream.asrouter.userprefs.cfr.features", false);
user_pref("browser.preferences.moreFromMozilla", false);
user_pref("browser.aboutConfig.showWarning", false);
user_pref("browser.aboutwelcome.enabled", false);
user_pref("browser.tabs.loadBookmarksInBackground", true);
user_pref("toolkit.legacyUserProfileCustomizations.stylesheets", true);
user_pref("browser.compactmode.show", true);
user_pref("full-screen-api.warning.delay", -1);
user_pref("full-screen-api.warning.timeout", 0);
user_pref("browser.messaging-system.whatsNewPanel.enabled", false);
user_pref("browser.startup.homepage_override.mstone", "ignore");
user_pref("browser.profiles.enabled", true);
user_pref("browser.privateWindowSeparation.enabled", false);
user_pref("browser.menu.showViewImageInfo", true);
user_pref("browser.zoom.full", true);
user_pref("browser.urlbar.showSearchSuggestionsFirst", true);

// Tab
user_pref("browser.tabs.hoverPreview.enabled", true);
user_pref("browser.tabs.hoverPreview.showThumbnails", true);
user_pref("browser.tabs.tabmanager.enabled", false);

// URL Bar
user_pref("browser.urlbar.suggest.calculator", true);
user_pref("browser.urlbar.unitConversion.enabled", true);
user_pref("browser.urlbar.trimURLs", true);
user_pref("browser.urlbar.trimHttps", true);
user_pref("browser.urlbar.untrimOnUserInteraction.featureGate", true);

// Settings
user_pref("browser.urlbar.update2.engineAliasRefresh", true);
user_pref("permissions.default.desktop-notification", 2);
user_pref("browser.download.manager.addToRecentDocs", false);

// Translation
user_pref("browser.translations.enable", true);
user_pref("browser.translations.autoTranslate", true);

// Cookie Banner
user_pref("cookiebanners.service.mode", 1);
user_pref("cookiebanners.service.mode.privateBrowsing", 1);

// Font
user_pref("gfx.webrender.quality.force-subpixel-aa-where-possible", true);
user_pref("gfx.font_rendering.cleartype_params.rendering_mode", 5);
user_pref("gfx.font_rendering.cleartype_params.cleartype_level", 100);
user_pref("gfx.font_rendering.cleartype_params.force_gdi_classic_for_families", "");
user_pref("gfx.font_rendering.cleartype_params.force_gdi_classic_max_size", 6);
user_pref("gfx.font_rendering.directwrite.use_gdi_table_loading", false);
user_pref("gfx.font_rendering.cleartype_params.gamma", 1750);
user_pref("gfx.font_rendering.cleartype_params.enhanced_contrast", 100);
user_pref("gfx.font_rendering.cleartype_params.pixel_structure", 1)
user_pref("dom.text_fragments.enabled", true);

// Scrolling
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

// Privacy
user_pref("extensions.postDownloadThirdPartyPrompt", false);
user_pref("security.mixed_content.block_display_content", true);
user_pref("pdfjs.enableScripting", false);
user_pref("dom.security.https_first", true);
user_pref("browser.contentblocking.category", "strict");
user_pref("urlclassifier.trackingSkipURLs", "*.reddit.com, *.twitter.com, *.twimg.com, *.tiktok.com");
user_pref("urlclassifier.features.socialtracking.skipURLs", "*.instagram.com, *.twitter.com, *.twimg.com");
user_pref("network.cookie.sameSite.noneRequiresSecure", true);
user_pref("browser.download.start_downloads_in_tmp_dir", true);
user_pref("browser.helperApps.deleteTempFileOnExit", true);
user_pref("browser.uitour.enabled", false);
user_pref("privacy.globalprivacycontrol.enabled", true);
user_pref("security.OCSP.enabled", 0);
user_pref("security.remote_settings.crlite_filters.enabled", true);
user_pref("security.pki.crlite_mode", 2);
user_pref("security.ssl.treat_unsafe_negotiation_as_broken", true);
user_pref("browser.xul.error_pages.expert_bad_cert", true);
user_pref("security.tls.enable_0rtt_data", false);
user_pref("media.peerconnection.ice.proxy_only_if_behind_proxy", true);
user_pref("media.peerconnection.ice.default_address_only", true);
user_pref("browser.safebrowsing.downloads.remote.enabled", false);

// Extensions
user_pref("extensions.enabledScopes", 5);