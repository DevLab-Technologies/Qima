# Qima marketing measurement

Status: plan for the owner. Prepared 1 November 2026.

Rule: nothing is added to the app or the site to measure marketing. No analytics, no tracking, no accounts, no email capture (brief rule 6). Everything below comes from dashboards that already exist.

Time: about 15 minutes a week, plus 30 minutes at each review point (weeks 3, 6, 9 and 12).

---

## 1. Set-up (week 0)

| Item | Where | Notes |
|---|---|---|
| App Store campaign links `ct=x` and `ct=linkedin` | App Store Connect, App Analytics, Campaigns (generates the link with the provider token) | Use these links in posts. Never link to the plain App Store URL from a post |
| Site link | Already on qima.money as the store buttons | The Play button carries `utm_source=qima.money`. For the App Store button, a `ct=site` campaign link is a proposal for the site, not a change made here |
| Play UTM links, once Play is confirmed live | `https://play.google.com/store/apps/details?id=com.devlabtechnologies.qima&referrer=utm_source%3Dx%26utm_medium%3Dpost` (and `linkedin`) | Play Console, Store performance, Acquisition |
| A weekly log | A spreadsheet the owner keeps: one row per week with the numbers in section 2 | Kept off the app and off any shared server |

App Store Connect campaign data appears only for users who opted in to share with developers, and only above Apple's privacy thresholds. Small weekly numbers may show as blank. Read trends over several weeks, not single days.

## 2. Weekly read (15 minutes, Monday)

| # | Number | Where to read it | Why |
|---|---|---|---|
| 1 | Product page views by campaign (`x`, `linkedin`) | App Store Connect, App Analytics, Sources, Campaigns | Did posts send people to the store? |
| 2 | First-time downloads by campaign | Same place | Did they install? |
| 3 | Conversion rate (page views to downloads), overall and by campaign | App Store Connect, App Analytics | Is the listing doing its job? |
| 4 | Downloads by territory: SA, AE, EG, KW, QA, BH, OM, JO, US | App Store Connect, App Analytics, Territory | Is the primary audience arriving? |
| 5 | Impressions, link clicks, profile visits per post, split Arabic vs English | X analytics (post activity) | Which language and format work on X? |
| 6 | Impressions, clicks, reposts, comments per post | LinkedIn post analytics | Is LinkedIn bringing reputation, clicks, both or neither? |
| 7 | Link in post vs first comment (weeks 1 and 2 only) | LinkedIn clicks plus App Store `ct=linkedin` page views | Pick one for weeks 3 to 12 |
| 8 | Store-listing acquisitions by UTM, once live | Play Console | Same questions for Android |
| 9 | Hours spent this week | The owner's own note | The plan has to stay within about 4.5 hours |

Not tracked, on purpose: anything inside the app; follower counts as a goal (recorded as context only); likes as a goal.

## 3. Baseline and targets

- Weeks 1 and 2 are the baseline. No targets before then, and no numbers are guessed in this plan.
- At the week-3 review, set targets for weeks 3 to 12 from the baseline: for example, weekly page views from `ct=x`, conversion rate, and the share of downloads from the primary territories.
- Write the targets into the weekly log, not into public posts.

## 4. Review points

| Week | Look at | Decide |
|---|---|---|
| 3 | Baseline from weeks 1 and 2 | Targets; LinkedIn link placement; posting times |
| 6 | Weeks 3 to 5 against targets | Language mix; formats that work |
| 9 | Weeks 6 to 8 | Whether the zakat run-up needs more Arabic posts or more clips |
| 12 | The whole run | What to keep for the next 90 days; whether to open a Qima account; whether Apple Search Ads is worth a test |

## 5. What would change the plan

| If this happens | Then |
|---|---|
| Arabic posts send clearly more store page views than English posts for 3 weeks in a row | Move X to 3 Arabic posts for every English one |
| English posts send more page views, mostly from non-Gulf territories | Keep the 2:1 mix, and add one English thread a month for the secondary audience |
| LinkedIn gets impressions and comments but almost no `ct=linkedin` page views for 4 weeks | Keep LinkedIn for reputation; stop putting install links there; cut it to every other week if time is short |
| Page views rise but conversion stays flat or falls | Stop adding posts. Review the listing first: screenshots, subtitle, Arabic copy |
| Clips (screen recordings) beat still images on link clicks for 3 weeks | Swap one still-image post a week for a clip, within the same hours |
| Downloads from SA, AE and EG are a small share of the total | Check the Arabic listing and Arabic post times before changing the audience |
| The owner spends more than 6 hours in a week for 2 weeks running | Drop the third X post and keep LinkedIn every other week. Consistency matters more than volume |
| A post draws questions about returns or what to buy | Answer calmly that Qima is not investment advice; don't engage further; review that post's wording |
| A post draws a zakat ruling question | Reply that Qima calculates and the person decides; suggest they ask a scholar they trust |
| The week-0 gate slips past 16 November | Compress weeks 1 to 8; keep weeks 9 to 12 ending before Ramadan |
