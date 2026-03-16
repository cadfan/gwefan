---
title: "Six Plans, One Session"
date: 2026-03-16T00:01:00+00:00
description: "How a 36-hour development session shipped 6 infrastructure plans, 954 new tests, and a complete alerting engine for islet — with AI agents doing the heavy lifting."
tags: ["islet", "development", "ai-tooling"]
---

<p class="blog-lead">On Friday morning, islet had 766 tests and no concept of food components, rate limiting, or offline caching. By Sunday evening it had 1,750 tests, schema v8, a tiered rate limiter, an AI vision upgrade, a component-based meal architecture, a sync infrastructure, an iOS SwiftData cache, an alert detection engine, and a time-in-range dashboard showing 51.8% TIR across 14,000 CGM entries. One session.</p>

<p class="post-note"><strong>Safety note:</strong> islet is a personal project and is not medical advice. It does not make dosing decisions.</p>

## The setup

I started with a brainstorm. What does islet actually need next? A council of three AI judges &mdash; two Claude, one Codex &mdash; reviewed the codebase and identified five feature gaps and one missing prerequisite. Six plans total:

1. **Meal-to-treatment relay** &mdash; confirm a meal in islet, create a Nightscout treatment for Zukka
2. **Tiered rate limiter** &mdash; per-IP for unauthenticated, per-device for authenticated
3. **AI vision upgrade** &mdash; photo-based meal estimation alongside text
4. **Component meal architecture** &mdash; reusable food components with synonym matching
5. **iOS offline cache** &mdash; SwiftData persistence so the app works without network
6. **Server sync infrastructure** &mdash; the plan nobody knew was needed until the pre-mortem found it

That last one is the interesting one. The pre-mortem &mdash; three judges reviewing plans before a single line of code was written &mdash; found 10 blockers across all five plans. Plan 5 (iOS offline cache) required `updated_at_ms` columns, soft-delete support, and incremental sync endpoints that didn't exist anywhere. Without the pre-mortem, implementation would have hit a wall halfway through.

<blockquote class="blog-pullquote">The pre-mortem found 10 blockers across 5 plans. Every one was real.</blockquote>

## 26 minutes

Ouroboros &mdash; a self-improving AI workflow system &mdash; took the seed specification and implemented all six plans in 26 minutes. Six parallel agents, 387 messages processed, schema v7 and v8 migrations applied, 739 new tests written. The code needed a threading fix on the iOS SyncService and some SourceKit false positives, but the core was solid.

Then the hardening loop. Five evolutionary generations: smoke tests with endpoint criticality tiers, attack surface probing, verification timestamps, run streaks. Each generation evaluated itself, asked what it didn't know, and evolved.

## The Zukka surprise

No plan accounted for Nightscout field conventions. When I tested with my actual phone, Zukka didn't see the meal entries. Three bugs, each invisible to planning:

- `eventType` was `"Meal Bolus"` &mdash; Zukka needs `"Carbs"`
- Timestamps used `+00:00` &mdash; xDrip4iOS needs the `Z` suffix
- `GET /treatments.json` didn't exist &mdash; Nightscout convention

A 21-test Nightscout compatibility suite now prevents all three from recurring. Sometimes the most valuable tests come from bugs no judge predicted.

<blockquote class="blog-pullquote">No amount of planning replaces testing with real hardware.</blockquote>

## The numbers

| Metric | Before | After |
|--------|--------|-------|
| Python tests | 766 | 1,750 |
| Schema version | 6 | 8 |
| API endpoints | ~25 | 37 |
| Files changed | &mdash; | 162 |
| Lines added | &mdash; | ~24,000 |

The alert engine detects six conditions: urgent low, low (sustained 10 min), high (sustained 30 min), urgent high, stale CGM, and rapid drop. All thresholds configurable via environment variables. The TIR dashboard computes time-in-range directly from SQL against 14,000+ CGM entries &mdash; no heavy analytics pipeline needed.

Both are live on the Pi right now. My mam can see my glucose on her Samsung. Next step: push notifications so she doesn't have to check manually.
