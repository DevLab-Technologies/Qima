# Week 2 on LinkedIn: designing for the unit people think in

Status: draft for the owner to edit. Not posted.

**Slot:** Tuesday or Wednesday, 8 to 10 am Riyadh time.
**Link:** put `{APP_STORE_LINK_LINKEDIN}` in the **first comment** this week (week 1 had it in the post), then compare clicks in LinkedIn analytics and App Store Connect.
**Asset:** `ios/fastlane/screenshots/en-US/iphone_4_gold_holdings.png`.
**Alt text:** Qima's gold screen: price per troy ounce, kilogram and gram by karat, and holdings with value and average cost. Sample data.

---

> A small design decision that shaped Qima: show people the unit they already think in.
>
> Finance apps usually price gold one way, per troy ounce in US dollars. That is how markets quote it. It is not how most people I know buy it. A bracelet bought in Riyadh or Cairo is weighed in grams and priced at its karat, in local money.
>
> So in Qima, the unit and the karat are part of the asset, not a setting buried in a menu:
>
> - Gold, silver, platinum and palladium per gram, ounce or kilogram.
> - Gold at 24K, 22K, 21K or 18K.
> - Any of them in the currency you choose, so the same gold can sit in your watchlist in dollars per ounce and in riyals per gram at 21K.
>
> Each gold screen shows the price per troy ounce, per kilogram and per gram at each karat. Record what you bought and you see its value, average cost and gain. The allocation view splits your gold by karat, and the portfolio adds everything into one number.
>
> What this cost: more screens to test, every number formatted for each currency and language, and right-to-left Arabic layouts to check for every unit label. I'll write about the right-to-left work in a few weeks.
>
> I built Qima on my own. It is free, with no account and no ads.
>
> Prices come from third-party sources and may be delayed. Qima is not investment advice.

First comment:

> Qima on iPhone and iPad: {APP_STORE_LINK_LINKEDIN}

---

Claim sources (`brand/guidelines.md` §1):

| Line | Claims-table row |
|---|---|
| Per gram, ounce or kilogram; four metals | Prices for gold, silver, platinum and palladium per troy ounce, gram or kilogram |
| 24K, 22K, 21K or 18K | Gold by 24K, 22K, 21K and 18K |
| Same gold in dollars per ounce and riyals per gram at 21K | World currencies; shown in the store screenshot `iphone_1_watchlist` |
| Value, average cost and gain; one number | Record buys, sells, transfers and fees; see value, cost, average cost and gain · Portfolio allocation by class, gold by karat |
| Right-to-left Arabic | English, Arabic, Spanish and French, with full right-to-left Arabic |
| Free, no account, no ads | Free, with no subscription · No account · No ads, no analytics, no tracking |
| "I built Qima on my own" | Ownership disclosure. The owner should confirm it is accurate (open question O9) |

Checks: ownership yes · price disclaimer yes · checked against `iphone_4_gold_holdings`, which shows "Price per unit" (troy ounce, kilogram, 24K g and more on scroll) and a holdings card with value, average and gain; "gold by karat" refers to the allocation view (`iphone_6_allocation`) · the screenshot shows a sample gain of +59.33%: add "Sample data" to the image or crop the gain row · no emoji.
