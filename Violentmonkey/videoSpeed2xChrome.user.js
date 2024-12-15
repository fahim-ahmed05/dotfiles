// ==UserScript==
// @name         Video Speed 2x for Meta sites, X, Rumble, TikTok etc
// @namespace    Violentmonkey Scripts
// @homepage     https://github.com/fahim-ahmed05/dotfiles
// @version      1.9
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
// @downloadURL  https://github.com/fahim-ahmed05/dotfiles/raw/main/Violentmonkey/videoSpeed2xChrome.user.js
// @updateURL    https://github.com/fahim-ahmed05/dotfiles/raw/main/Violentmonkey/videoSpeed2xChrome.user.js
// @grant        none
// ==/UserScript==

(function() {
    'use strict';

    // Default speed
    let currentSpeed = 2;

    function setSpeed() {
        const videos = document.querySelectorAll('video');
        videos.forEach(video => {
            video.playbackRate = currentSpeed;
        });
    }

    // Observe for changes
    const observer = new MutationObserver((mutations) => {
        mutations.forEach((mutation) => {
            if (mutation.addedNodes.length || mutation.type === 'attributes') {
                setSpeed();
            }
        });
    });

    observer.observe(document.body, { childList: true, subtree: true, attributes: true });

    setSpeed();

    // Listen for the shortcut keys
    window.addEventListener('keydown', function(e) {
        if (e.altKey && e.key === '1') {
            currentSpeed = 1;
            setSpeed();
        } else if (e.altKey && e.key === '2') {
            currentSpeed = 2;
            setSpeed();
        } else if (e.altKey && e.key === '3') {
            currentSpeed = 3;
            setSpeed();
        }
    });
})();
