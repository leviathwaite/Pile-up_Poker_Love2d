--[[
  Pile-Up Poker – Love2D
  ======================
  A solitaire card game for Android (Samsung S22 Ultra) and desktop.

  Rules
  -----
  • A shuffled 52-card deck is dealt one card at a time.
  • Tap one of the 5 column buttons at the bottom to place the current card
    in that column.
  • Each column holds up to 5 cards, forming a poker hand.
  • After all 25 card slots are filled the game ends and each column is scored
    as a standard 5-card poker hand.
  • Try to maximise your total score across all five hands!

  Controls
  --------
  Touch / tap  – place card / select menu buttons
  Keyboard 1-5 – place card in column 1-5 (desktop convenience)
  R            – restart
  Escape       – return to menu / quit

  Running
  -------
  love .                         (from project root)
  love /path/to/Pile-up_Poker_Love2d
--]]

local C    = require("src.constants")
local Game = require("src.game")
local R    = require("src.render")

-- ── State ─────────────────────────────────────────────────────────────────────
local game

-- ── Love2D callbacks ──────────────────────────────────────────────────────────

function love.load()
    math.randomseed(os.time())
    love.graphics.setDefaultFilter("linear", "linear")
    love.graphics.setBackgroundColor(0.06, 0.06, 0.06)

    R.init()
    game = Game.new()
end

function love.update(dt)
    game:update(dt)
end

function love.draw()
    love.graphics.push()
    R.setupTransform()

    if game.state == C.ST_MENU then
        R.drawMenu(game.highScore)
    elseif game.state == C.ST_PLAYING then
        R.drawGame(game)
    elseif game.state == C.ST_GAMEOVER then
        R.drawGameOver(game)
    end

    love.graphics.pop()
end

-- ── Input helpers ─────────────────────────────────────────────────────────────

local function handleTap(sx, sy)
    local vx, vy = R.toVirtual(sx, sy)

    if game.state == C.ST_MENU then
        if R.hit(R.playButton, vx, vy) then
            game:startNewGame()
        end

    elseif game.state == C.ST_PLAYING then
        for col, btn in ipairs(R.colButtons) do
            if R.hit(btn, vx, vy) then
                game:placeCard(col)
                break
            end
        end

    elseif game.state == C.ST_GAMEOVER then
        if R.hit(R.playAgainButton, vx, vy) then
            game:startNewGame()
        elseif R.hit(R.menuButton, vx, vy) then
            game.state = C.ST_MENU
        end
    end
end

-- ── Love2D input callbacks ────────────────────────────────────────────────────

function love.mousepressed(x, y, button)
    if button == 1 then handleTap(x, y) end
end

function love.touchpressed(_id, x, y, _dx, _dy, _pressure)
    handleTap(x, y)
end

function love.keypressed(key)
    -- Column hotkeys 1-5 (desktop convenience)
    local colKey = tonumber(key)
    if colKey and colKey >= 1 and colKey <= C.NUM_COLS then
        if game.state == C.ST_PLAYING then
            game:placeCard(colKey)
        end
        return
    end

    if key == "r" then
        if game.state == C.ST_PLAYING or game.state == C.ST_GAMEOVER then
            game:startNewGame()
        end
    elseif key == "escape" then
        if game.state == C.ST_PLAYING then
            game.state = C.ST_MENU
        elseif game.state == C.ST_MENU then
            love.event.quit()
        elseif game.state == C.ST_GAMEOVER then
            game.state = C.ST_MENU
        end
    end
end
