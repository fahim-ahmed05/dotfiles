// ==UserScript==
// @name         Video Speed 2x for Meta sites, X, Rumble, TikTok etc
// @namespace    Violentmonkey Scripts
// @homepage     https://github.com/fahim-ahmed05/dotfiles
// @version      1.1
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

    // Detect browser
    const isFirefox = navigator.userAgent.includes('Firefox');

    // Define shortcuts based on browser
    const shortcuts = isFirefox
        ? { speed1: { key: ',', modifier: 'ctrlKey' }, speed2: { key: '.', modifier: 'ctrlKey' } }
        : { speed1: { key: '1', modifier: 'altKey' }, speed2: { key: '2', modifier: 'altKey' } };

    // Observe for video elements being added
    const observer = new MutationObserver(() => setSpeed());

    observer.observe(document.body, { childList: true, subtree: true });

    // Set the initial speed
    setSpeed();

    // Shortcut keys for toggling speed
    window.addEventListener('keydown', function (e) {
        if (e[shortcuts.speed1.modifier] && e.key === shortcuts.speed1.key) {
            currentSpeed = 1;
            setSpeed();
        } else if (e[shortcuts.speed2.modifier] && e.key === shortcuts.speed2.key) {
            currentSpeed = 2;
            setSpeed();
        }
    });
})();
