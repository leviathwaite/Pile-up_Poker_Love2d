# Pile-Up Poker — Love2D

A solitaire card game for **Android (Samsung S22 Ultra)** and desktop,
built with [Love2D](https://love2d.org/) (version 11.4+).

---

## Game Rules

| Step | Description |
|------|-------------|
| 1 | A shuffled deck feeds a **visible 5-card hand** at the bottom of the screen. |
| 2 | Tap a card in your hand, then tap one of the **4 column buttons** to place it. |
| 3 | Each column holds up to **4 cards**, forming a 4-card poker hand. |
| 4 | After all **16** card placements are made the game ends. |
| 5 | Each column is scored with the **4-card reference payouts** and totals are summed. |

### Scoring table

| Hand              | Points |
|-------------------|--------|
| Straight Flush ★  | 450    |
| 4 of a Kind ★     | 325    |
| Straight ★        | 180    |
| 3 of a Kind ★     | 125    |
| Flush             |  80    |
| 2 Pair            |  60    |
| Pair              |   5    |
| No Hand           |   0    |

Order of cards in hand doesn’t matter.  
★ indicates a quality hand.

Maximum possible score: **1800** (four Straight Flushes).

---

## Controls

| Input              | Action                          |
|--------------------|---------------------------------|
| **Tap / Click**    | Select hand cards / place cards / press buttons |
| **Keys 1 – 4**     | Place selected card in column 1-4 |
| **H**              | Toggle the hand reference       |
| **R**              | Restart game                    |
| **Escape**         | Return to menu / quit           |

---

## Project structure

```
.
├── conf.lua          Love2D window configuration
├── main.lua          Entry point & input handling
├── src/
│   ├── constants.lua Virtual resolution, colours, hand ranks
│   ├── deck.lua      52-card deck (build, shuffle, deal)
│   ├── eval.lua      Poker hand evaluator
│   ├── game.lua      Game state machine
│   └── render.lua    All drawing (procedural cards + Kenney asset support)
└── assets/
    ├── README.md     Instructions for Kenney card assets
    └── cards/        ← place Kenney PNG files here (optional)
```

---

## Running on desktop

```bash
# from the repository root
love .
```

Requires Love2D 11.4 or later — download from <https://love2d.org/>.

## Running on Android

1. Install the **Love2D for Android** app from the
   [Love2D releases page](https://github.com/love2d/love-android/releases)
   or the Google Play Store.
2. Package the game:
   ```bash
   zip -9 pile-up-poker.love conf.lua main.lua src/ assets/
   ```
3. Copy `pile-up-poker.love` to your device and open it with the Love2D app,
   or use `adb push` + intent:
   ```bash
   adb push pile-up-poker.love /sdcard/
   adb shell am start -a android.intent.action.VIEW \
       -d file:///sdcard/pile-up-poker.love \
       -t application/octet-stream org.love2d.android
   ```

The game is designed for the S22 Ultra portrait aspect ratio (≈ 19.3 : 9)
and uses large touch targets sized for phone play in portrait orientation.

---

## Card assets (optional)

The game ships with a built-in procedural card renderer so it works
out of the box.  For the full visual experience, drop
**Kenney's Playing Cards Pack** PNGs into `assets/cards/`.
See [`assets/README.md`](assets/README.md) for instructions.

---

## Licence

Project code: MIT.  
Kenney card assets (if downloaded separately): CC0.
