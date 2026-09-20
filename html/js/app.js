(() => {
    'use strict';

    const root = document.getElementById('announcement-root');
    const card = document.getElementById('announcement');
    const logo = document.getElementById('job-logo');
    const subtitle = document.getElementById('job-subtitle');
    const label = document.getElementById('job-label');
    const message = document.getElementById('announcement-message');
    const locationRow = document.getElementById('location-row');
    const locationText = document.getElementById('announcement-location');
    const timerBar = document.getElementById('timer-bar');

    const queue = [];
    let active = false;
    let activeToken = 0;
    let leaveTimer = null;
    let finishTimer = null;
    let audio = null;

    const clamp = (value, min, max, fallback) => {
        const number = Number(value);
        if (!Number.isFinite(number)) return fallback;
        return Math.min(max, Math.max(min, number));
    };

    const safeText = (value, fallback = '') => {
        if (typeof value === 'string') return value;
        if (value === null || value === undefined) return fallback;
        return String(value);
    };

    const safeHex = (value, fallback) => {
        const text = safeText(value).trim();
        return /^#[0-9a-fA-F]{6}$/.test(text) ? text : fallback;
    };

    const safeRgba = (value, fallback) => {
        const text = safeText(value).trim();
        return /^rgba?\([\d\s.,%]+\)$/.test(text) ? text : fallback;
    };

    const safeAssetPath = (value, prefix) => {
        const text = safeText(value).trim();
        if (!text || text.includes('..') || text.includes('://') || text.startsWith('/')) return '';
        if (!/^[a-zA-Z0-9_./-]+$/.test(text)) return '';
        return `${prefix}${text}`;
    };

    const setPosition = (position) => {
        const allowed = new Set(['top-center', 'top-left', 'top-right', 'bottom-center']);
        const resolved = allowed.has(position) ? position : 'bottom-center';
        root.className = `position-${resolved}`;
    };

    const stopTimers = () => {
        if (leaveTimer) clearTimeout(leaveTimer);
        if (finishTimer) clearTimeout(finishTimer);
        leaveTimer = null;
        finishTimer = null;
    };

    const playSound = (data) => {
        if (!data.sound) return;

        const source = safeAssetPath(data.soundFile || 'sounds/notify.wav', '');
        if (!source) return;

        try {
            if (audio) {
                audio.pause();
                audio = null;
            }

            audio = new Audio(source);
            audio.volume = clamp(data.soundVolume, 0, 1, 0.2);
            audio.play().catch(() => {});
        } catch (_) {
            // La NUI visual debe seguir funcionando aunque falle el audio.
        }
    };

    const render = (data) => {
        const accent = safeHex(data.accent, '#4B8DFF');
        const accentSoft = safeRgba(data.accentSoft, 'rgba(75, 141, 255, 0.20)');
        const duration = clamp(data.duration, 1000, 60000, 10000);

        document.documentElement.style.setProperty('--accent', accent);
        document.documentElement.style.setProperty('--accent-soft', accentSoft);
        setPosition(safeText(data.position, 'top-center'));

        subtitle.textContent = safeText(data.subtitle, 'ANUNCIO DE SERVICIO');
        label.textContent = safeText(data.label, 'SERVICIO');
        message.textContent = safeText(data.message);

        const logoPath = safeAssetPath(data.logo, 'img/jobs/');
        if (logoPath) {
            logo.hidden = false;
            logo.src = logoPath;
            logo.onerror = () => {
                logo.hidden = true;
                logo.removeAttribute('src');
            };
        } else {
            logo.hidden = true;
            logo.removeAttribute('src');
        }

        const location = safeText(data.location).trim();
        if (location) {
            locationText.textContent = location;
            locationRow.hidden = false;
        } else {
            locationText.textContent = '';
            locationRow.hidden = true;
        }

        timerBar.style.animation = 'none';
        void timerBar.offsetWidth;
        timerBar.style.animation = `timer-countdown ${duration}ms linear forwards`;

        card.classList.remove('is-leaving', 'is-visible', 'is-entering');
        card.setAttribute('aria-hidden', 'false');
        void card.offsetWidth;
        card.classList.add('is-entering');

        setTimeout(() => {
            card.classList.remove('is-entering');
            card.classList.add('is-visible');
        }, 430);

        playSound(data);
        return duration;
    };

    const hideCurrent = (token) => {
        if (token !== activeToken) return;

        card.classList.remove('is-entering', 'is-visible');
        card.classList.add('is-leaving');

        finishTimer = setTimeout(() => {
            if (token !== activeToken) return;

            card.classList.remove('is-leaving');
            card.setAttribute('aria-hidden', 'true');
            timerBar.style.animation = 'none';
            active = false;
            showNext();
        }, 350);
    };

    const showNext = () => {
        if (active || queue.length === 0) return;

        active = true;
        const item = queue.shift();
        const token = ++activeToken;
        const duration = render(item);

        leaveTimer = setTimeout(() => hideCurrent(token), duration);
    };

    const replaceCurrent = (data) => {
        stopTimers();
        queue.length = 0;
        active = false;
        card.classList.remove('is-entering', 'is-visible', 'is-leaving');
        card.setAttribute('aria-hidden', 'true');
        queue.push(data);
        showNext();
    };

    const enqueue = (data) => {
        const queueEnabled = data.enableQueue !== false;
        const maxQueue = Math.floor(clamp(data.maxQueue, 1, 20, 5));

        if (!queueEnabled) {
            replaceCurrent(data);
            return;
        }

        if (active && queue.length >= maxQueue) {
            return;
        }

        if (!active && queue.length >= maxQueue) {
            queue.shift();
        }

        queue.push(data);
        showNext();
    };

    window.addEventListener('message', (event) => {
        const payload = event.data;
        if (!payload || payload.action !== 'announcement' || typeof payload.data !== 'object') return;
        enqueue(payload.data);
    });
})();
