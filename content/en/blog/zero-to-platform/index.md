---
title: "Zero to platform in three weeks"
date: 2026-03-13T11:00:00+00:00
description: "islet went from an empty git repo to a multi-platform glucose intelligence system in twenty days. Here is how that happened and what it cost."
tags: ["islet", "retrospective"]
---

<p class="blog-lead">On February 15th, islet was a name and some planning documents. By March 7th, it was a daemon running on a Raspberry Pi, a Flask API accepting data from two phones, a glucose prediction engine, an iOS companion app with eleven screens, an Android follower app, a food template system, and a test suite with over 600 tests. This is not a story about moving fast. It is a story about what happens when you have already done the thinking.</p>

<div class="blog-stat-row">
  <div class="blog-stat">
    <div class="blog-stat-num">20</div>
    <div class="blog-stat-label">Days</div>
  </div>
  <div class="blog-stat">
    <div class="blog-stat-num">10,905</div>
    <div class="blog-stat-label">Python SLOC</div>
  </div>
  <div class="blog-stat">
    <div class="blog-stat-num">3,463</div>
    <div class="blog-stat-label">Swift SLOC</div>
  </div>
  <div class="blog-stat">
    <div class="blog-stat-num">668+</div>
    <div class="blog-stat-label">Tests</div>
  </div>
</div>

## The planning tail

islet did not start on February 15th. It started months earlier as a question: what would a T1D data platform look like if it were built from scratch today, knowing everything Nightscout got right and wrong?

The planning phase produced architecture documents, schema designs, a phased roadmap, and a clear separation between what the system should do (store, analyse, present) and what it should never do (advise on dosing). By the time the first `git init` happened, the shape of the system was already decided. The twenty days were execution, not discovery.

## Phase 1: The daemon (Feb 15–17)

The first piece was the simplest: a polling daemon that mirrors Nightscout data into SQLite. Config loader, Nightscout client, storage layer, CLI (`isletctl`), systemd units, Pi deployment scripts. The entire Nightscout-to-SQLite pipeline, with staleness detection, health checks, and a soak test on the Pi.

This was deliberately boring. No API, no UI, no prediction. Just reliable data ingestion with tests for every edge case: pagination gaps after downtime, treatment records with zero values, timestamp drift between server and client.

## Phase 1.5: Meal logging (Feb 17–19)

The `meals` table, CRUD operations, status transitions (logged → estimated → confirmed), a schema migration runner, and AI-assisted carb estimation via an external provider. By the end, 168 tests. The meal system was designed to grow — the estimation provider interface is pluggable — but the first version was intentionally constrained.

## Phase 3: Own the pipeline (Feb 20–23)

This was the pivot. islet gained its own Nightscout-compatible API, per-device token auth, conditional relay routing, and a mode switch to stop polling. Nightscout went from dependency to optional downstream consumer. [I wrote about this separately.](/blog/replacing-nightscout/)

## Phase 4: Native clients (Feb 25 – Mar 7)

The iOS companion app ("Warm Amber") grew from a single-screen dashboard to a full application: glucose chart with finger scrubber, treatment input, food logger with AI estimation, history view with time range picker, settings, and prediction overlays. Eleven screens, custom SwiftUI components, the same warm amber palette that runs through everything.

The Android follower app landed in parallel — a focused, read-only dashboard for family members. Different user, [different app](/blog/android-follower/).

glucore, the analytics engine, gained forward prediction, parameter tuning, and calibration. [That story is here.](/blog/glucore-forward-prediction/)

## What made this possible

Three things:

**The planning was done.** Every phase had a clear scope, defined inputs and outputs, and a test matrix. There were no "let me think about how this should work" pauses during implementation. The thinking happened in November, December, January. February was typing.

**The architecture was right from the start.** SQLite, not Postgres — because the system runs on a Raspberry Pi and needs zero maintenance. Flask, not Django — because the API is thin and the logic lives in the domain layer. systemd, not Docker — because the Pi already runs Linux and adding container orchestration for two Python services is not simplification.

**The scope was honest.** Every feature had a clear boundary. The meal system logged meals — it did not try to be a nutrition app. The prediction engine produced trajectories — it did not try to suggest dosing. The iOS app showed data — it did not try to replace a clinical tool. Saying "no" to adjacent features is what made twenty days enough.

<blockquote class="blog-pullquote">The hard part was never the code. The hard part was deciding what the system should be. Once that was settled, building it was a matter of discipline.</blockquote>

## What it cost

No cloud services. No paid APIs beyond Claude Code itself. No external databases. The hardware was already in the house — a Raspberry Pi 5B, two iPhones, a broken-screen MacBook Pro repurposed as a headless build machine.

The islet backend runs on the same Pi that serves this website, receives email, and hosts Nightscout. It adds negligible load. The iOS app runs on a phone I already carry. The Android follower runs on a phone my partner already carries.

The recurring cost is a Libre 3 sensor every two weeks, which I would be buying regardless. islet made the data from that sensor more useful. It did not add a new expense.

## What is next

The system works. It runs in production, processes real glucose data, and surfaces predictions that I actually check before meals. But twenty days of building leaves a long tail of refinement. The parameter tuning grid is coarse. The food template library is small. The iOS app needs polish sessions. The prediction uncertainty bands are wider than they should be.

None of that is urgent. The foundation is solid, the tests are comprehensive, and the data pipeline is reliable. The next phase is depth, not breadth — making each piece better rather than adding new ones.

<div class="post-note">islet does not give insulin dosing advice. Predictions are informational only. The safety contract is enforced in code and documented in the project's architecture documents.</div>
