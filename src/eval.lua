-- Poker hand evaluator
-- Handles both full 5-card evaluation and partial (in-progress) hints.

local C = require("src.constants")

local Eval = {}

-- ── Internal helpers ─────────────────────────────────────────────────────────

local function valueCounts(cards)
    local counts = {}
    for _, card in ipairs(cards) do
        counts[card.numValue] = (counts[card.numValue] or 0) + 1
    end
    return counts
end

local function countList(counts)
    local list = {}
    for _, n in pairs(counts) do
        table.insert(list, n)
    end
    table.sort(list, function(a, b) return a > b end)
    return list
end

local function isFlush(cards)
    local suit = cards[1].suit
    for i = 2, #cards do
        if cards[i].suit ~= suit then return false end
    end
    return true
end

local function isStraight(sortedVals)
    -- Normal straight
    local ok = true
    for i = 2, #sortedVals do
        if sortedVals[i] ~= sortedVals[i - 1] + 1 then
            ok = false; break
        end
    end
    if ok then return true end
    -- Ace-low: A-2-3-4-5  (ace is 14, treat as 1)
    if sortedVals[#sortedVals] == 14 then
        local aceLow = {}
        for i = 1, #sortedVals - 1 do aceLow[i] = sortedVals[i] end
        table.insert(aceLow, 1)
        table.sort(aceLow)
        ok = true
        for i = 2, #aceLow do
            if aceLow[i] ~= aceLow[i - 1] + 1 then ok = false; break end
        end
        if ok then return true end
    end
    return false
end

local function sortedValues(cards)
    local vals = {}
    for _, c in ipairs(cards) do table.insert(vals, c.numValue) end
    table.sort(vals)
    return vals
end

-- ── Public API ────────────────────────────────────────────────────────────────

--- Evaluate a complete 5-card hand.
--- Returns { rank, name, abbr, score }
function Eval.evaluate(cards)
    assert(#cards == 5, "evaluate() requires exactly 5 cards")

    local vals  = sortedValues(cards)
    local flush = isFlush(cards)
    local str   = isStraight(vals)
    local vc    = valueCounts(cards)
    local cl    = countList(vc)

    -- Royal Flush: straight flush A-high
    if flush and str and vals[5] == 14 and vals[1] == 10 then
        local info = C.HAND_INFO[C.H_ROYAL_FLUSH]
        return {rank = C.H_ROYAL_FLUSH, name = info.name, abbr = info.abbr, score = info.score}
    end

    if flush and str then
        local info = C.HAND_INFO[C.H_STRAIGHT_FLUSH]
        return {rank = C.H_STRAIGHT_FLUSH, name = info.name, abbr = info.abbr, score = info.score}
    end

    if cl[1] == 4 then
        local info = C.HAND_INFO[C.H_FOUR_KIND]
        return {rank = C.H_FOUR_KIND, name = info.name, abbr = info.abbr, score = info.score}
    end

    if cl[1] == 3 and cl[2] == 2 then
        local info = C.HAND_INFO[C.H_FULL_HOUSE]
        return {rank = C.H_FULL_HOUSE, name = info.name, abbr = info.abbr, score = info.score}
    end

    if flush then
        local info = C.HAND_INFO[C.H_FLUSH]
        return {rank = C.H_FLUSH, name = info.name, abbr = info.abbr, score = info.score}
    end

    if str then
        local info = C.HAND_INFO[C.H_STRAIGHT]
        return {rank = C.H_STRAIGHT, name = info.name, abbr = info.abbr, score = info.score}
    end

    if cl[1] == 3 then
        local info = C.HAND_INFO[C.H_THREE_KIND]
        return {rank = C.H_THREE_KIND, name = info.name, abbr = info.abbr, score = info.score}
    end

    if cl[1] == 2 and cl[2] == 2 then
        local info = C.HAND_INFO[C.H_TWO_PAIR]
        return {rank = C.H_TWO_PAIR, name = info.name, abbr = info.abbr, score = info.score}
    end

    if cl[1] == 2 then
        local info = C.HAND_INFO[C.H_ONE_PAIR]
        return {rank = C.H_ONE_PAIR, name = info.name, abbr = info.abbr, score = info.score}
    end

    local info = C.HAND_INFO[C.H_HIGH_CARD]
    return {rank = C.H_HIGH_CARD, name = info.name, abbr = info.abbr, score = info.score}
end

--- Quick hint for an incomplete column (1-4 cards).
--- Returns a short label string or nil if nothing notable yet.
function Eval.hint(cards)
    if #cards < 2 then return nil end

    local vc = valueCounts(cards)
    local cl = countList(vc)

    if cl[1] >= 4 then return "4-of-Kind" end
    if cl[1] == 3 and (cl[2] or 0) >= 2 then return "Full Hse" end
    if cl[1] == 3 then return "3-of-Kind" end
    if cl[1] == 2 and (cl[2] or 0) == 2 then return "Two Pair" end
    if cl[1] == 2 then return "One Pair" end

    -- Check flush draw (all same suit)
    local suitMatch = true
    local s0 = cards[1].suit
    for i = 2, #cards do
        if cards[i].suit ~= s0 then suitMatch = false; break end
    end
    if suitMatch and #cards >= 3 then return "Flush?" end

    return nil
end

return Eval
