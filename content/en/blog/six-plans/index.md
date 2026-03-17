---
title: "Six plans for the next phase of islet"
date: 2026-03-15T02:00:00+00:00
description: "islet works. Now it needs to work better. Six plans covering sync infrastructure, offline caching, food photography, component-based meals, rate limiting, and Nightscout relay."
tags: ["islet", "architecture", "ios"]
---

<p class="blog-lead">The foundation is solid. The daemon runs, the API accepts data, the iOS app logs meals and shows predictions. But "it works" is not the same as "it works well." The next phase is six focused improvements that take islet from a system that functions to one that feels right.</p>

## The shape of the work

Six plans, ordered by dependency. Some are small fixes to obvious gaps. Some are structural changes that touch the database schema, the API, and the iOS app in a single pass. All of them come from the same source: using the system every day and noticing where it falls short.

<div class="wave-timeline">
  <div class="wave-group">
    <div class="wave-label">Wave 1 <span class="wave-note">independent</span></div>
    <div class="wave-plans">
      <div class="wave-plan wave-plan-low">
        <div class="wave-plan-num">1</div>
        <div class="wave-plan-body">
          <div class="wave-plan-title">Meal-to-treatment relay</div>
          <div class="wave-plan-desc">When a meal is confirmed, create a Nightscout-compatible treatment and relay it downstream. Closes the loop between islet and existing CGM displays.</div>
        </div>
        <div class="wave-plan-risk">low</div>
      </div>
      <div class="wave-plan wave-plan-med">
        <div class="wave-plan-num">2</div>
        <div class="wave-plan-body">
          <div class="wave-plan-title">Per-device rate limiter</div>
          <div class="wave-plan-desc">Replace the single global request bucket with per-device rate limiting keyed on device identity. Defence-in-depth behind Cloudflare.</div>
        </div>
        <div class="wave-plan-risk">medium</div>
      </div>
    </div>
  </div>

  <div class="wave-connector"></div>

  <div class="wave-group">
    <div class="wave-label">Wave 2 <span class="wave-note">sync foundation</span></div>
    <div class="wave-plans">
      <div class="wave-plan wave-plan-high">
        <div class="wave-plan-num">6</div>
        <div class="wave-plan-body">
          <div class="wave-plan-title">Server sync infrastructure</div>
          <div class="wave-plan-desc">Add <code>updated_at</code> and <code>deleted_at</code> timestamps to meals and treatments. Soft-delete support. A unified sync endpoint that returns all changes since a cursor. The foundation everything else builds on.</div>
        </div>
        <div class="wave-plan-risk">medium-high</div>
      </div>
    </div>
  </div>

  <div class="wave-connector"></div>

  <div class="wave-group">
    <div class="wave-label">Wave 3 <span class="wave-note">backend features</span></div>
    <div class="wave-plans">
      <div class="wave-plan wave-plan-high">
        <div class="wave-plan-num">3</div>
        <div class="wave-plan-body">
          <div class="wave-plan-title">AI vision upgrade</div>
          <div class="wave-plan-desc">Take a photo of your plate. The estimation prompt adapts based on what it receives &mdash; image only, image with description, or text as before.</div>
        </div>
        <div class="wave-plan-risk">medium-high</div>
      </div>
      <div class="wave-plan wave-plan-highest">
        <div class="wave-plan-num">4</div>
        <div class="wave-plan-body">
          <div class="wave-plan-title">Component architecture</div>
          <div class="wave-plan-desc">A food component library that grows as you eat. Log "sourdough toast" once with accurate carbs, and the system remembers it next time. Exact match first, fuzzy fallback for variations.</div>
        </div>
        <div class="wave-plan-risk">high</div>
      </div>
    </div>
  </div>

  <div class="wave-connector"></div>

  <div class="wave-group">
    <div class="wave-label">Waves 4–5 <span class="wave-note">iOS integration</span></div>
    <div class="wave-plans">
      <div class="wave-plan wave-plan-high">
        <div class="wave-plan-num">5</div>
        <div class="wave-plan-body">
          <div class="wave-plan-title">iOS offline cache</div>
          <div class="wave-plan-desc">SwiftData cache for glucose readings, meals, and treatments. The app shows cached data immediately and syncs in the background. No spinner unless the cache is completely empty.</div>
        </div>
        <div class="wave-plan-risk">medium-high</div>
      </div>
    </div>
  </div>
</div>

## Why this order

The dependency chain dictates the sequence. Plans 1 and 2 are independent &mdash; they touch different parts of the codebase and neither relies on the other. They go first because they are low-risk and immediately useful.

Plan 6 must land before Plans 3 and 4 because it establishes the `updated_at` timestamp pattern that the component tables inherit. Building the food component schema on top of sync-aware tables is simpler than retrofitting sync awareness after the fact.

Plans 3 and 4 are independent of each other but both need Plan 6's patterns to be in place. The iOS work in Plan 5 comes last because it consumes all the backend APIs that the earlier plans create.

<blockquote class="blog-pullquote">The order is not a preference. It is a dependency graph.</blockquote>

## The ones that matter most

**Component architecture** is the most ambitious and the most valuable. Right now, every carb estimate starts from scratch &mdash; even for foods I eat three times a week. The component library turns repeated meals into instant lookups. The [bakery data post](/blog/bakery-carb-data/) was an early version of this idea: manufacturer data entered once and reused forever. The component system generalises it to everything.

**Offline caching** solves the most visible annoyance. The iOS app currently makes a network call every time it opens. In the kitchen with a weak signal, that means a loading state where a glucose reading should be. With a local SwiftData cache, the app opens instantly with the last-known data and refreshes in the background.

**Photo-based estimation** is the one I have wanted longest. Describing "two slices of sourdough with butter, a fried egg, and half an avocado" takes twenty seconds. Photographing it takes two. The estimation adapts its prompt based on what it receives &mdash; a photo alone, a photo with a text description, or text as before.

## The seven-day reinstall

While planning all of this, the iOS app stopped launching. Not a crash, not a build failure &mdash; the provisioning profile had expired.

Without a paid Apple Developer account, apps are signed with a free certificate that expires every seven days. When it expires, the app will not open. You reconnect the phone to the build machine, rebuild, reinstall. The app data survives but the interruption does not.

This is the trade-off of building for one. A $99/year developer account would fix it permanently. But the app has exactly one user, will never appear on the App Store, and the reinstall takes under two minutes from an SSH terminal. Every seven days, I run the build command and the phone picks up the new binary over USB.

It is mildly annoying. It is not annoying enough to pay $99/year to avoid.

<div class="blog-stat-row">
  <div class="blog-stat"><div class="blog-stat-num">6</div><div class="blog-stat-label">Plans</div></div>
  <div class="blog-stat"><div class="blog-stat-num">5</div><div class="blog-stat-label">Waves</div></div>
  <div class="blog-stat"><div class="blog-stat-num">~35</div><div class="blog-stat-label">Issues</div></div>
  <div class="blog-stat"><div class="blog-stat-num">2</div><div class="blog-stat-label">Schema migrations</div></div>
</div>

## What stays the same

islet still does not give dosing advice. The safety contract is unchanged. Predictions are informational. The system stores data, analyses it, and presents it &mdash; the human makes the decisions.

The Raspberry Pi still runs everything. The broken MacBook still builds the iOS app. The architecture stays SQLite, Flask, systemd. No new dependencies, no new infrastructure. Just the same box doing more with what it already has.

<div class="post-note">islet is a personal project. It does not provide medical advice or insulin dosing recommendations. All predictions and estimates are informational only.</div>
