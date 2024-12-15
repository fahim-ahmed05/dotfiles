// ==UserScript==
// @name         Video Speed 2x for Meta sites, X, Rumble, TikTok etc
// @namespace    Violentmonkey Scripts
// @homepage     https://github.com/fahim-ahmed05/dotfiles
// @version      1.0
// @description  Automatically sets video speed to 2x on Meta sites, X, Rumble, TikTok etc. Allows toggling between 1x and 2x speed using shortcuts.
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
// @downloadURL  https://github.com/fahim-ahmed05/dotfiles/raw/main/Violentmonkey/videoSpeed2xFirefox.user.js
// @updateURL    https://github.com/fahim-ahmed05/dotfiles/raw/main/Violentmonkey/videoSpeed2xFirefox.user.js
// @grant        none
// ==/UserScript==

(function () {
    'use strict';

    // Default speed
    let currentSpeed = 2;

    // Function to set video speed
    function setSpeed() {
        const videos = document.querySelectorAll('video');
        videos.forEach(video => {
            if (video.playbackRate !== currentSpeed) {
                video.playbackRate = currentSpeed;
            }
        });
    }

    // Observe for video elements being added
    const observer = new MutationObserver(() => setSpeed());

    observer.observe(document.body, { childList: true, subtree: true });

    // Set the initial speed
    setSpeed();

    // Shortcut keys for toggling speed
    window.addEventListener('keydown', function (e) {
        if (e.ctrlKey && e.key === ',') {
            currentSpeed = 1;
            setSpeed();
        } else if (e.ctrlKey && e.key === '.') {
            currentSpeed = 2;
            setSpeed();
        }
    });
})();
