# Card Assets – Kenney's Playing Cards Pack

This folder is the expected home for
**Kenney's Playing Cards Pack** image assets.

## Why they are not included

The assets are free to download but are distributed by Kenney under the
[Creative Commons CC0 licence](https://kenney.nl/assets/playing-cards-pack).
Because the licence technically allows redistribution, they could be bundled,
but the pack is 50+ MB (PNG + SVG sources) so it is more practical to
download them separately.

## How to install

1. Visit <https://kenney.nl/assets/playing-cards-pack> and click **Download**.
2. Unzip the archive.
3. Copy the contents of the **PNG** (or **1x** folder if available) into
   `assets/cards/` so that the structure looks like:

```
assets/
└── cards/
    ├── cardClubs2.png
    ├── cardClubs3.png
    ├── …
    ├── cardSpadesA.png
    ├── cardBack_blue2.png
    └── …
```

4. The game auto-detects the assets on startup. If the folder is absent or
   empty it falls back to a built-in procedural card renderer so the game
   is always playable without them.

## Expected file naming

| Card              | File name                  |
|-------------------|----------------------------|
| Ace of Clubs      | `cardClubsA.png`           |
| 10 of Hearts      | `cardHearts10.png`         |
| King of Spades    | `cardSpadesK.png`          |
| Card back (blue)  | `cardBack_blue2.png`       |

> The naming follows Kenney's default export convention.  If your download
> uses a different convention (e.g. underscores or lower-case) just rename
> the files to match or adjust the path in `src/render.lua →
> R._tryLoadKenneyAssets()`.
