# Week 1 on LinkedIn: why I built a portfolio tracker that starts with gold

Status: draft for the owner to edit. Not posted. Runs only after the week-0 gate.

Account: `linkedin.com/in/elkhayyat`. Link placeholder: `{APP_STORE_LINK_LINKEDIN}` (App Store campaign link with `ct=linkedin`). Test it in the post this week and in the first comment next week, and compare clicks.

**Slot:** Tuesday or Wednesday, 8 to 10 am Riyadh time.
**Asset:** `ios/fastlane/screenshots/en-US/iphone_2_gold_detail.png`.
**Alt text:** Qima's gold detail screen, with price and chart. Sample data.

---

> I built a portfolio tracker that starts with gold. Here is why.
>
> Many families I know in the Gulf and Egypt keep part of what they own in gold: bars, coins and jewellery. When they ask what it is worth, they don't mean dollars per troy ounce. They mean grams, at the karat they bought, in riyals, dirhams or pounds.
>
> Most portfolio apps I tried start with stocks and treat metals as an extra. So I built Qima the other way round.
>
> Gold, silver, platinum and palladium come first, priced per gram, ounce or kilogram, with gold at 24K, 22K, 21K and 18K, in the currency you choose. Bitcoin, Ethereum, world currencies and the rest of what you hold sit beside them in one total, with cost, average cost and gain.
>
> Three decisions shaped the rest:
>
> 1. No account. You open the app and start. There is no sign-up and no login.
> 2. No server holds your portfolio. Your data stays on your devices, with optional iCloud sync on Apple devices.
> 3. No ads, no analytics, no subscription. It is free.
>
> Over the next few weeks I'll write about each decision: building for the unit people think in, doing right-to-left Arabic properly, and working out zakat without pretending to issue rulings.
>
> Qima is on iPhone and iPad: {APP_STORE_LINK_LINKEDIN}
>
> Prices come from third-party sources and may be delayed. Qima is not investment advice.

---

Claim sources (`brand/guidelines.md` §1):

| Line | Claims-table row |
|---|---|
| Per gram, ounce or kilogram; gold, silver, platinum, palladium | Prices for gold, silver, platinum and palladium per troy ounce, gram or kilogram |
| 24K, 22K, 21K and 18K | Gold by 24K, 22K, 21K and 18K |
| Bitcoin, Ethereum, world currencies | Bitcoin and Ethereum; world currencies (stocks left out of the post, answer 14) |
| Cost, average cost and gain | Record buys, sells, transfers and fees; see value, cost, average cost and gain |
| No account, no sign-up, no login | No account, no sign-up, no login |
| Data stays on your devices, optional iCloud sync | Data stays on your device, with optional iCloud sync on Apple devices |
| No ads, no analytics, free, no subscription | No ads, no analytics, no tracking; Free, with no subscription |
| "No server holds your portfolio" | Live site wording (guidelines §10, website), follows from the on-device row |
| Riyals, dirhams, pounds | "in the currency you choose": SAR, AED and EGP are built in (`lib/models/instrument_catalog.dart`) |
| Families in the Gulf and Egypt; most apps start with stocks | The owner's own observation, not a product claim |

Checks: ownership yes · price disclaimer yes · zakat mentioned only as a future topic, with no ruling language · no emoji · no numbers beyond units and karats.
