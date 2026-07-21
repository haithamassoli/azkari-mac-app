# App Store assets — Dhikr (Mac)

Marketing screenshots for the Mac App Store, plus a recipe for the (optional) App Preview.

## Screenshots — ready to upload

Six frames in [`out/`](out/), each **2880 × 1800** (a valid Mac App Store size). Upload order = the order below; the first is the most important (it shows in search results).

| # | File | Shows |
|---|------|-------|
| 1 | `out/01-hero.png` | Corner popup with Arabic + transliteration + translation |
| 2 | `out/02-counter.png` | Tasbeeh counter mid-count (17 / 33) |
| 3 | `out/03-menubar.png` | Menu-bar dropdown (Show / Pause / Settings / Quit) |
| 4 | `out/04-settings.png` | General settings — interval, selection, time-aware, launch at login |
| 5 | `out/05-library.png` | Adhkar library — enable, edit, add your own |
| 6 | `out/06-bilingual.png` | Fully right-to-left Arabic UI |

**Where:** App Store Connect → your app → (version) → **App Previews and Screenshots**. Mac has one screenshot set (drag to reorder, up to 10). Content is real app UI/strings on a marketing background — standard and accepted for screenshots.

## App Preview (optional video)

Apple requires previews to be **captured from the app running** — a marketing mockup can be rejected here (unlike screenshots). So record the real app:

- **Specs:** `.mov`/`.mp4`, **15–30 s**, **1920 × 1080** (or 3840 × 2160), H.264. Up to 3 per localization. The first frame is the poster.
- **Record:** ⌘⇧5 → record a 1920×1080 region (or full screen, then scale: `ffmpeg -i in.mov -vf scale=1920:1080 -c:v libx264 -crf 18 out.mov`).

**30-second shot list:**
1. `0–3s` Click the moon menu-bar icon → dropdown opens.
2. `3–6s` Click **Show a Dhikr Now** → popup fades into the corner.
3. `6–12s` A counter dhikr appears — tap the card, count climbs to 33, "Done".
4. `12–20s` Settings → drag the font-size slider (Arabic preview grows), toggle translation, change the interval.
5. `20–26s` Adhkar tab — toggle a few, point at **Add Dhikr**.
6. `26–30s` Switch language → whole UI flips to Arabic RTL. End on the popup + "Dhikr".

## Regenerating / editing

Everything is one self-contained file: [`screenshots.html`](screenshots.html). Each frame is a `<section class="shot" id="…">`; edit copy/content there and re-capture:

```
# in the browser (Chrome DevTools MCP or any headless Chrome):
# 1. set viewport to 1440x900 at devicePixelRatio 2
# 2. open  screenshots.html#<id>   (hero | counter | menubar | settings | library | bilingual)
# 3. screenshot the viewport  ->  2880x1800 png
```

<!-- ponytail: HTML→browser capture, not native screencapture. Faithful to the
     real SwiftUI UI + adhkar.json content; swap for real app captures only if
     App Review ever pushes back on a specific frame. -->
