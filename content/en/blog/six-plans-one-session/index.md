---
title: "Six Plans, One Session"
date: 2026-03-16T00:01:00+00:00
description: "A 36-hour development session that shipped 6 infrastructure plans, 954 new tests, and a complete alerting engine for islet."
tags: ["islet", "development"]
---

<p class="blog-lead">On Friday morning, islet had 766 tests and no concept of food components, rate limiting, or offline caching. By Sunday evening it had 1,750 tests, schema v8, a tiered rate limiter, photo-based meal estimation, a component meal architecture, a sync infrastructure, an iOS SwiftData cache, an alert detection engine, and a time-in-range dashboard showing 51.8% TIR across 14,000 CGM entries. One session.</p>

<p class="post-note"><strong>Safety note:</strong> islet is a personal project and is not medical advice. It does not make dosing decisions.</p>

## The scope

I started by listing what islet actually needed next. Six infrastructure gaps, each blocking something else:

1. **Meal-to-treatment relay** &mdash; confirm a meal in islet, create a Nightscout treatment so Zukka sees it
2. **Tiered rate limiter** &mdash; per-IP limits for unauthenticated requests, per-device limits for authenticated ones
3. **Photo-based meal estimation** &mdash; image input alongside text for the carb estimation API
4. **Component meal architecture** &mdash; reusable food components with synonym matching and fuzzy lookup
5. **iOS offline cache** &mdash; SwiftData persistence so the app works without network
6. **Server sync infrastructure** &mdash; `updated_at_ms`, soft-delete, incremental query endpoints

That last one wasn't in the original list. A design review before implementation found that Plan 5 required timestamp columns, soft-delete support, and incremental sync endpoints that didn't exist. Without catching that dependency, the iOS cache work would have hit a wall halfway through.

<blockquote class="blog-pullquote">The design review found 10 blockers across 5 plans. Every one was real.</blockquote>

## Implementation

All six plans shipped in parallel. Schema v7 (sync columns, `PRAGMA foreign_keys = ON`, soft-delete functions) landed first, then v8 (food components, synonyms, meal-component join table) on top. The rate limiter replaced the single global bucket with a merged middleware that resolves auth first &mdash; failed auth checks per-IP (10/min) and a global unauthenticated budget (500/min), passed auth checks per-device-label (120/min).

The iOS work was the most involved. SwiftData models for cached CGM entries, meals, and treatments. A `SyncService` that polls `/api/v1/sync` with cursor-based incremental updates and tombstone handling. A `CacheFirstDataProvider` that serves cached data instantly, then refreshes from the API in the background. Camera capture with `PhotosPicker` + `UIImagePickerController`. Component type-ahead chips above the food description field.

Then five rounds of hardening: smoke tests with endpoint criticality tiers, attack surface probing for paths that should return 404, verification timestamps, and run-streak tracking.

## The Nightscout surprise

No plan accounted for Nightscout field conventions. When I tested with my actual phone, Zukka didn't see the meal entries. Three bugs:

- `eventType` was `"Meal Bolus"` &mdash; Zukka needs `"Carbs"`
- Timestamps used `+00:00` &mdash; xDrip4iOS needs the `Z` suffix
- `GET /treatments.json` didn't exist &mdash; Nightscout clients expect the `.json` route

A 21-test Nightscout compatibility suite now prevents all three from recurring. These are the bugs that only surface when you test with a real device &mdash; no amount of spec review catches field-level format assumptions buried in a third-party client.

<blockquote class="blog-pullquote">No amount of planning replaces testing with real hardware.</blockquote>

## The numbers

| Metric | Before | After |
|--------|--------|-------|
| Python tests | 766 | 1,750 |
| Schema version | 6 | 8 |
| API endpoints | ~25 | 37 |
| Files changed | &mdash; | 162 |
| Lines added | &mdash; | ~24,000 |

The alert engine detects six conditions: urgent low (<3.0 mmol/L), low (sustained 10 min), high (sustained 30 min), urgent high (>16.7), stale CGM (>15 min no reading), and rapid drop (>0.17 mmol/L/min). All thresholds are configurable via environment variables. "Sustained" means every reading in the window breaches the threshold, with at least two readings present and no gap exceeding six minutes &mdash; precise enough to avoid false alarms from sensor noise.

The TIR dashboard computes time-in-range directly from SQL against the CGM entries table &mdash; no analytics pipeline needed. A `GROUP BY` on date gives daily TIR values for the trend chart. The whole query runs in milliseconds on 14,000 rows.

Both are live on the Pi. My mam can see my glucose on her Samsung. Next: push notifications so she doesn't have to open the app to know I'm going low.
