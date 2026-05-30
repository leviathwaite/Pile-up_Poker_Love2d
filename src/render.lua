-- Rendering module
-- Draws all game screens; stores button bounds for touch-hit-testing.
-- All coordinates are in virtual-pixel space (1080 × 2340).
--
-- NOTE: All helper (local) functions are defined BEFORE they are called.

local C = require("src.constants")

local R = {}

-- ── Module-level state ────────────────────────────────────────────────────────

local fonts      = {}
local cardImages = {}   -- optional Kenney asset cache

-- Screen → virtual transform
local _sx, _sy, _ox, _oy = 1, 1, 0, 0

-- Hit-testable button bounds (populated each frame by draw calls)
R.playButton      = nil
R.playAgainButton = nil
R.menuButton      = nil
R.colButtons      = {}

-- Suit unicode symbols
local SYM = {hearts = "♥", diamonds = "♦", clubs = "♣", spades = "♠"}

-- Header height constant (used by both header and grid)
local HEADER_H = 128

-- ── Low-level drawing helpers ─────────────────────────────────────────────────

local function setColor(t, a)
    if a then
        love.graphics.setColor(t[1], t[2], t[3], a)
    elseif t[4] then
        love.graphics.setColor(t[1], t[2], t[3], t[4])
    else
        love.graphics.setColor(t[1], t[2], t[3], 1)
    end
end

local function rect(mode, x, y, w, h, r)
    love.graphics.rectangle(mode, x, y, w, h, r or 0, r or 0)
end

-- Draws text centred at (cx, cy).
local function centredText(font, text, cx, cy)
    love.graphics.setFont(font)
    local w = font:getWidth(text)
    local h = font:getHeight()
    love.graphics.print(text, math.floor(cx - w / 2), math.floor(cy - h / 2))
end

-- ── Decorative felt background ────────────────────────────────────────────────

local function drawFeltStripes()
    local stripeW = 110
    setColor(C.COL_FELT_STRIPE, 0.35)
    love.graphics.setLineWidth(stripeW)
    local diag = C.VIRT_W + C.VIRT_H
    for x = -C.VIRT_H, C.VIRT_W + stripeW, stripeW * 2.5 do
        love.graphics.line(x, 0, x + diag * 0.7071, diag * 0.7071)
    end
    love.graphics.setLineWidth(1)
end

-- ── Card drawing ──────────────────────────────────────────────────────────────

local function drawCardKenney(card, x, y, w, h, alpha)
    local key = card.suit .. "_" .. card.value
    local img = cardImages[key]
    if not img then return false end
    local iw, ih = img:getDimensions()
    love.graphics.setColor(1, 1, 1, alpha)
    love.graphics.draw(img, x, y, 0, w / iw, h / ih)
    return true
end

local function drawCardProcedural(card, x, y, w, h, alpha)
    local r = math.max(8, math.floor(w * 0.06))

    -- Drop shadow
    setColor(C.COL_SHADOW, (C.COL_SHADOW[4] or 0.35) * alpha)
    rect("fill", x + 4, y + 5, w, h, r)

    -- White face
    love.graphics.setColor(1, 1, 1, alpha)
    rect("fill", x, y, w, h, r)

    -- Border
    love.graphics.setColor(0.72, 0.72, 0.72, alpha)
    love.graphics.setLineWidth(2)
    rect("line", x, y, w, h, r)

    -- Suit colour
    local col = card.isRed and C.COL_RED or C.COL_BLACK
    love.graphics.setColor(col[1], col[2], col[3], alpha)

    local sym = SYM[card.suit] or "?"
    local val = card.value

    -- Top-left corner: value + symbol
    love.graphics.setFont(fonts.corner)
    love.graphics.print(val, x + 8, y + 4)
    love.graphics.setFont(fonts.hint)
    love.graphics.print(sym, x + 9, y + 47)

    -- Centre value
    love.graphics.setFont(fonts.cardNum)
    local vw = fonts.cardNum:getWidth(val)
    local vh = fonts.cardNum:getHeight()
    love.graphics.print(val,
        math.floor(x + (w - vw) / 2),
        math.floor(y + h / 2 - vh * 0.85))

    -- Centre suit symbol
    love.graphics.setFont(fonts.cardSym)
    local sw = fonts.cardSym:getWidth(sym)
    local sh = fonts.cardSym:getHeight()
    love.graphics.print(sym,
        math.floor(x + (w - sw) / 2),
        math.floor(y + h / 2 + sh * 0.05))

    -- Bottom-right corner (rotated 180°)
    love.graphics.push()
    love.graphics.translate(x + w - 8, y + h - 4)
    love.graphics.rotate(math.pi)
    love.graphics.setFont(fonts.corner)
    love.graphics.print(val, 0, 0)
    love.graphics.setFont(fonts.hint)
    love.graphics.print(sym, 1, 47)
    love.graphics.pop()
end

local function drawCard(card, x, y, w, h, alpha)
    alpha = alpha or 1
    if not drawCardKenney(card, x, y, w, h, alpha) then
        drawCardProcedural(card, x, y, w, h, alpha)
    end
end

local function drawCardBack(x, y, w, h, alpha)
    alpha = alpha or 1

    if cardImages["back"] then
        local img = cardImages["back"]
        local iw, ih = img:getDimensions()
        love.graphics.setColor(1, 1, 1, alpha)
        love.graphics.draw(img, x, y, 0, w / iw, h / ih)
        return
    end

    local r = math.max(8, math.floor(w * 0.06))

    -- Shadow
    setColor(C.COL_SHADOW, (C.COL_SHADOW[4] or 0.35) * alpha)
    rect("fill", x + 4, y + 5, w, h, r)

    -- Back face (blue)
    setColor(C.COL_CARD_BACK_A, alpha)
    rect("fill", x, y, w, h, r)

    -- Inner panel
    local m = math.floor(w * 0.08)
    setColor(C.COL_CARD_BACK_B, alpha)
    rect("fill", x + m, y + m, w - m * 2, h - m * 2, math.max(4, r - 3))

    -- Subtle vertical stripes on inner panel
    love.graphics.setLineWidth(1.5)
    love.graphics.setColor(1, 1, 1, 0.10 * alpha)
    local step = math.floor(w * 0.15)
    for dx = 0, w - m * 2, step do
        love.graphics.line(x + m + dx, y + m, x + m + dx, y + h - m)
    end

    -- Outer border
    setColor(C.COL_CARD_BACK_A, alpha)
    love.graphics.setLineWidth(2)
    rect("line", x, y, w, h, r)
end

local function drawEmptySlot(x, y, w, h)
    local r = math.max(8, math.floor(w * 0.06))
    setColor(C.COL_SLOT)
    rect("fill", x, y, w, h, r)
    setColor(C.COL_SLOT_BORDER)
    love.graphics.setLineWidth(2)
    rect("line", x, y, w, h, r)
end

-- ── Scoring guide (used in menu) ──────────────────────────────────────────────

local function drawScoringGuide(topY)
    setColor(C.COL_TEXT)
    centredText(fonts.medium, "Scoring", C.VIRT_W / 2, topY + 34)

    local entries = {
        {"Royal Flush",    "100 pts"},
        {"Straight Flush", "75 pts"},
        {"Four of a Kind", "50 pts"},
        {"Full House",     "25 pts"},
        {"Flush",          "20 pts"},
        {"Straight",       "15 pts"},
        {"Three of a Kind","10 pts"},
        {"Two Pair",        "5 pts"},
        {"One Pair",        "2 pts"},
        {"High Card",       "1 pt"},
    }
    local col1x = 90
    local col2x = 600
    local rowH  = fonts.small:getHeight() + 10
    for i, e in ipairs(entries) do
        local ey = topY + 82 + (i - 1) * rowH
        love.graphics.setFont(fonts.small)
        setColor(C.COL_TEXT_DIM)
        love.graphics.print(e[1], col1x, ey)
        setColor(C.COL_GOLD)
        love.graphics.print(e[2], col2x, ey)
    end
end

-- ── Header (in-game) ──────────────────────────────────────────────────────────

local function drawHeader(game)
    setColor(C.COL_HEADER_BG)
    rect("fill", 0, 0, C.VIRT_W, HEADER_H)

    setColor(C.COL_GOLD)
    love.graphics.setFont(fonts.large)
    love.graphics.print("Pile-Up Poker", 24, 16)

    setColor(C.COL_TEXT)
    love.graphics.setFont(fonts.medium)
    local sc = "Score: " .. game.score
    love.graphics.print(sc, C.VIRT_W - fonts.medium:getWidth(sc) - 24, 14)

    setColor(C.COL_TEXT_DIM)
    love.graphics.setFont(fonts.small)
    local remaining = (game.deck and game.deck:size() or 0)
                    + (game.currentCard and 1 or 0)
    love.graphics.print("Cards left: " .. remaining, 24, 78)

    setColor(C.COL_GOLD)
    local hs = "Best: " .. game.highScore
    love.graphics.print(hs, C.VIRT_W - fonts.small:getWidth(hs) - 24, 78)
end

-- ── Grid metrics ──────────────────────────────────────────────────────────────

-- All grid measurements are derived here and stored in GM so that
-- _drawGrid and _drawFooter share a single source of truth.
local GM = {}

local function computeGridMetrics()
    local margin = C.GRID_MARGIN
    local gap    = C.COL_GAP
    local cols   = C.NUM_COLS
    local rows   = C.NUM_ROWS

    local totalW = C.VIRT_W - 2 * margin
    local cw     = math.floor((totalW - (cols - 1) * gap) / cols)
    local ch     = math.floor(cw * 1.4)
    local rh     = C.ROW_GAP

    GM.cw      = cw
    GM.ch      = ch
    GM.rh      = rh
    GM.margin  = margin
    GM.gap     = gap
    GM.cols    = cols
    GM.rows    = rows
    GM.gridTop = HEADER_H + 52   -- room above grid for hint labels
    GM.hintY   = HEADER_H + 10  -- hint label y
    GM.gridH   = rows * ch + (rows - 1) * rh

    GM.colX = {}
    for c = 1, cols do
        GM.colX[c] = margin + (c - 1) * (cw + gap)
    end
end

local function footerTop()
    return GM.gridTop + GM.gridH + 22
end

-- ── Grid drawing ──────────────────────────────────────────────────────────────

local function drawGrid(game)
    computeGridMetrics()

    for col = 1, GM.cols do
        local cx = GM.colX[col]

        -- Hand hint label above each column
        local hint = game:columnHint(col)
        if hint then
            setColor(C.COL_GOLD)
            love.graphics.setFont(fonts.hint)
            local hw = fonts.hint:getWidth(hint)
            love.graphics.print(hint,
                math.floor(cx + (GM.cw - hw) / 2), GM.hintY)
        end

        -- Small column number tab
        setColor({0, 0, 0, 0.40})
        rect("fill", cx, GM.hintY + 30, GM.cw, 26, 6)
        setColor(C.COL_TEXT_DIM)
        love.graphics.setFont(fonts.hint)
        local numStr = tostring(col)
        local nw     = fonts.hint:getWidth(numStr)
        love.graphics.print(numStr,
            math.floor(cx + (GM.cw - nw) / 2), GM.hintY + 31)

        -- Card slots
        for row = 1, GM.rows do
            local ry   = GM.gridTop + (row - 1) * (GM.ch + GM.rh)
            local card = game.columns[col][row]
            if card then
                drawCard(card, cx, ry, GM.cw, GM.ch)
            else
                drawEmptySlot(cx, ry, GM.cw, GM.ch)
            end
        end
    end
end

-- ── Footer drawing ────────────────────────────────────────────────────────────

local function drawFooter(game)
    local ft = footerTop()
    local fh = C.VIRT_H - ft

    setColor(C.COL_FOOTER_BG)
    rect("fill", 0, ft, C.VIRT_W, fh)

    -- Top divider line
    setColor(C.COL_GOLD, 0.45)
    love.graphics.setLineWidth(2)
    love.graphics.line(40, ft + 8, C.VIRT_W - 40, ft + 8)

    -- Current card display
    if game.currentCard then
        setColor(C.COL_TEXT_DIM)
        centredText(fonts.small, "Tap a column to place:", C.VIRT_W / 2, ft + 52)

        -- Large centre card
        local cw = math.floor(GM.cw * 1.14)
        local ch = math.floor(cw * 1.4)
        local cx = math.floor((C.VIRT_W - cw) / 2)
        local cy = ft + 78
        drawCard(game.currentCard, cx, cy, cw, ch)
    else
        setColor(C.COL_TEXT_DIM)
        centredText(fonts.medium, "No more cards", C.VIRT_W / 2, ft + 110)
    end

    -- Column buttons (5 wide, touch-friendly)
    local btnAreaH   = 234
    local btnAreaTop = C.VIRT_H - btnAreaH - 18
    local btnMargin  = 14
    local btnGap     = 10
    local btnW       = math.floor(
                           (C.VIRT_W - btnMargin * 2 - btnGap * (C.NUM_COLS - 1))
                           / C.NUM_COLS)
    local btnH       = btnAreaH

    R.colButtons = {}

    for col = 1, C.NUM_COLS do
        local bx       = btnMargin + (col - 1) * (btnW + btnGap)
        local by       = btnAreaTop
        local canPlace = game:canPlace(col)

        -- Button background
        setColor(canPlace and C.COL_BTN or C.COL_BTN_DISABLED)
        rect("fill", bx, by, btnW, btnH, 18)

        -- Highlight border (only if placeable)
        if canPlace then
            setColor(C.COL_BTN_HOVER)
            love.graphics.setLineWidth(3)
            rect("line", bx, by, btnW, btnH, 18)
        end

        -- Column number (large)
        setColor(canPlace and C.COL_TEXT or C.COL_TEXT_DIM)
        centredText(fonts.xlarge, tostring(col), bx + btnW / 2, by + btnH * 0.40)

        -- Status line
        local cnt = #game.columns[col]
        love.graphics.setFont(fonts.hint)
        if not canPlace then
            setColor({0.9, 0.35, 0.35})
            centredText(fonts.hint, "FULL", bx + btnW / 2, by + btnH * 0.77)
        else
            setColor(C.COL_GOLD)
            centredText(fonts.hint, cnt .. "/5", bx + btnW / 2, by + btnH * 0.77)
        end

        R.colButtons[col] = {x = bx, y = by, w = btnW, h = btnH}
    end
end

-- ── Kenney asset loader ───────────────────────────────────────────────────────
-- Expects assets in  assets/cards/  using Kenney's naming convention:
--   cardClubs2.png  cardHeartsA.png  cardBack_blue2.png  etc.
-- Falls back silently to procedural drawing if files are absent.

local function tryLoadKenneyAssets()
    if not love.filesystem.getInfo("assets/cards/cardClubs2.png") then return end

    local suitMap = {
        hearts   = "Hearts",
        diamonds = "Diamonds",
        clubs    = "Clubs",
        spades   = "Spades",
    }
    local vals = {"A","2","3","4","5","6","7","8","9","10","J","Q","K"}

    for suit, sName in pairs(suitMap) do
        for _, val in ipairs(vals) do
            local path = "assets/cards/card" .. sName .. val .. ".png"
            local ok, img = pcall(love.graphics.newImage, path)
            if ok then cardImages[suit .. "_" .. val] = img end
        end
    end

    -- Card back (try a few variants)
    for _, name in ipairs({"cardBack_blue2","cardBack_blue1","cardBack_red2"}) do
        local ok, img = pcall(love.graphics.newImage, "assets/cards/" .. name .. ".png")
        if ok then cardImages["back"] = img; break end
    end
end

-- ── Public: init ──────────────────────────────────────────────────────────────

function R.init()
    -- Font sizes tuned for 1080-wide virtual canvas
    fonts.tiny    = love.graphics.newFont(24)
    fonts.hint    = love.graphics.newFont(28)
    fonts.small   = love.graphics.newFont(34)
    fonts.medium  = love.graphics.newFont(48)
    fonts.large   = love.graphics.newFont(66)
    fonts.xlarge  = love.graphics.newFont(90)
    fonts.cardNum = love.graphics.newFont(60)
    fonts.cardSym = love.graphics.newFont(74)
    fonts.corner  = love.graphics.newFont(38)

    tryLoadKenneyAssets()
end

-- ── Public: transform helpers ─────────────────────────────────────────────────

function R.setupTransform()
    local sw    = love.graphics.getWidth()
    local sh    = love.graphics.getHeight()
    local scale = math.min(sw / C.VIRT_W, sh / C.VIRT_H)
    _sx = scale; _sy = scale
    _ox = (sw - C.VIRT_W * scale) / 2
    _oy = (sh - C.VIRT_H * scale) / 2
    love.graphics.translate(_ox, _oy)
    love.graphics.scale(scale, scale)
end

function R.toVirtual(sx, sy)
    return (sx - _ox) / _sx, (sy - _oy) / _sy
end

function R.hit(bounds, vx, vy)
    if not bounds then return false end
    return vx >= bounds.x and vx <= bounds.x + bounds.w
       and vy >= bounds.y and vy <= bounds.y + bounds.h
end

-- ── Public: screen draw functions ─────────────────────────────────────────────

function R.drawMenu(highScore)
    setColor(C.COL_BG)
    rect("fill", 0, 0, C.VIRT_W, C.VIRT_H)
    drawFeltStripes()

    -- Title
    setColor(C.COL_GOLD)
    centredText(fonts.xlarge, "Pile-Up", C.VIRT_W / 2, 230)
    centredText(fonts.xlarge, "Poker",   C.VIRT_W / 2, 345)

    -- Decorative face-down cards
    local cw, ch = 170, 238
    local deco = {{200, 690, -0.28}, {540, 640, -0.04}, {880, 690, 0.26}}
    for _, p in ipairs(deco) do
        love.graphics.push()
        love.graphics.translate(p[1], p[2])
        love.graphics.rotate(p[3])
        drawCardBack(-cw / 2, -ch / 2, cw, ch)
        love.graphics.pop()
    end

    -- Description
    local lines = {
        "Deal cards into 5 columns.",
        "Each column scores as a poker hand.",
        "Fill all 5 columns for your best score!",
    }
    local ly = 968
    for _, ln in ipairs(lines) do
        setColor(C.COL_TEXT)
        centredText(fonts.small, ln, C.VIRT_W / 2, ly)
        ly = ly + fonts.small:getHeight() + 14
    end

    -- High score
    if highScore and highScore > 0 then
        setColor(C.COL_GOLD)
        centredText(fonts.medium, "Best: " .. highScore, C.VIRT_W / 2, 1172)
    end

    -- PLAY button
    local bw, bh = 500, 148
    local bx     = math.floor((C.VIRT_W - bw) / 2)
    local by     = 1320
    setColor(C.COL_BTN)
    rect("fill", bx, by, bw, bh, 26)
    setColor(C.COL_BTN_HOVER)
    love.graphics.setLineWidth(4)
    rect("line", bx, by, bw, bh, 26)
    setColor(C.COL_TEXT)
    centredText(fonts.xlarge, "PLAY", bx + bw / 2, by + bh / 2)
    R.playButton = {x = bx, y = by, w = bw, h = bh}

    -- Scoring guide
    drawScoringGuide(1532)
end

function R.drawGame(game)
    setColor(C.COL_BG)
    rect("fill", 0, 0, C.VIRT_W, C.VIRT_H)
    drawFeltStripes()

    drawHeader(game)
    drawGrid(game)
    drawFooter(game)
end

function R.drawGameOver(game)
    setColor(C.COL_BG)
    rect("fill", 0, 0, C.VIRT_W, C.VIRT_H)
    drawFeltStripes()

    -- Dark overlay
    love.graphics.setColor(0, 0, 0, 0.72)
    rect("fill", 0, 0, C.VIRT_W, C.VIRT_H)

    -- Title
    setColor(C.COL_GOLD)
    centredText(fonts.xlarge, "Game Over!", C.VIRT_W / 2, 100)

    -- Total score
    setColor(C.COL_TEXT)
    centredText(fonts.large, "Total Score: " .. game.score, C.VIRT_W / 2, 226)

    if game.score > 0 and game.score >= game.highScore then
        setColor(C.COL_GOLD)
        centredText(fonts.medium, "✦ NEW HIGH SCORE ✦", C.VIRT_W / 2, 322)
    end

    -- Results per column
    local resultTop = 404
    local colW      = math.floor((C.VIRT_W - 40) / C.NUM_COLS)
    local cardW     = math.floor(colW * 0.80)
    local cardH     = math.floor(cardW * 1.4)
    local rowStep   = math.floor(cardH * 0.30)  -- overlapping fan

    for col = 1, C.NUM_COLS do
        local colX = 20 + (col - 1) * colW
        local res  = game.handResults[col]

        -- Column label
        setColor(C.COL_TEXT_DIM)
        love.graphics.setFont(fonts.hint)
        centredText(fonts.hint, "Col " .. col, colX + colW / 2, resultTop)

        -- Fanned card stack
        local stackTop = resultTop + 30
        for row, card in ipairs(game.columns[col]) do
            local cy = stackTop + (row - 1) * rowStep
            drawCard(card,
                math.floor(colX + (colW - cardW) / 2), cy, cardW, cardH)
        end

        -- Hand name + score
        if res then
            local labelY = stackTop + 5 * rowStep + cardH + 10
            local rank   = res.rank or 0
            if rank == 0 then
                setColor(C.COL_TEXT_DIM)
            elseif rank <= C.H_STRAIGHT_FLUSH then
                setColor(C.COL_GOLD)
            elseif rank <= C.H_FLUSH then
                setColor({0.4, 1.0, 0.4})
            elseif rank <= C.H_THREE_KIND then
                setColor({0.4, 0.8, 1.0})
            else
                setColor(C.COL_TEXT_DIM)
            end
            love.graphics.setFont(fonts.hint)
            centredText(fonts.hint, res.abbr or "—",
                colX + colW / 2, labelY)
            setColor(C.COL_GOLD)
            centredText(fonts.hint, "+" .. (res.score or 0),
                colX + colW / 2, labelY + 36)
        end
    end

    -- Play Again button
    local bw, bh = 520, 138
    local bx     = math.floor((C.VIRT_W - bw) / 2)
    local by     = C.VIRT_H - 302
    setColor(C.COL_BTN)
    rect("fill", bx, by, bw, bh, 26)
    setColor(C.COL_BTN_HOVER)
    love.graphics.setLineWidth(4)
    rect("line", bx, by, bw, bh, 26)
    setColor(C.COL_TEXT)
    centredText(fonts.xlarge, "PLAY AGAIN", bx + bw / 2, by + bh / 2)
    R.playAgainButton = {x = bx, y = by, w = bw, h = bh}

    -- Menu button
    local mw, mh = 300, 100
    local mx     = math.floor((C.VIRT_W - mw) / 2)
    local my     = by + bh + 28
    setColor(C.COL_HEADER_BG)
    rect("fill", mx, my, mw, mh, 20)
    setColor(C.COL_TEXT_DIM)
    love.graphics.setLineWidth(2)
    rect("line", mx, my, mw, mh, 20)
    setColor(C.COL_TEXT)
    centredText(fonts.medium, "MENU", mx + mw / 2, my + mh / 2)
    R.menuButton = {x = mx, y = my, w = mw, h = mh}
end

return R
