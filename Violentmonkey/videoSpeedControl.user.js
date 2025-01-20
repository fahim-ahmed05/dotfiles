// ==UserScript==
// @name         Video Speed Control
// @namespace    Violentmonkey Scripts
// @homepage     https://github.com/fahim-ahmed05/dotfiles
// @version      1.7
// @description  Control video speed (1x to 5x) with keyboard shortcuts on Meta sites, X, Rumble, TikTok, etc.
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
    let currentSpeed = 2;
    const minSpeed = 1;
    const maxSpeed = 3;

    // Function to set video speed
    function setSpeed(video) {
        if (video && video.playbackRate !== currentSpeed) {
            video.playbackRate = currentSpeed;
        }
    }

    // Function to apply speed to video
    function applySpeedToVideo() {
        const videos = document.querySelectorAll('video');
        videos.forEach(video => setSpeed(video));
    }

    // Re-apply speed periodically (in case of dynamic content)
    setInterval(() => applySpeedToVideo(), 2000);

    // Apply speed when video starts playing
    document.body.addEventListener(
        'play',
        (e) => {
            if (e.target.tagName === 'VIDEO') {
                setSpeed(e.target);
            }
        },
        true
    );

    // Set initial speed
    applySpeedToVideo();

    // Shortcut keys for adjusting speed
    window.addEventListener('keydown', function (e) {
        if (e.altKey && e.key === '3') {
            currentSpeed = Math.max(currentSpeed - 0.25, minSpeed);
            applySpeedToVideo();
        } else if (e.altKey && e.key === '4') {
            currentSpeed = Math.min(currentSpeed + 0.25, maxSpeed);
            applySpeedToVideo();
        } else if (e.altKey && e.key === '1') {
            currentSpeed = 1;
            applySpeedToVideo();
        } else if (e.altKey && e.key === '2') {
            currentSpeed = 2;
            applySpeedToVideo();
        }
    });
})();
