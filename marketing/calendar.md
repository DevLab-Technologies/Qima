# Qima content calendar: week 0 and 12 weeks

Status: plan for the owner to approve. Nothing has been posted. See `strategy.md` for the rules behind it.

How to read it:

- **Dates are the earliest possible.** Week 1 starts no earlier than Monday 9 November 2026, and only after the week-0 gate is met. If the gate slips, every row shifts. Weeks 9 to 12 should still end before Ramadan 1448, expected to begin around 8 February 2027 (astronomical estimate). So if the gate slips past 16 November, merge weeks from 1 to 8; don't cut 9 to 12.
- **Cadence each week:** X: 3 posts (2 Arabic in Egyptian dialect, 1 English), plus 15 minutes of replies on 4 days. LinkedIn: 1 English post. That comes to about 4.5 hours a week.
- **Messages:** M1 gold the way you buy it, M2 everything else in one number, M3 zakat, M4 no account and private. All trace to `brand/guidelines.md` §1.
- **Assets:** filenames are in `ios/fastlane/screenshots/en-US/` and `ar-SA/` (same names). Use the Arabic set for Arabic posts.
- **Disclaimers:** add the price disclaimer to any post that shows or claims a price or value. Add the zakat disclaimer to any zakat post. Exact wording is in `strategy.md` §5.
- **Sample data:** store screenshots use the seeded demo portfolio, with large gains on screen (for example "+59.40%" on `iphone_1_watchlist` and "+59.33%" on `iphone_4_gold_holdings`). In social crops, either crop the gain line out or add "Sample data" to the image. Never let a gain figure read as a promise of returns.
- **Labels:** "[after claims update]" means the post uses a claim that isn't in the claims table yet. It runs only after the claims-table update and after 3.1.0 is live. Each such slot has a fallback that uses table claims only.

---

## Week 0: the gate (no posts with a link)

| Task | Owner time | Done when |
|---|---|---|
| Confirm 3.1.0 is live on the App Store (and Play, if it ships there) | 10 min | Public App Store page shows 3.1.0 |
| Upload the corrected store text in all four languages (already in `ios/fastlane/metadata/` and `android/fastlane/metadata/`) | 1 h | Live US subtitle reads "Gold prices by karat & zakat" |
| Create App Store Connect campaign links `ct=x` and `ct=linkedin` | 20 min | Both links open the listing |
| Set the X and LinkedIn bios to mention Qima and https://qima.money | 15 min | Bio says the owner built Qima |
| Reserve a Qima handle on X (no posts) | 10 min | Handle held |
| Crop the week 1 and 2 screenshots; record the week 2 clip | 45 min | Files ready |

Total: about 2.5 to 3 hours, once.

---

## Weeks 1 to 8: founder story and product proof

| Week (earliest start) | Theme | Platform | Post type | Language | Message | Asset |
|---|---|---|---|---|---|---|
| **1** (9 Nov) | Why I built Qima: gold first | X | Single post, launch | AR | M1, M4 | `iphone_1_watchlist` (ar-SA), gain line cropped |
| | | X | Single post, question hook | AR | M1 | `iphone_2_gold_detail` (ar-SA) |
| | | X | Thread, 5 posts | EN | M1, M2, M4 | `iphone_1_watchlist`, `iphone_2_gold_detail`, `iphone_8_add_asset` |
| | | LinkedIn | Long post: why gold first | EN | M1, M4 | `iphone_2_gold_detail` |
| **2** (16 Nov) | Gold the way you buy it: karat and units | X | Single post | AR | M1, M2 | `iphone_4_gold_holdings` (ar-SA) |
| | | X | Screen recording, 10 to 20 s | AR | M1 | Clip: watchlist with gold in USD per oz t and in SAR per gram at 21K |
| | | X | Single post | EN | M1 | `iphone_2_gold_detail` |
| | | LinkedIn | Long post: designing for the unit people think in | EN | M1, M2 | `iphone_4_gold_holdings` |
| **3** (23 Nov) | No account: privacy by design | X | Single post | AR | M4 | `iphone_8_add_asset` (ar-SA) |
| | | X | Thread, 4 posts: what "no account" means in practice | EN | M4 | Settings screens for app lock and backup (new crops) |
| | | X | Single post: hide balances | AR | M4 | Clip: hide-balances toggle, 10 s |
| | | LinkedIn | Long post: why I didn't build accounts or a server | EN | M4 | `iphone_8_add_asset` |
| **4** (30 Nov) | Everything else in one number | X | Single post | AR | M2 | `iphone_5_portfolio` (ar-SA), gain cropped |
| | | X | Single post | EN | M2 | `iphone_6_allocation` |
| | | X | Single post: CSV import | AR | M2 | New crop: CSV import screen |
| | | LinkedIn | Long post: one total across metals, crypto and cash | EN | M2 | `iphone_6_allocation` |
| **5** (7 Dec) | Building right-to-left Arabic properly | X | Thread, 5 posts: what I learned shipping full RTL | EN | Languages row | `iphone_1_watchlist` en-US and ar-SA side by side |
| | | X | Single post | AR | Languages row, M1 | `iphone_2_gold_detail` (ar-SA) |
| | | X | Reply sessions in Flutter threads | EN | Languages row | None |
| | | LinkedIn | Carousel: four languages, one layout, both directions | EN | Languages row | 4 to 6 slides from en-US and ar-SA screenshots |
| **6** (14 Dec) | Price alerts and widgets | X | Single post: alerts | AR | Alerts row | New crop: alert setup screen |
| | | X | Single post: widgets | EN | Widgets row (answer 17) | New capture: Home Screen and Lock Screen widgets |
| | | X | Single post: widgets | AR | Widgets row | Same capture, Arabic |
| | | LinkedIn | Long post: why alerts are opt-in, by level or by % move | EN | Alerts row | Alert setup crop |
| **7** (21 Dec) | What I cut, and why | X | Thread, 4 posts: no ads, no analytics, no subscription | EN | M4 | Plain text, lockup on dark |
| | | X | Single post | AR | M4 | Lockup on dark (`brand/assets/logo/qima-lockup-on-dark.svg`) |
| | | X | Single post: free, no in-app purchases | AR | Free row | `iphone_8_add_asset` (ar-SA) |
| | | LinkedIn | Long post: the features I chose not to build | EN | M4 | Lockup on dark |
| **8** (28 Dec) | What shipped in 3.1.0 | X | Single post: share as image [after claims update] | AR | Share (not in table yet) | `iphone_3_share` (ar-SA). Fallback: charts post with `iphone_2_gold_detail`, Charts row |
| | | X | Single post: reorder the watchlist [after claims update] | EN | Reorder (not in table yet) | Clip: drag to reorder. Fallback: allocation by karat, Allocation row |
| | | X | Single post: charts from one day to all time | AR | Charts row | `iphone_2_gold_detail` (ar-SA) |
| | | LinkedIn | Long post: shipping 3.1.0 [after claims update] | EN | Share, reorder | `iphone_3_share`. Fallback: year-end post on the building story, M1 and M4 |

## Weeks 9 to 12: zakat run-up

Every post in these weeks carries the zakat disclaimer. Posts that show a value also carry the price disclaimer. No ruling language: Qima calculates, the person decides.

| Week (earliest start) | Theme | Platform | Post type | Language | Message | Asset |
|---|---|---|---|---|---|---|
| **9** (4 Jan) | What Qima's zakat screen does | X | Single post | AR | M3 | `iphone_7_zakat` (ar-SA), cropped to the "Zakat due" card (guidelines §10 social spec) |
| | | X | Single post | EN | M3 | `iphone_7_zakat`, same crop |
| | | X | Single post: what counts toward nisab | AR | M3 | New crop: "what counts" settings |
| | | LinkedIn | Long post: building a zakat calculator that doesn't rule | EN | M3 | `iphone_7_zakat` |
| **10** (11 Jan) | Nisab and hawl | X | Thread, 4 posts: nisab on 85 g gold or 595 g silver; hawl on Hijri or Gregorian | AR | M3 | Hawl picker crop |
| | | X | Single post | EN | M3 | 1080 × 1080 zakat social post (guidelines §10) |
| | | X | Single post: the hawl reminder | AR | M3 | Reminder settings crop |
| | | LinkedIn | Long post: handling Hijri and Gregorian dates | EN | M3 | Hawl picker crop |
| **11** (18 Jan) | Before you share your phone: privacy in a family | X | Single post: hide balances, app lock | AR | M4 | Clip: hide balances, app lock |
| | | X | Single post: AES-256 backups | EN | M4 | Backup export sheet crop |
| | | X | Single post: 160+ currencies [after claims update] | EN | 160+ currencies (not in table yet) | Currency picker crop. Fallback: "in the currency you choose", M1 |
| | | LinkedIn | Long post: password-protected backups without a server | EN | M4 | Backup export sheet crop |
| **12** (25 Jan) | Ramadan run-up: set your hawl reminder | X | Single post | AR | M3 | `iphone_7_zakat` (ar-SA) |
| | | X | Single post | AR | M3, M1 | Social post, Arabic version (guidelines §10) |
| | | X | Single post | EN | M3 | `iphone_7_zakat` |
| | | LinkedIn | Long post: 12 weeks of building in public, and what I learned | EN | M1 to M4 | Lockup on dark plus one screenshot. No user or download numbers unless the owner chooses to share them from App Store Connect |

---

## Reactive slots (any week, within the same 4.5 hours)

| Trigger | What to post | Rules |
|---|---|---|
| A big gold price move in the news | A short Arabic post: "here's how it looks in grams at 21K", with a screenshot | Price disclaimer. No predictions, no "buy now", no comment on where prices go next |
| Someone asks about gold or zakat apps in a thread | A reply that says the owner built Qima, and one table claim that answers the question | Disclose ownership; one link at most |
| A Flutter or right-to-left question | A helpful reply; mention Qima only if it's relevant | No link unless asked |

## Assets to build (separate job, needs the owner's approval)

Templates don't exist yet (`brand/assets/` holds only the logo, lockups and icons). The calendar needs:

| Template | Size | Spec |
|---|---|---|
| Single image post | 1080 × 1080 | Guidelines §10 social post: `bg0` dark, Almarai, lockup bottom left |
| X landscape image | 1200 × 675 | Same style, screenshot cropped and centred |
| LinkedIn carousel slide | 1080 × 1350 | Same style, one idea per slide, page number |
| Short clip end card | 1080 × 1920, 2 s | Lockup on dark, no tagline, no claims |

Until they exist, posts use cropped real screenshots, plus the lockup where noted.
