-- Game-wide constants

local C = {}

-- ── Virtual resolution ───────────────────────────────────────────────────────
-- Designed for Samsung S22 Ultra portrait (1440 × 3088 ≈ 19.3 : 9).
-- We use 1080 × 2340 (2.166:1) as the virtual canvas; Love2D scales it to
-- fill any physical screen while preserving the aspect ratio.
C.VIRT_W = 1080
C.VIRT_H = 2340

-- ── Card dimensions (in virtual pixels) ────────────────────────────────────
-- Standard card ratio is 2.5 : 3.5 = 5 : 7
C.CARD_W = 200
C.CARD_H = 280   -- 200 × 1.40

-- ── Board layout ────────────────────────────────────────────────────────────
C.NUM_COLS     = 5
C.NUM_ROWS     = 5   -- cards per column (hand size)
C.GRID_MARGIN  = 15  -- left / right margin around the grid
C.COL_GAP      = 10  -- horizontal gap between columns
C.ROW_GAP      = 8   -- vertical gap between rows

-- ── Colours ─────────────────────────────────────────────────────────────────
C.COL_BG            = {0.09, 0.40, 0.09}    -- dark green felt
C.COL_FELT_STRIPE   = {0.11, 0.45, 0.11}
C.COL_CARD_FACE     = {1.00, 1.00, 1.00}
C.COL_CARD_BACK_A   = {0.18, 0.28, 0.80}
C.COL_CARD_BACK_B   = {0.24, 0.38, 0.90}
C.COL_RED           = {0.88, 0.12, 0.12}
C.COL_BLACK         = {0.08, 0.08, 0.08}
C.COL_GOLD          = {1.00, 0.84, 0.00}
C.COL_HEADER_BG     = {0.00, 0.18, 0.00, 0.85}
C.COL_FOOTER_BG     = {0.00, 0.12, 0.00, 0.90}
C.COL_BTN           = {0.13, 0.52, 0.13}
C.COL_BTN_HOVER     = {0.22, 0.70, 0.22}
C.COL_BTN_DISABLED  = {0.28, 0.28, 0.28}
C.COL_TEXT          = {1.00, 1.00, 1.00}
C.COL_TEXT_DIM      = {0.75, 0.75, 0.75}
C.COL_SHADOW        = {0.00, 0.00, 0.00, 0.35}
C.COL_SLOT          = {0.00, 0.00, 0.00, 0.22}
C.COL_SLOT_BORDER   = {1.00, 1.00, 1.00, 0.18}
C.COL_HIGHLIGHT     = {1.00, 0.84, 0.00, 0.30}

-- ── Game states ─────────────────────────────────────────────────────────────
C.ST_MENU     = "menu"
C.ST_PLAYING  = "playing"
C.ST_GAMEOVER = "gameover"

-- ── Poker hand ranks (lower index = better) ─────────────────────────────────
C.H_ROYAL_FLUSH    = 1
C.H_STRAIGHT_FLUSH = 2
C.H_FOUR_KIND      = 3
C.H_FULL_HOUSE     = 4
C.H_FLUSH          = 5
C.H_STRAIGHT       = 6
C.H_THREE_KIND     = 7
C.H_TWO_PAIR       = 8
C.H_ONE_PAIR       = 9
C.H_HIGH_CARD      = 10

C.HAND_INFO = {
    [C.H_ROYAL_FLUSH]    = {name = "Royal Flush",     abbr = "Royal!",    score = 100},
    [C.H_STRAIGHT_FLUSH] = {name = "Straight Flush",  abbr = "Str.Flush", score = 75},
    [C.H_FOUR_KIND]      = {name = "Four of a Kind",  abbr = "4-of-Kind", score = 50},
    [C.H_FULL_HOUSE]     = {name = "Full House",       abbr = "Full Hse",  score = 25},
    [C.H_FLUSH]          = {name = "Flush",            abbr = "Flush",     score = 20},
    [C.H_STRAIGHT]       = {name = "Straight",         abbr = "Straight",  score = 15},
    [C.H_THREE_KIND]     = {name = "Three of a Kind",  abbr = "3-of-Kind", score = 10},
    [C.H_TWO_PAIR]       = {name = "Two Pair",         abbr = "Two Pair",  score = 5},
    [C.H_ONE_PAIR]       = {name = "One Pair",         abbr = "One Pair",  score = 2},
    [C.H_HIGH_CARD]      = {name = "High Card",        abbr = "Hi Card",   score = 1},
}

-- Maximum possible score (all Royal Flushes)
C.MAX_SCORE = C.HAND_INFO[C.H_ROYAL_FLUSH].score * C.NUM_COLS  -- 500

return C
