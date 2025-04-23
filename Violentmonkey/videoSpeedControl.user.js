// ==UserScript==
// @name         Video Speed Control
// @namespace    Violentmonkey Scripts
// @homepage     https://github.com/fahim-ahmed05/dotfiles
// @version      2.7
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
// @match        *://*.preservetube.com/*
// @downloadURL  https://github.com/fahim-ahmed05/dotfiles/raw/main/Violentmonkey/videoSpeedControl.user.js
// @updateURL    https://github.com/fahim-ahmed05/dotfiles/raw/main/Violentmonkey/videoSpeedControl.user.js
// @grant        none
// ==/UserScript==

(function () {
    'use strict';

    let currentSpeed = 2;
    const minSpeed = 1;
    const maxSpeed = 5;

    const speedOverlay = document.createElement('div');
    speedOverlay.style.position = 'fixed';
    speedOverlay.style.top = '10%';
    speedOverlay.style.left = '50%';
    speedOverlay.style.transform = 'translateX(-50%)';
    speedOverlay.style.padding = '10px 20px';
    speedOverlay.style.background = 'rgba(0, 0, 0, 0.7)';
    speedOverlay.style.color = 'white';
    speedOverlay.style.fontSize = '24px';
    speedOverlay.style.borderRadius = '8px';
    speedOverlay.style.zIndex = '99999';
    speedOverlay.style.display = 'none';
    speedOverlay.style.pointerEvents = 'none';
    document.body.appendChild(speedOverlay);

    let overlayTimeout;

    function showSpeedOverlay() {
        speedOverlay.textContent = `Speed: ${currentSpeed.toFixed(2)}x`;
        speedOverlay.style.display = 'block';

        clearTimeout(overlayTimeout);
        overlayTimeout = setTimeout(() => {
            speedOverlay.style.display = 'none';
        }, 1000);
    }

    function setSpeed(video) {
        if (video && video.playbackRate !== currentSpeed) {
            video.playbackRate = currentSpeed;
        }
    }

    function applySpeedToAllVideos() {
        const videos = document.querySelectorAll('video');
        videos.forEach(video => setSpeed(video));
    }

    const isFirefox = navigator.userAgent.includes('Firefox');

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

    const observer = new MutationObserver(() => applySpeedToAllVideos());
    observer.observe(document.body, { childList: true, subtree: true });

    setInterval(() => applySpeedToAllVideos(), 2000);

    document.body.addEventListener(
        'play',
        (e) => {
            if (e.target.tagName === 'VIDEO') {
                setSpeed(e.target);
            }
        },
        true
    );

    applySpeedToAllVideos();

    window.addEventListener('keydown', function (e) {
        if (e[shortcuts.decrease.modifier] && e.key === shortcuts.decrease.key) {
            currentSpeed = Math.max(currentSpeed - 0.25, minSpeed);
            applySpeedToAllVideos();
            showSpeedOverlay();
        } else if (e[shortcuts.increase.modifier] && e.key === shortcuts.increase.key) {
            currentSpeed = Math.min(currentSpeed + 0.25, maxSpeed);
            applySpeedToAllVideos();
            showSpeedOverlay();
        } else if (e[shortcuts.toggle1x.modifier] && e.key === shortcuts.toggle1x.key) {
            currentSpeed = 1;
            applySpeedToAllVideos();
            showSpeedOverlay();
        } else if (e[shortcuts.toggle2x.modifier] && e.key === shortcuts.toggle2x.key) {
            currentSpeed = 2;
            applySpeedToAllVideos();
            showSpeedOverlay();
        }
    });
})();
