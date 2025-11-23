const statusTextEl = document.getElementById("status-text");
const attemptsLabel = document.getElementById("attempts-label");
const gameTitleEl = document.getElementById("game-title");
const difficultyLabelEl = document.getElementById("difficulty-label");
const modeButtons = document.querySelectorAll(".btn-mode");
const patternGameEl = document.getElementById("pattern-game");
const timingGameEl = document.getElementById("timing-game");
const btnStart = document.getElementById("btn-start");
const uiContent = document.querySelector(".wrapper");
const closeButton = document.getElementById("btn-close");
let currentMode = "pattern"; 


function setStatus(message, type = "normal") {
    statusTextEl.classList.remove("status-ok", "status-fail");
    if (type === "success") statusTextEl.classList.add("status-ok");
    if (type === "fail") statusTextEl.classList.add("status-fail");
    statusTextEl.innerHTML = message;
}

closeButton.addEventListener("click", () => {
    uiContent.style.display = "none";
    hEvent('CloseMenu', {});
});

function onHackSuccess(type) {
    hEvent('onHackSuccess', {type});
}
function onHackFail(type) {
    hEvent('onHackFail', {type});
}

modeButtons.forEach(btn => {
    btn.addEventListener("click", () => {
        modeButtons.forEach(b => b.classList.remove("active"));
        btn.classList.add("active");
        currentMode = btn.dataset.mode;
        if (currentMode === "pattern") {
            patternGameEl.style.display = "block";
            timingGameEl.style.display = "none";
            gameTitleEl.textContent = "Pattern Hack";
            difficultyLabelEl.textContent = "Average";
            attemptsLabel.textContent = "Attempts: " + patternState.maxAttempts;
            setStatus("Click Start to begin the Pattern Hack.");
        } else {
            patternGameEl.style.display = "none";
            timingGameEl.style.display = "block";
            gameTitleEl.textContent = "Timing Hack";
            difficultyLabelEl.textContent = "Average";
            attemptsLabel.textContent = "Attempts: " + timingState.maxAttempts;
            setStatus("Click Start to begin the Timing Hack.");
        }
    });
});

const patternState = {
    maxAttempts: 3,
    attemptsLeft: 3
};

const timingState = {
    maxAttempts: 3,
    attemptsLeft: 3
};

/****************************************************
 * PATTERN HACK
 ****************************************************/

const patternGridEl = document.getElementById("pattern-grid");
const patternRoundEl = document.getElementById("pattern-round").querySelector("span");
let patternNodes = [];
let patternSequence = [];
let patternPlayerIndex = 0;
let isShowingPattern = false;
let patternRound = 0;

for (let i = 0; i < 9; i++) {
    const node = document.createElement("div");
    node.className = "pattern-node";
    node.dataset.index = i;
    node.addEventListener("click", () => onPatternNodeClick(i));
    patternGridEl.appendChild(node);
    patternNodes.push(node);
}

function resetPatternVisual() {
    patternNodes.forEach(n => {
        n.classList.remove("active", "correct", "wrong");
    });
}

function generatePatternSequence(length) {
    const seq = [];
    for (let i = 0; i < length; i++) {
        const idx = Math.floor(Math.random() * 9);
        seq.push(idx);
    }
    return seq;
}

async function showPatternSequence() {
    isShowingPattern = true;
    resetPatternVisual();
    setStatus("Memorize the pattern...", "normal");
    for (let i = 0; i < patternSequence.length; i++) {
        const index = patternSequence[i];
        const node = patternNodes[index];

        node.classList.add("active");
        await sleep(550);
        node.classList.remove("active");
        await sleep(180);
    }
    isShowingPattern = false;
    setStatus("Your turn! Reproduce the pattern by clicking on the blocks.", "normal");
}

function onPatternNodeClick(index) {
    if (isShowingPattern) return;
    if (!patternSequence.length) return;
    const expectedIndex = patternSequence[patternPlayerIndex];
    resetPatternVisual();
    if (index === expectedIndex) {
        patternNodes[index].classList.add("correct");
        patternPlayerIndex++;
        if (patternPlayerIndex >= patternSequence.length) {
            patternRound++;
            patternRoundEl.textContent = patternRound;
            setStatus("Correct pattern! Next round...", "success");
            if (patternRound >= 3) {
                setStatus("Pattern Hack completed successfully!", "success");
                onHackSuccess("pattern");
                patternSequence = [];
            } else {
                startPatternRound(patternSequence.length + 1);
            }
        }
    } else {
        patternNodes[index].classList.add("wrong");
        patternNodes[expectedIndex].classList.add("active");
        patternState.attemptsLeft--;
        attemptsLabel.textContent = "Attempts: " + patternState.attemptsLeft;
        if (patternState.attemptsLeft <= 0) {
            setStatus("The Pattern Hack failed.", "fail");
            onHackFail("pattern");
            patternSequence = [];
        } else {
            setStatus("Wrong pattern! Try again. Remaining attempts:" + patternState.attemptsLeft, "fail");
            patternPlayerIndex = 0;
            showPatternSequence();
        }
    }
}

function startPatternRound(sequenceLength = 3) {
    patternSequence = generatePatternSequence(sequenceLength);
    patternPlayerIndex = 0;
    resetPatternVisual();
    showPatternSequence();
}

function resetPatternGame(fullReset = true) {
    resetPatternVisual();
    patternSequence = [];
    patternPlayerIndex = 0;
    patternRound = 0;
    patternRoundEl.textContent = "0";
    if (fullReset) {
        patternState.attemptsLeft = patternState.maxAttempts;
        attemptsLabel.textContent = "Tentativas: " + patternState.attemptsLeft;
    }
}

/****************************************************
 * TIMING HACK 
 ****************************************************/

const timingTrackEl = document.getElementById("timing-track");
const timingTargetEl = document.getElementById("timing-target");
const timingCursorEl = document.getElementById("timing-cursor");
const timingHitsEl = document.getElementById("timing-hits");
const timingRequiredEl = document.getElementById("timing-required");
const timingAttemptsEl = document.getElementById("timing-attempts");
const timingFireBtn = document.getElementById("timing-fire");
let timingRaf = null;
let cursorPx = 0;              
let cursorDir = 1;            
let targetStart = 0.3;
let targetEnd = 0.5;
let timingHits = 0;
const timingRequired = 3;
timingRequiredEl.textContent = timingRequired.toString();
const speedPxPerSec = 420; 
const hitMode = "center"; 

function placeTimingTarget() {
    const minWidth = 0.12;
    const maxWidth = 0.2;
    const width = minWidth + Math.random() * (maxWidth - minWidth);
    const start = Math.random() * (1 - width);
    const end = start + width;
    targetStart = start;
    targetEnd = end;
    timingTargetEl.style.left = (start * 100) + "%";
    timingTargetEl.style.width = (width * 100) + "%";
}

let lastTimestamp = null;
function timingLoop(ts) {
    if (!lastTimestamp) lastTimestamp = ts;
    const dt = (ts - lastTimestamp) / 1000; 
    lastTimestamp = ts;
    const trackRect = timingTrackEl.getBoundingClientRect();
    const trackWidth = Math.max(1, trackRect.width);
    cursorPx += cursorDir * speedPxPerSec * dt;
    const halfCursor = timingCursorEl.getBoundingClientRect().width / 2;
    const minCenter = halfCursor;
    const maxCenter = trackWidth - halfCursor;
    if (cursorPx > maxCenter) {
        cursorPx = maxCenter;
        cursorDir = -1;
    } else if (cursorPx < minCenter) {
        cursorPx = minCenter;
        cursorDir = 1;
    }
    const norm = (cursorPx - halfCursor) / (trackWidth - halfCursor * 2); 
    const leftPct = (cursorPx / trackWidth) * 100;
    timingCursorEl.style.left = leftPct + "%";
    timingRaf = requestAnimationFrame(timingLoop);
}

function startTimingCursor() {
    stopTimingCursor();
    const trackRect = timingTrackEl.getBoundingClientRect();
    const trackWidth = Math.max(1, trackRect.width);
    const cursorWidth = timingCursorEl.getBoundingClientRect().width;
    cursorPx = cursorWidth / 2;
    cursorDir = 1;
    lastTimestamp = null;
    timingRaf = requestAnimationFrame(timingLoop);
}

function stopTimingCursor() {
    if (timingRaf) {
        cancelAnimationFrame(timingRaf);
        timingRaf = null;
    }
    lastTimestamp = null;
}

function resetTimingGame(fullReset = true) {
    stopTimingCursor();
    timingHits = 0;
    timingHitsEl.textContent = "0";
    placeTimingTarget();
    timingCursorEl.style.left = "0%";
    if (fullReset) {
        timingState.attemptsLeft = timingState.maxAttempts;
        timingAttemptsEl.textContent = timingState.attemptsLeft.toString();
    }
}

function isHitStrictCenter() {
    const trackRect = timingTrackEl.getBoundingClientRect();
    const cursorRect = timingCursorEl.getBoundingClientRect();
    const targetRect = timingTargetEl.getBoundingClientRect();
    const cursorCenter = (cursorRect.left + cursorRect.right) / 2;
    return cursorCenter >= targetRect.left && cursorCenter <= targetRect.right;
}

function isHitOverlap() {
    const cursorRect = timingCursorEl.getBoundingClientRect();
    const targetRect = timingTargetEl.getBoundingClientRect();
    return !(cursorRect.right < targetRect.left || cursorRect.left > targetRect.right);
}

function fireTiming() {
    const hit = (hitMode === "center") ? isHitStrictCenter() : isHitOverlap();

    if (hit) {
        timingHits++;
        timingHitsEl.textContent = timingHits.toString();
        setStatus("Correct! Stay focused...", "success");
        placeTimingTarget();

        if (timingHits >= timingRequired) {
            setStatus("Timing Hack completed successfully!", "success");
            onHackSuccess("timing");
            stopTimingCursor();
        }
    } else {
        timingState.attemptsLeft--;
        timingAttemptsEl.textContent = timingState.attemptsLeft.toString();
        setStatus("You got the timing wrong! Remaining attempts:" + timingState.attemptsLeft, "fail");

        if (timingState.attemptsLeft <= 0) {
            setStatus("The timing hack failed..", "fail");
            onHackFail("timing");
            stopTimingCursor();
        }
    }
}

timingFireBtn.addEventListener("click", () => {
    fireTiming();
});





/****************************************************
 * UTILS
 ****************************************************/

function sleep(ms) {
    return new Promise(resolve => setTimeout(resolve, ms));
}

patternGameEl.style.display = "block";
timingGameEl.style.display = "none";
resetPatternGame(true);
resetTimingGame(true);
placeTimingTarget();


btnStart.addEventListener("click", () => {
    if (currentMode === "pattern") {
        resetPatternGame(true);
        startPatternRound(3);
        setStatus("Memorize the pattern and then click on the blocks in the same order.");
    } else {
        resetTimingGame(true);
        placeTimingTarget();
        startTimingCursor();
        setStatus("Stop the cursor inside the blue area by clicking 'Hack!'.");
    }
});


window.addEventListener("message", function(event) {
    const data = event.data;
    const eventAction = data.name || data.action;

    if (eventAction === "open") {
        uiContent.style.display = "grid";
    }

    if (eventAction === "close") {
        uiContent.style.display = "none";

    }

    if (eventAction === "startPattern") {
        currentMode = "pattern";
        uiContent.style.display = "grid";
        patternGameEl.style.display = "block";
        timingGameEl.style.display = "none";
        setStatus("Memorize the pattern and then click on the blocks in the same order.");
    }

    if (eventAction === "startTiming") {
        uiContent.style.display = "grid";
        currentMode = "timing";
        patternGameEl.style.display = "none";
        timingGameEl.style.display = "block";
        setStatus("Stop the cursor inside the blue area by clicking 'Hack!'.");
    }
});


/****************************************************
 * PHONE NOTIFY SYSTEM
 ****************************************************/

const phone = document.querySelector('.phone');
const msgBox = document.getElementById('msgBox');
let notifyQueue = [];
let notifyAtiva = false;
function processarFila() {
    if (notifyAtiva) return;
    if (notifyQueue.length === 0) return;
    notifyAtiva = true;
    const cfg = notifyQueue.shift();
    executarNotify(cfg);
}
function executarNotify({ texto = "", cor = "#0aff6c", velocidade = 40, tempo = 4000 } = {}) {
    msgBox.innerHTML = "";
    msgBox.style.color = cor;
    let i = 0;
    phone.classList.remove('hide');
    phone.classList.add('show');
    phone.setAttribute('aria-hidden', 'false');
    msgBox.classList.add('typing');
    const interval = setInterval(() => {
        msgBox.innerHTML = texto.substring(0, i);
        i++;
        if (i > texto.length) {
            clearInterval(interval);
            msgBox.classList.remove('typing');
        }
    }, velocidade);
    setTimeout(() => {
        phone.classList.remove('show');
        phone.classList.add('hide');
        phone.setAttribute('aria-hidden', 'true');
        setTimeout(() => {
            notifyAtiva = false;
            processarFila();
        }, 600);
    }, tempo);
}

function notify(cfg = {}) {
    if (typeof cfg === 'string') cfg = { texto: cfg };
    const item = {
        texto: String(cfg.texto ?? ""),
        cor: cfg.cor ?? '#0aff6c',
        velocidade: Number.isFinite(cfg.velocidade) ? cfg.velocidade : 40,
        tempo: Number.isFinite(cfg.tempo) ? cfg.tempo : 4000
    };
    notifyQueue.push(item);
    processarFila();
}
window.addEventListener("message", function(event) {
    const eventData = event.data;
    const eventAction = eventData.name || eventData.action;
    const data = eventData.args && eventData.args[0];
    if (eventAction === "notify") {
        let message = data.message || data.text || "";
        let color = data.color || data.cor || "#0aff6c";
        let speed = data.speed || data.velocidade || 40;
        let duration = data.duration || data.tempo || 4000;
        notify({ texto: message, cor: color, velocidade: speed, tempo: duration });
    }
});