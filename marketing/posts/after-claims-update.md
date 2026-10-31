# Drafts that wait for the claims table

Status: drafts for the owner to edit. Not posted.

**Every post in this file runs only after the claims-table update and after 3.1.0 is live.** Each one uses a claim that is not yet in `brand/guidelines.md` §1. The owner accepted these claims in principle (Phase 1, question 10), but they haven't been added to the table, and this plan doesn't add them. Until they are, use the fallback named in `calendar.md`.

| Claim waiting for the table | Proposed source |
|---|---|
| Share an asset as an image, sized for WhatsApp, Instagram, Facebook and LinkedIn posts and stories, with a ready caption | 3.1.0 release notes (`ios/fastlane/metadata/en-US/release_notes.txt`); `lib/screens/share_asset_sheet.dart`; screenshot `iphone_3_share` |
| Reorder the watchlist: drag items, or sort by name, top performers or asset class | 3.1.0 release notes |
| 160+ display currencies | `README.md` "Data sources" (`open.er-api.com`); `brand/discovery.md` |
| Opens offline: holdings are stored locally | `site/index.html` "Offline" |

---

## A1. X, Arabic: share as image (calendar week 8)

**Labelled:** after the claims-table update and after 3.1.0 is live.
**Asset:** `ios/fastlane/screenshots/ar-SA/iphone_3_share.png`.
**Alt text:** شاشة مشاركة الدهب كصورة في Qima. بيانات تجريبية.

> في آخر تحديث لـ Qima: تقدر تشارك سعر الدهب أو أي أصل كصورة، مقاسها مظبوط لبوست أو ستوري على واتساب وانستجرام وفيسبوك ولينكدإن، ومعاها كابشن جاهز.
>
> أنا اللي عامل التطبيق.
> {APP_STORE_LINK_X}
>
> الأسعار جاية من مصادر خارجية وممكن تتأخر. Qima مش نصيحة استثمارية.

Claim sources: share as image (waiting); prices disclaimer because the image shows a price.
Checks: ownership yes · disclaimer yes · no emoji.

---

## A2. X, English: share as image

**Labelled:** after the claims-table update and after 3.1.0 is live.
**Asset:** `ios/fastlane/screenshots/en-US/iphone_3_share.png`.

> New in Qima 3.1: share any asset as an image, sized for WhatsApp, Instagram, Facebook and LinkedIn, with a ready caption.
>
> I built it for sending a gold price to the family chat.
> {APP_STORE_LINK_X}
>
> Prices come from third-party sources and may be delayed. Qima is not investment advice.

Claim sources: share as image (waiting). "Family chat" is the owner's reason, not a product claim; the owner should confirm it is true.
Checks: ownership yes · disclaimer yes · no emoji.

---

## A3. X, English: reorder the watchlist (calendar week 8)

**Labelled:** after the claims-table update and after 3.1.0 is live.
**Asset:** 10 second clip: drag a row, then switch sort to "asset class".

> Small thing I shipped in Qima 3.1: reorder your watchlist. Drag items, or sort by name or by asset class.
>
> Gold stays at the top if that's where you want it.
> {APP_STORE_LINK_X}

Claim sources: reorder and sort (waiting). The "top performers" sort is left out on purpose: it reads close to performance talk.
Checks: ownership ("I shipped") yes · no price claim, so no disclaimer · no emoji.

---

## A4. X, English: 160+ currencies (calendar week 11)

**Labelled:** after the claims-table update and after 3.1.0 is live.
**Asset:** crop of the currency picker (new capture).

> I built Qima for Gulf gold holders, but it adds up in 160+ currencies: gold, crypto and cash, in the currency you live in.
> {APP_STORE_LINK_X}
>
> Prices come from third-party sources and may be delayed. Qima is not investment advice.

Claim sources: 160+ display currencies (waiting); Bitcoin and Ethereum; "added up" is the tagline idea.
Checks: ownership yes · disclaimer yes · no emoji.

---

## A5. X, Arabic: opens offline, with privacy

**Labelled:** after the claims-table update and after 3.1.0 is live. Use in week 3 or 11 as an extra post only if time allows.
**Asset:** none, or the lockup on dark.

> سؤال اتسألته كتير: Qima شغال من غير نت؟
>
> ممتلكاتك متخزنة على جهازك، فالمحفظة بتفتح بنت أو من غيره. الأسعار بس هي اللي محتاجة نت عشان تتحدث.
>
> ومن غير حساب، ومن غير ما أي سيرفر يشيل محفظتك. أنا اللي عامل التطبيق.

Claim sources: offline (waiting); no account; data stays on your devices. "No server holds your portfolio" is live site wording (guidelines §10). "Prices need a connection to refresh" follows from `errorRefreshFailed`. "A question I've been asked a lot" must be true before posting; otherwise open with "Qima شغال من غير نت؟" alone.
Checks: ownership yes · no price shown, so no price disclaimer · no emoji.

---

## A6. LinkedIn, English: shipping 3.1.0 (calendar week 8)

**Labelled:** after the claims-table update and after 3.1.0 is live.
**Asset:** `ios/fastlane/screenshots/en-US/iphone_3_share.png`.
**Link:** `{APP_STORE_LINK_LINKEDIN}`, in the post or the first comment, whichever won in weeks 1 and 2.

> Qima 3.1 is out. Three changes, and why I made them.
>
> 1. A calmer look. I reworked the design so it feels at home on iPhone: softer colours on chips and controls, and fewer things competing for attention.
> 2. Reorder the watchlist. Drag items, or sort by name or asset class. People who hold gold usually want it at the top, so now they can keep it there.
> 3. Share an asset as an image. Sized for WhatsApp, Instagram, Facebook and LinkedIn posts and stories, with a ready caption. Gold prices get sent to family chats all the time; I wanted that to look clean.
>
> What didn't change: no account, no ads, no analytics, and your data stays on your devices.
>
> I build Qima on my own. It is free on iPhone and iPad.
>
> Prices come from third-party sources and may be delayed. Qima is not investment advice.

Claim sources: "a cleaner, calmer look that feels at home on iPhone" (3.1.0 release notes; the chip detail is from `brand/discovery.md`, erratum, commit `671f96c`); reorder and share (waiting); no account; no ads, analytics; data stays on your devices; free.
Checks: ownership yes · disclaimer yes · "top performers" sort left out · no emoji.
