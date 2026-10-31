# Qima marketing: Phase 1 proposal

Status: proposal for the owner to approve. Nothing has been posted, sent or published. Prepared 31 October 2026.

Sources: `brand/guidelines.md` (sections 1, 8, 10), `brand/open-questions.md`, `brand/discovery.md`, `site/index.html`, `site/privacy.html`, `ios/fastlane/metadata/en-US/*`, `android/fastlane/metadata/android/en-US/*`, store screenshots, and the owner's public profiles as seen without signing in.

---

## 1. What I found first

### The owner's public profiles

| Profile | What was visible without signing in |
|---|---|
| X, `@AHMEDLEKHAYYAT` (the handle in the brief) | "This account doesn't exist." |
| X, `@AHMEDELKHAYYAT` (confirmed by the owner as the right account) | Bio: "Software Engineering Manager, Machine Learning, Generative AI, CTO". Location Riyadh. Joined October 2010. 3,195 followers and 213 following, as shown on 31 October 2026. Logged-out visitors see only one post: a joking post in Egyptian colloquial Arabic, with emoji, about someone who let AI write their posts without checking them. |
| LinkedIn, `linkedin.com/in/elkhayyat` | Sign-in wall. Nothing was readable. |
| `elkhayyat.me` (linked from X) | A one-line page offering help hiring software teams. |

What this suggests (to be confirmed in question 5): the audience is mostly Arabic-speaking tech people in Saudi Arabia and Egypt. That overlaps the primary audience: Gulf professionals, many of whom hold gold. The owner already writes casually in Arabic. Qima posts will need to leave out the emoji the owner uses today (rule 7).

### Public surfaces that would undercut a campaign today

Promoting now would send people to pages that break the claims rules or lead nowhere. I propose fixing these before the first post. These are proposals only; no changes have been made.

| # | Where | Today | Problem |
|---|---|---|---|
| F1 | `site/index.html:41-42` | Store buttons are `href="#"` and disabled | Visitors from a post can't install |
| F2 | `site/index.html` hero | "stored only on your phone" | Not true with iCloud sync (never-say list) |
| F3 | `site/index.html` details | "Grams, ounces and tolas" | Tolas are on hold |
| F4 | `site/index.html` details | "Widgets on Android. Coming to iOS." | Waiting on question 17 |
| F5 | `site/index.html` privacy list | "Holdings deleted when you uninstall" | Not true with iCloud sync |
| F6 | `site/privacy.html:7` meta description | "Your portfolio never leaves your device." | Never-say list |
| F7 | App Store promotional text | "priced live, stored only on your own devices", with no gold or karat | Doesn't lead with gold. The live-price disclaimer is only in the description |
| F8 | App Store subtitle | "Metals, crypto & stocks prices" | Gives stocks headline weight (question 14); guidelines §10 suggests "Gold, metals & all you own" |
| F9 | App Store description | Omits zakat, allocation, alerts, app lock and backups | These are the strongest reasons to install. Guidelines §10 already has replacement copy |
| F10 | Play short description | "Gold, silver, crypto, stocks and currencies in one private portfolio. No ads." | Has no karat and no zakat |

Update, 31 October 2026: F1 to F10 are fixed in the repository (site, privacy and terms pages, and every App Store and Play listing in all four languages, with Arabic in Egyptian dialect). They go live only when the site is deployed and the listings are uploaded.

The `site/` fixes are listed in guidelines §10. The listing copy in §10 is ready to use, and the Arabic version waits on questions 23 and 24.

### Claims the plan wants that are not in the claims table

| Claim | Why the plan wants it | Evidence it ships |
|---|---|---|
| Share an asset as an image, sized for WhatsApp, Instagram, Facebook and LinkedIn | It suits founder posts ("here's gold today, made in Qima") and it is in the store screenshots | 3.1.0 release notes; `iphone_3_share` |
| Reorder or sort the watchlist | Small, but good for "what shipped" posts | 3.1.0 release notes |
| 160+ display currencies | Strong for the secondary audience | `discovery.md`, from `README.md` |
| Opens offline | Fits the privacy story | `site/index.html` "Offline" |
| Available on Mac, and on Android | Needed to name platforms in posts | Mac was submitted (`discovery.md`); there is a Play pipeline; not confirmed live |

Until each one is added to the claims table, the drafts will not use it.

### Missing asset

The brief says `brand/assets/` holds social templates. It doesn't: it holds the logo, lockups and icons. The only social spec is the 1080 × 1080 zakat post in guidelines §10. Phase 2 will specify templates in the calendar. Building them is a separate job for the owner to approve.

---

## 2. Strategy proposal (one page)

**Objective, 90 days (default, see question 1).** Get Qima installed by gold holders in Saudi Arabia, the Gulf and Egypt, and give the owner a reputation as a careful builder. Nothing is measured inside the app. Measurement uses store campaign links and native platform analytics. Weeks 1 and 2 set a baseline. Targets are set from that baseline in week 3, not guessed now.

**Sequence.**
1. Week 0: fix F1 to F10, the store and site claim problems above.
2. Weeks 1 to 8: founder story and product proof.
3. Weeks 9 to 12: zakat season run-up. Ramadan 1448 is expected to begin around 8 February 2027. That is an astronomical estimate; the actual date depends on moon sighting. Many people pay zakat in Ramadan, so this window is the strongest reason to care.

**Audiences.**

| | Who | Where they are reached |
|---|---|---|
| Primary | Arab and Gulf households and individuals who hold physical gold | X in Arabic, the owner's Riyadh network, Arabic store listing, zakat season |
| Secondary | People anywhere who hold metals with crypto, stocks and cash and want one private total | X in English, LinkedIn, privacy and indie-app communities |
| Amplifiers | The owner's tech followers: they may not hold gold, but they share "built it myself" stories | LinkedIn, X Flutter and indie conversations |

**Core messages.** Each is traced to the claims table in `guidelines.md` §1.

| # | Message | Claims rows used | Disclaimer needed |
|---|---|---|---|
| M1 | **Gold the way you buy it.** By gram, ounce or kilogram, 24K to 18K, in your currency. | Metals per oz t, g, kg; 24K, 22K, 21K, 18K; live prices | Prices disclaimer |
| M2 | **Everything else you own, in one number.** Bitcoin and Ethereum, world currencies and your other holdings beside your gold, with cost, gain and allocation. Stocks are mentioned, never headlined (question 14). | Crypto, currencies; buys, sells, cost and gain; allocation by class and karat; charts | Prices disclaimer |
| M3 | **Zakat, worked out from what you hold.** Nisab on 85 g gold or 595 g silver, hawl on the Hijri or Gregorian calendar, a reminder. You choose the basis. | Zakat row | Zakat disclaimer, plus prices disclaimer when a value is shown |
| M4 | **No account. Your data stays on your devices.** No ads, no analytics, no tracking; app lock, hidden balances, AES-256 backups. Free, with no subscription. | No account; no ads, analytics or tracking; on-device with optional iCloud; app lock; AES-256; free | None |

Founder angle across all four: "I built Qima because…", with the decisions behind it: gold-first, no accounts, right-to-left Arabic done properly, and what was cut. Every post says the owner built it.

**Channel roles.**

| Channel | Role | Format | Cadence (default) |
|---|---|---|---|
| LinkedIn | Builder reputation; reaches Gulf professionals | One longer post a week on a product decision, with one screenshot or a carousel | 1 per week, Tuesday or Wednesday morning, Riyadh time |
| X | Reach and conversation, Arabic and English | Short post with a screenshot or a 10 to 20 second screen recording; one thread every two weeks; replies in gold, zakat, personal finance, Flutter and indie threads | 3 posts a week, plus about 15 minutes of replies on 4 days |
| Store listings | Where every post lands; turns visits into installs | Fixes F7 to F10, then campaign links per channel | One-time fix, then a monthly check |
| Website | Second landing page | Fixes F1 to F6; store buttons with campaign links | One-time fix |

**Owner time (default).**

| Part | Hours a week |
|---|---|
| LinkedIn: write, edit, reply to comments | 1.5 |
| X: 3 posts from the drafts, plus replies | 2.0 |
| Assets: crop screenshots, record 1 or 2 short clips | 0.75 |
| Weekly measurement read | 0.25 |
| **Total** | **about 4.5** |

The store and site fixes in week 0 are a one-time job of about 3 to 4 hours. Most of the copy already exists in §10.

**How results are measured.** Nothing is added to the app or the site.

| Question | Where to read it |
|---|---|
| Did posts send people to the store? | App Store Connect, App Analytics: product page views and downloads by source, broken down by campaign link (`ct=x`, `ct=linkedin`, `ct=site`). Play Console: store listing acquisitions by UTM campaign |
| Did the listing convert? | App Store Connect conversion rate; Play Console store listing conversion |
| Which posts worked? | X post analytics (impressions, link clicks, profile visits); LinkedIn post analytics (impressions, clicks, reposts) |
| Is the Arabic audience responding? | The same numbers split by Arabic and English posts, and App Store Connect downloads by territory (Saudi Arabia, the UAE, Egypt, Kuwait, Qatar) |

What would change the plan: details in Phase 2 `measurement.md`. For example: if Arabic posts send clearly more store visits than English ones for three weeks, shift to two Arabic posts for every one in English. If LinkedIn earns attention but no store visits, keep it for reputation and stop putting install links there.

**Other low-cost channels (optional).**

| Channel | Fit | Why |
|---|---|---|
| Store listing optimisation (English and Arabic) | Strong; do first | Every other channel lands here. Copy is ready in §10 |
| Ramadan and zakat-season timing | Strong | The primary audience's strongest seasonal reason. Weeks 9 to 12 are built around it |
| Arabic content | Strong | The primary audience, and the owner already writes in Arabic. Dialect: question 3 |
| Reddit and forums (precious-metals, Islamic finance, FlutterDev), with ownership disclosed | Medium | Right people, but self-promotion rules are strict. Best as answers to real questions, not launches |
| Flutter community (showcase, dev posts about RTL and theming) | Medium | Builds the owner's reputation; few of these readers hold gold |
| Product Hunt | Medium to low | Reaches the global secondary audience for one day. Costs a launch day of the owner's time. Upvote culture fits a calm brand badly. Worth it only after the store fixes and with Android live |
| Hacker News "Show HN" | Low to medium | The privacy-by-design angle fits; results vary a lot and the gold angle doesn't |
| Apple Search Ads (paid) | Optional, if budget | Uses Apple's own reporting, with nothing added to the app. Hold until the listing is fixed and a baseline exists |
| Influencers, giveaways, paid promotions | Doesn't fit | Claims risk, cost, and it reads as hype |
