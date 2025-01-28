// ==UserScript==
// @name         Video Speed Control
// @namespace    Violentmonkey Scripts
// @homepage     https://github.com/fahim-ahmed05/dotfiles
// @version      2.5
// @description  Control video speed (1x to 5x) with keyboard shortcuts.
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
    const maxSpeed = 5;

    // Function to set video speed
    function setSpeed(video) {
        if (video && video.playbackRate !== currentSpeed) {
            video.playbackRate = currentSpeed;
        }
    }

    // Function to apply speed to all videos
    function applySpeedToAllVideos() {
        const videos = document.querySelectorAll('video');
        videos.forEach(video => setSpeed(video));
    }

    // Detect browser
    const isFirefox = navigator.userAgent.includes('Firefox');

    // Define shortcuts based on browser
    const shortcuts = isFirefox
        ? {
              decrease: { key: ',', modifier: 'altKey' },
              increase: { key: '.', modifier: 'altKey' },
              toggle1x: { key: ',', modifier: 'ctrlKey' },
              toggle2x: { key: '.', modifier: 'ctrlKey' }
          }
        : {
              decrease: { key: '3', modifier: 'altKey' },
              increase: { key: '4', modifier: 'altKey' },
              toggle1x: { key: '1', modifier: 'altKey' },
              toggle2x: { key: '2', modifier: 'altKey' }
          };

    // Observe for video elements being added
    const observer = new MutationObserver(() => applySpeedToAllVideos());
    observer.observe(document.body, { childList: true, subtree: true });

    // Re-apply speed periodically (in case of dynamic content)
    setInterval(() => applySpeedToAllVideos(), 2000);

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
    applySpeedToAllVideos();

    // Shortcut keys for adjusting speed
    window.addEventListener('keydown', function (e) {
        if (e[shortcuts.decrease.modifier] && e.key === shortcuts.decrease.key) {
            currentSpeed = Math.max(currentSpeed - 0.25, minSpeed);
            applySpeedToAllVideos();
            console.log(`Speed decreased to: ${currentSpeed.toFixed(2)}x`);
        } else if (e[shortcuts.increase.modifier] && e.key === shortcuts.increase.key) {
            currentSpeed = Math.min(currentSpeed + 0.25, maxSpeed);
            applySpeedToAllVideos();
            console.log(`Speed increased to: ${currentSpeed.toFixed(2)}x`);
        } else if (e[shortcuts.toggle1x.modifier] && e.key === shortcuts.toggle1x.key) {
            currentSpeed = 1;
            applySpeedToAllVideos();
            console.log('Speed set to: 1x');
        } else if (e[shortcuts.toggle2x.modifier] && e.key === shortcuts.toggle2x.key) {
            currentSpeed = 2;
            applySpeedToAllVideos();
            console.log('Speed set to: 2x');
        }
    });
})();