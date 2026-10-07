# Truth Finder AI — App Store screenshot generator

Marketing frames for the iOS app listing. Based on the [app-store-screenshots](https://github.com/ParthJadhav/app-store-screenshots) agent skill (Next.js + `html-to-image`).

## Run locally

```bash
cd marketing/app-store-screenshots
npm install
npm run dev
```

Open [http://localhost:3000](http://localhost:3000), choose export size, then **Export this slide** or **Export all PNGs**.

### Generate PNGs on disk (CI / headless)

Writes **1320×2868** (6.9″) files to `exported-store-screenshots/`:

```bash
npm run generate:screenshots
```

Uses Puppeteer + production `next start` and `window.__TRUTHFINDER_EXPORT_SLIDE__`. Requires a one-time `npm install` (includes Chromium).

## Replace screenshots

Drop PNG captures into `public/screenshots/` (use consistent names):

| File | Suggested capture |
|------|-------------------|
| `home.png` | Verify tab — main screen |
| `verify.png` | Input + Paste / Verify |
| `result.png` | Result card with verdict |
| `history.png` | History tab |
| `favorites.png` | Favorites tab |

**Tip:** Capture on a **6.1″** simulator first to minimize cropping surprises ([skill README](https://github.com/ParthJadhav/app-store-screenshots)).

Flatten screenshots to **RGB** (no alpha) if exports look blank.

## Assets

- `public/mockup.png` — iPhone frame from the skill
- `public/app-icon.png` — copy of app icon (optional for future slides)

## Brand colors (from the iOS app)

The SwiftUI app uses **system semantic colors** (see `ContentView.swift`, `TruthModels.swift` / `TruthVerdict.color`). Hex equivalents for marketing are in `src/app/truthfinder-colors.ts`:

| Token | Hex | Code reference |
|--------|-----|----------------|
| Grouped background | `#F2F2F7` | `Color(.systemGroupedBackground)` |
| System background | `#FFFFFF` | `Color(.systemBackground)` |
| System gray 6 | `#F2F2F7` | `Color(.systemGray6)` (Paste button) |
| Accent / blue | `#007AFF` | `Color.accentColor`, `.blue` (default iOS tint; `AccentColor` asset is unset) |
| Verdict “good” | `#34C759` | `.green` for true / likely true |
| Verdict uncertain | `#FF9500` | `.orange` |
| Verdict “bad” | `#FF3B30` | `.red` |
| Favorite star | `#FFCC00` | `.yellow` |
| Info banner wash | `#E8F1FF` | `Color.blue.opacity(0.1)` (approximate) |
