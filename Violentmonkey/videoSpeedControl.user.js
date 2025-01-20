// ==UserScript==
// @name         Video Speed Control
// @namespace    Violentmonkey Scripts
// @homepage     https://github.com/fahim-ahmed05/dotfiles
// @version      1.9
// @description  Control video speed (1x to 3x) with keyboard shortcuts on Meta sites, X, Rumble, TikTok, etc.
// @author       Fahim Ahmed
// @match        *://*.facebook.com/*
// @match        *://*.messenger.com/*
// @match        *://*.instagram.com/*
// @match        *://*.threads.net/*
// @match        *://*.twitter.com/*
// @match        *://*.x.com/*
// @match        *://*.rumble.com/*
// @match        *://*.tiktok.com/*
// @match        *://*.patreon.com/*
// @match        *://*.bitchute.com/*
// @match        *://*.substack.com/*
// @match        *://*.linkedin.com/*
// @downloadURL  https://github.com/fahim-ahmed05/dotfiles/raw/main/Violentmonkey/videoSpeedControl.user.js
// @updateURL    https://github.com/fahim-ahmed05/dotfiles/raw/main/Violentmonkey/videoSpeedControl.user.js
// @grant        none
// ==/UserScript==

(function () {
    'use strict';

    // Default speed and limits
    let currentSpeed = 2; // Default speed
    const minSpeed = 1;   // Minimum allowed speed
    const maxSpeed = 3;   // Maximum allowed speed

    // URLs using setInterval or MutationObserver
    const useSetInterval = [
        'facebook.com/reel/'
    ];
    const useMutationObserver = [
    ];

    // Function to set the playback speed for a video
    function setSpeed(video) {
        if (video && video.playbackRate !== currentSpeed) {
            video.playbackRate = currentSpeed;
        }
    }

    // Function to apply the current speed to all video elements
    function applySpeedToVideos() {
        document.querySelectorAll('video').forEach(setSpeed);
    }

    // Listen for new videos starting to play and apply speed
    document.body.addEventListener(
        'play',
        (e) => {
            if (e.target.tagName === 'VIDEO') {
                setSpeed(e.target);
            }
        },
        true
    );

    // Adjust speed with keyboard shortcuts
    window.addEventListener('keydown', (e) => {
        if (e.altKey) {
            switch (e.key) {
                case '1': // Alt+1: Reset to 1x speed
                    currentSpeed = 1;
                    break;
                case '2': // Alt+2: Reset to 2x speed
                    currentSpeed = 2;
                    break;
                case '3': // Alt+3: Decrease speed
                    currentSpeed = Math.max(currentSpeed - 0.25, minSpeed);
                    break;
                case '4': // Alt+4: Increase speed
                    currentSpeed = Math.min(currentSpeed + 0.25, maxSpeed);
                    break;
                default:
                    return; // Exit if the key is not recognized
            }
            applySpeedToVideos();
        }
    });

    // Helper to check if the current URL matches specific patterns
    function matchesURL(patterns) {
        return patterns.some(pattern => window.location.href.includes(pattern));
    }

    // Determine which method to use
    if (matchesURL(useSetInterval)) {
        // Use setInterval for specified URLs
        setInterval(applySpeedToVideos, 2000);
    } else if (matchesURL(useMutationObserver)) {
        // Use MutationObserver for specified URLs
        const observer = new MutationObserver(() => {
            applySpeedToVideos();
        });

        observer.observe(document.body, {
            childList: true,
            subtree: true
        });
    }

    // Apply the initial speed
    applySpeedToVideos();
})();
