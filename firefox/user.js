// =========================
// GENERAL PERFORMANCE
// =========================
user_pref("content.notify.interval", 100000);
user_pref("browser.sessionstore.interval", 60000);
user_pref("browser.sessionhistory.max_total_viewers", 4);

// =========================
// GRAPHICS & RENDERING
// =========================
user_pref("gfx.canvas.accelerated.cache-size", 512);
user_pref("gfx.content.skia-font-cache-size", 20);

// =========================
// CACHE & MEDIA BUFFER
// =========================
user_pref("browser.cache.disk.enable", false);
user_pref("media.memory_cache_max_size", 65536);
user_pref("media.cache_readahead_limit", 7200);
user_pref("media.cache_resume_threshold", 3600);
user_pref("image.mem.decode_bytes_at_a_time", 32768);

// =========================
// NETWORK CONFIGURATION
// =========================
user_pref("network.http.max-connections", 1800);
user_pref("network.http.max-persistent-connections-per-server", 10);
user_pref("network.http.max-urgent-start-excessive-connections-per-host", 5);
user_pref("network.http.pacing.requests.enabled", false);
user_pref("network.dnsCacheExpiration", 3600);
user_pref("network.ssl_tokens_cache_capacity", 10240);

// =========================
// DNS-OVER-HTTPS & IPv6
// =========================
user_pref("network.trr.mode", 3);
user_pref("network.trr.uri", "https://dns.adguard-dns.com/dns-query");
user_pref("network.trr.custom_uri", "https://dns.adguard-dns.com/dns-query");
user_pref("network.trr.bootstrapAddress", "94.140.14.14");
user_pref("network.dns.disableIPv6", true);

// =========================
// SPECULATIVE CONNECTIONS
// =========================
user_pref("network.http.speculative-parallel-limit", 0);
user_pref("network.dns.disablePrefetch", true);
user_pref("network.dns.disablePrefetchFromHTTPS", true);
user_pref("browser.urlbar.speculativeConnect.enabled", false);
user_pref("browser.places.speculativeConnect.enabled", false);
user_pref("network.prefetch-next", false);
user_pref("network.predictor.enabled", false);

// =========================
// SECURITY & PRIVACY SETTINGS
// =========================
user_pref("dom.security.https_only_mode", true);
user_pref("security.mixed_content.block_display_content", true);
user_pref("browser.helperApps.deleteTempFileOnExit", true);
user_pref("browser.privatebrowsing.resetPBM.enabled", true);
user_pref("network.auth.subresource-http-auth-allow", 1);

// =========================
// ENHANCED PRIVACY FEATURES
// =========================
user_pref("privacy.globalprivacycontrol.enabled", true);
user_pref("network.cookie.cookieBehavior", 1);
user_pref("privacy.trackingprotection.enabled", true);
user_pref("privacy.trackingprotection.pbmode.enabled", true);
user_pref("privacy.trackingprotection.cryptomining.enabled", true);
user_pref("privacy.trackingprotection.fingerprinting.enabled", true);
user_pref("privacy.trackingprotection.fingerprinting.probable.enabled", true);
user_pref("network.http.referer.XOriginTrimmingPolicy", 2);

// =========================
// SSL/TLS & CERTIFICATES
// =========================
user_pref("security.ssl.treat_unsafe_negotiation_as_broken", true);
user_pref("browser.xul.error_pages.expert_bad_cert", true);
user_pref("security.tls.enable_0rtt_data", false);
user_pref("security.OCSP.enabled", 0);
user_pref("security.pki.crlite_mode", 2);

// =========================
// EXPERIMENTAL FEATURES
// =========================
user_pref("layout.css.grid-template-masonry-value.enabled", true);

// =========================
// TELEMETRY & DATA COLLECTION
// =========================
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

// =========================
// BROWSER BEHAVIOR & UI
// =========================
user_pref("browser.tabs.loadBookmarksInBackground", true);
user_pref("browser.tabs.hoverPreview.enabled", true);
user_pref("browser.tabs.closeWindowWithLastTab", true);
user_pref("browser.formfill.enable", false);
user_pref("places.history.enabled", true);
user_pref("privacy.history.custom", true);
user_pref("browser.privatebrowsing.forceMediaMemoryCache", true);

// =========================
// SMOOTH SCROLLING
// =========================
user_pref("apz.overscroll.enabled", true);
user_pref("general.smoothScroll", true);
user_pref("general.smoothScroll.msdPhysics.enabled", true);
user_pref("general.smoothScroll.msdPhysics.continuousMotionMaxDeltaMS", 12);
user_pref("general.smoothScroll.msdPhysics.motionBeginSpringConstant", 600);
user_pref("general.smoothScroll.msdPhysics.regularSpringConstant", 650);
user_pref("general.smoothScroll.msdPhysics.slowdownMinDeltaMS", 25);
user_pref("general.smoothScroll.msdPhysics.slowdownMinDeltaRatio", "2");
user_pref("general.smoothScroll.msdPhysics.slowdownSpringConstant", 250);
user_pref("general.smoothScroll.currentVelocityWeighting", "1");
user_pref("general.smoothScroll.stopDecelerationWeighting", "1");
user_pref("mousewheel.default.delta_multiplier_y", 300);

// =========================
// PERMISSIONS DEFAULTS
// =========================
user_pref("permissions.default.xr", 2);
user_pref("permissions.default.desktop-notification", 2);
user_pref("permissions.default.geo", 2);
user_pref("permissions.default.camera", 2);
user_pref("permissions.default.microphone", 2);
user_pref("permissions.manager.defaultsUrl", "");
user_pref("media.autoplay.default", 5);

// =========================
// UI & ACCESSIBILITY
// =========================
user_pref("browser.urlbar.update2.engineAliasRefresh", true);
user_pref("layout.word_select.eat_space_to_next_word", false);
user_pref("browser.bookmarks.openInTabClosesMenu", false);
user_pref("ui.key.menuAccessKeyFocuses", false);
user_pref("findbar.highlightAll", true);
user_pref("browser.search.separatePrivateDefault.ui.enabled", true);
user_pref("editor.truncate_user_pastes", false);

// =========================
// FULLSCREEN BEHAVIOR
// =========================
user_pref("full-screen-api.transition-duration.enter", "0 0");
user_pref("full-screen-api.transition-duration.leave", "0 0");
user_pref("full-screen-api.warning.timeout", 0);

// =========================
// CONTAINERS
// =========================
user_pref("privacy.userContext.ui.enabled", true);

// =========================
// NEW TAB PAGE & HOMEPAGE
// =========================
user_pref("browser.newtabpage.activity-stream.default.sites", "");
user_pref("browser.newtabpage.activity-stream.showSponsoredTopSites", false);
user_pref("browser.newtabpage.activity-stream.feeds.section.topstories", false);
user_pref("browser.newtabpage.activity-stream.showSponsored", false);
user_pref("browser.newtabpage.activity-stream.system.showWeather", true);
user_pref("browser.aboutwelcome.enabled", false);
user_pref("startup.homepage_welcome_url", "");
user_pref("startup.homepage_welcome_url.additional", "");
user_pref("browser.firefox-view.feature-tour", "{\"screen\":\"\",\"complete\":true}");

// =========================
// DOWNLOADS
// =========================
user_pref("browser.download.manager.addToRecentDocs", false);
user_pref("browser.download.alwaysOpenPanel", false);
user_pref("browser.download.always_ask_before_handling_new_types", false);
user_pref("browser.safebrowsing.downloads.remote.enabled", false);
user_pref("browser.download.start_downloads_in_tmp_dir", true);
user_pref("browser.download.open_pdf_attachments_inline", false);

// =========================
// PDF VIEWER
// =========================
user_pref("pdfjs.enableScripting", false);

// =========================
// MOZILLA EXPERIMENTS & PROMOTIONS
// =========================
user_pref("app.shield.optoutstudies.enabled", false);
user_pref("app.normandy.enabled", false);
user_pref("app.normandy.api_url", "");
user_pref("browser.uitour.enabled", false);
user_pref("browser.privatebrowsing.vpnpromourl", "");
user_pref("extensions.getAddons.showPane", false);
user_pref("extensions.htmlaboutaddons.recommendations.enabled", false);
user_pref("extensions.getAddons.cache.enabled", false);
user_pref("browser.discovery.enabled", false);
user_pref("browser.shell.checkDefaultBrowser", false);
user_pref("browser.newtabpage.activity-stream.asrouter.userprefs.cfr.addons", false);
user_pref("browser.newtabpage.activity-stream.asrouter.userprefs.cfr.features", false);
user_pref("browser.search.update", false);
user_pref("browser.aboutConfig.showWarning", false);
user_pref("browser.preferences.experimental.hidden", false);
user_pref("browser.preferences.moreFromMozilla", false);
user_pref("signon.firefoxRelay.feature", false);

// =========================
// PICTURE-IN-PICTURE
// =========================
user_pref("media.videocontrols.picture-in-picture.enable-when-switching-tabs.enabled", true);

// =========================
// THEME & CUSTOMIZATION
// =========================
user_pref("widget.windows.mica", true);
user_pref("toolkit.legacyUserProfileCustomizations.stylesheets", true);