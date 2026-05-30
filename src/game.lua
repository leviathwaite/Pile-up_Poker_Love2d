-- Game state manager

local C    = require("src.constants")
local Deck = require("src.deck")
local Eval = require("src.eval")

local Game = {}
Game.__index = Game

function Game.new()
    local self = setmetatable({}, Game)
    self.highScore = 0
    self:_init()
    return self
end

-- ── Internal reset ────────────────────────────────────────────────────────────

function Game:_init()
    self.state       = C.ST_MENU
    self.deck        = nil
    self.columns     = {{}, {}, {}, {}, {}}
    self.currentCard = nil
    self.score       = 0
    self.handResults = {}
    self.moveCount   = 0
    self.totalMoves  = C.NUM_COLS * C.NUM_ROWS   -- 25
end

-- ── Public API ────────────────────────────────────────────────────────────────

function Game:startNewGame()
    self.deck = Deck.new()
    self.deck:shuffle()
    -- Reset each column to an empty table; cards from the previous game
    -- must be cleared explicitly here since _init() is not called again.
    for i = 1, C.NUM_COLS do self.columns[i] = {} end
    self.handResults = {}
    self.score       = 0
    self.moveCount   = 0
    self.currentCard = nil
    self.state       = C.ST_PLAYING
    self:_dealNext()
end

--- Place the current card into column `col` (1-based).
--- Returns true on success, false if the column is full.
function Game:placeCard(col)
    if self.state ~= C.ST_PLAYING then return false end
    if not self.currentCard then return false end
    if not self:_canPlace(col) then return false end

    table.insert(self.columns[col], self.currentCard)
    self.currentCard = nil
    self.moveCount   = self.moveCount + 1

    if self.moveCount >= self.totalMoves or not self:_hasSpace() then
        self:_endGame()
    else
        self:_dealNext()
    end
    return true
end

function Game:canPlace(col)
    return self:_canPlace(col)
end

--- Returns the current hand hint string for a column, or nil.
function Game:columnHint(col)
    local cards = self.columns[col]
    if #cards == 0 then return nil end
    if #cards == 5 then
        local res = Eval.evaluate(cards)
        return res.abbr
    end
    return Eval.hint(cards)
end

--- Returns evaluated result table for a complete column, or nil.
function Game:columnResult(col)
    return self.handResults[col]
end

function Game:update(_dt) end   -- reserved for future animations

-- ── Private helpers ───────────────────────────────────────────────────────────

function Game:_canPlace(col)
    return self.columns[col] ~= nil and #self.columns[col] < C.NUM_ROWS
end

function Game:_hasSpace()
    for i = 1, C.NUM_COLS do
        if #self.columns[i] < C.NUM_ROWS then return true end
    end
    return false
end

function Game:_dealNext()
    if self.deck:size() > 0 then
        self.currentCard = self.deck:deal()
    else
        self.currentCard = nil
    end
end

function Game:_endGame()
    self.score = 0
    self.handResults = {}
    for i = 1, C.NUM_COLS do
        local col = self.columns[i]
        local res
        if #col == C.NUM_ROWS then
            res = Eval.evaluate(col)
        else
            res = {rank = 0, name = "Incomplete", abbr = "—", score = 0}
        end
        self.handResults[i] = res
        self.score = self.score + res.score
    end
    if self.score > self.highScore then
        self.highScore = self.score
    end
    self.state = C.ST_GAMEOVER
end

return Game
