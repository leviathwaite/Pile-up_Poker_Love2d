-- Standard 52-card deck

local Deck = {}
Deck.__index = Deck

local SUITS  = {"hearts", "diamonds", "clubs", "spades"}
local VALUES = {"A","2","3","4","5","6","7","8","9","10","J","Q","K"}
local NUM    = {  14, 2,  3,  4,  5,  6,  7,  8,  9,  10, 11, 12, 13}

function Deck.new()
    local self = setmetatable({}, Deck)
    self:_build()
    return self
end

function Deck:_build()
    self._cards = {}
    for _, suit in ipairs(SUITS) do
        for i, val in ipairs(VALUES) do
            table.insert(self._cards, {
                suit     = suit,
                value    = val,
                numValue = NUM[i],
                isRed    = (suit == "hearts" or suit == "diamonds"),
            })
        end
    end
end

function Deck:shuffle()
    local n = #self._cards
    for i = n, 2, -1 do
        local j = math.random(1, i)
        self._cards[i], self._cards[j] = self._cards[j], self._cards[i]
    end
end

-- Deal from the top (last element) for O(1) removal
function Deck:deal()
    return table.remove(self._cards)
end

function Deck:size()
    return #self._cards
end

return Deck
