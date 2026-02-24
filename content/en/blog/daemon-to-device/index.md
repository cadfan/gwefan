---
title: "From daemon to device: islet at 86 commits"
date: 2026-02-23
description: "Three weeks from polling script to standalone platform — what the project looks like now and what having a client changes."
tags: ["islet", "milestones", "architecture"]
---

<p class="blog-lead">On February 5th, islet was a Python script that polled Nightscout every 60 seconds and stored the results in SQLite. Nineteen days and 86 commits later, it is a standalone platform: its own ingest API, analytics engine, relay system, and a native iOS app on my phone. The Nightscout dependency is off.</p>

That trajectory was not planned as a single arc. Each phase solved the next most important problem, and the specification-first approach meant each phase could be built quickly without rewriting what came before.

## The phases

<div class="spec-grid spec-grid-2col">
  <div class="spec-card">
    <div class="spec-card-title">Phase 1 &mdash; Ingest</div>
    <div class="spec-card-desc">Nightscout polling, SQLite storage, backfill, CLI, systemd daemon. One session from spec to running service.</div>
  </div>
  <div class="spec-card">
    <div class="spec-card-title">Phase 2 &mdash; Analytics</div>
    <div class="spec-card-desc">Glucore engine: insulin on board, carbs on board, blood glucose impact, deviation analysis, 30-minute predictions.</div>
  </div>
  <div class="spec-card">
    <div class="spec-card-title">Phase 3 &mdash; Independence</div>
    <div class="spec-card-desc">Direct ingest API, per-device tokens, conditional relay, three ingest modes. Nightscout becomes optional infrastructure.</div>
  </div>
  <div class="spec-card">
    <div class="spec-card-title">iOS companion</div>
    <div class="spec-card-desc">Native SwiftUI app. Glucose dashboard, AI-assisted food logging, meal lifecycle, Warm Amber theme.</div>
  </div>
</div>

Phase 3.3 &mdash; the actual cutover to API-only ingest &mdash; went live on the 23rd. Three commands, no data gap, both phones continued uploading. The [previous post]({{< ref "/blog/cutting-the-cord" >}}) described the design that made this boring. On the day, it was boring.

## Where it stands now

<div class="blog-stat-row">
  <div class="blog-stat"><div class="blog-stat-num">5,823</div><div class="blog-stat-label">Python SLOC</div></div>
  <div class="blog-stat"><div class="blog-stat-num">~1,600</div><div class="blog-stat-label">Swift SLOC</div></div>
  <div class="blog-stat"><div class="blog-stat-num">641</div><div class="blog-stat-label">tests passing</div></div>
  <div class="blog-stat"><div class="blog-stat-num">86</div><div class="blog-stat-label">commits</div></div>
</div>

The server runs 24/7 on a Raspberry Pi 5B. The API handles ingest from two phones, serves analytics to the iOS app, provides AI meal estimation, and relays selectively to Nightscout. The test suite covers the ingest pipeline, analytics engine, API routes, and meal estimation endpoint.

## What having a client changes

Before the iOS app, islet was invisible. It ran on a Pi in the next room, processing data that could only be seen through curl or the CLI. The system worked, but interacting with it required thinking like a developer.

The app makes islet tangible. You can glance at your glucose, check your active insulin, log what you're eating, review recent meals. The information that was always being computed is now accessible without context-switching into a terminal.

<blockquote class="blog-pullquote">Infrastructure that nobody can see is infrastructure that nobody trusts.</blockquote>

That changes the relationship with the project. It moves from something you maintain to something you use. The feedback loop tightens: problems that would take hours to notice via logs become obvious in seconds when you're looking at stale data or a wrong prediction on your phone screen.

## What didn't go as expected

The server-side meal estimation endpoint was harder than the iOS UI. SwiftUI made the client straightforward &mdash; views are declarative, the network layer is a single actor, the state management is built in. But making the API response shapes match what Swift's Codable decoders expected took several iterations of fix, build, test, repeat.

The other surprise was data staleness. A glucose reading from 45 minutes ago, displayed without any visual indicator that it's old, is worse than showing nothing. The server already guards against stale data in its analytics &mdash; the safety contract warns at 15 minutes and refuses predictions at 60 &mdash; but the lesson applies to display too. Data age needs to be as visible as the reading itself.

## What comes next

The remaining Nightscout dependency is the relay for the second phone. Once that phone can consume islet data directly &mdash; either through its own app integration or through the iOS companion &mdash; the relay can be turned off and Nightscout decommissioned.

Beyond that: glucose charting in the app, longer-range trend analysis, and the slow process of replacing everything that currently points at Nightscout with something that points at islet instead.

The destination was always a self-contained system. Eighty-six commits in, the outline is visible.

<p class="post-note"><strong>Safety note:</strong> islet is a personal project and is not medical advice. It does not make dosing decisions.</p>
