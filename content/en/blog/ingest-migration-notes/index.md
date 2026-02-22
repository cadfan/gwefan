---
title: "Making ingest boring: notes from moving islet to direct uploads"
date: 2026-02-22
description: "What looked like a simple endpoint change turned into protocol compatibility, idempotency, and operational signal work."
tags: ["islet", "operations", "reliability"]
---

<p class="blog-lead">Most migration plans look clean in architecture diagrams. One box becomes another box, one arrow moves, and the system is &ldquo;simpler&rdquo; afterwards. In practice, the shape of the arrows matters more than the boxes.</p>

For islet, Phase 3 looked simple on paper: stop depending on Nightscout polling, accept uploads directly, keep local storage as the source of truth, and treat upstream relay as optional safety.

The target was straightforward:

Libre sensor -> phone app -> islet ingest API -> SQLite -> analytics.

No middle layer required for the core path.

## The part that was easy

Building endpoints was not difficult. There were already clear data structures, storage functions, and tests around insertion behavior. Adding `POST /entries` and `POST /treatments` did not require a large rewrite.

The storage model helped:

1. writes are local-first
2. duplicates are ignored
3. every ingest path lands in the same database layer

That gave a stable core quickly.

## The part that was not easy

Compatibility behavior consumed more time than endpoint creation.

A phone uploader does not care that your architecture is cleaner. It cares whether every edge behavior matches what it expects from a Nightscout-style API.

Three categories caused most of the friction.

## 1. Protocol compatibility is not just field names

Some endpoints existed only because clients expect them during setup and verification, even if they look secondary from a server perspective.

Examples:

1. status and test routes used by client verification flows
2. treatment retrieval shape expected by uploader polling logic
3. delete semantics for correcting uploaded treatments

If one of those differs, upload can look healthy in logs while client behavior degrades.

## 2. Idempotency is the difference between reliable and noisy

Uploads retry. Networks drop. Requests arrive twice. Sometimes the second request is delayed enough that it looks new.

That means ingest must be idempotent by default, not as a future optimization.

When `_id` is missing, deterministic ID generation matters. If ID generation changes per retry, dedup fails silently and historical data quality drifts over time.

The practical rule was:

generate the same ID for the same logical record every time, then rely on insert-ignore semantics at the storage layer.

## 3. Operational signals must describe reality, not just process health

A running process is not the same as fresh data flow.

For API-first ingest, heartbeats alone are a weak signal. A daemon can be healthy while uploads have stopped upstream. The monitor should answer both:

1. is the service up?
2. is recent data still arriving?

That distinction turns \"everything looks fine\" into something actually useful at 3am.

<blockquote class="blog-pullquote">Boring systems come from explicit failure contracts, not optimistic health checks.</blockquote>

## Local-first first, relay second

During migration, forwarding to an upstream Nightscout instance remained useful as a safety path. But it was intentionally non-blocking.

The ordering matters:

1. validate and store locally
2. return success for accepted local write
3. attempt relay as a best-effort side effect

When relay fails, local continuity remains intact. That prevents external dependency outages from becoming data-loss events in the primary system.

This is a recurring pattern for self-hosted reliability: treat integrations as optional after the local transaction boundary is crossed.

## Why this phase matters

Replacing a dependency is less about deleting code and more about owning behavior previously hidden behind that dependency.

Nightscout was not only storage and API. It also encoded many small compatibility assumptions that clients relied on.

Phase 3 work made those assumptions explicit inside islet:

1. ingest behavior
2. normalization paths
3. dedup guarantees
4. compatibility endpoints
5. operational observability

That is the real migration result: fewer unknowns, tighter control, and clearer failure boundaries.

## What I would do earlier next time

1. treat client compatibility as a first-class test suite from day one
2. define idempotency strategy before the first endpoint is exposed
3. separate process liveness from data freshness in monitoring design
4. capture expected client polling and verification behavior in specs, not only in code comments

The code is important, but the migration quality mostly came from these non-obvious contracts.

The goal was never to create a clever ingest pipeline. It was to make ingestion uneventful, predictable, and easy to reason about under pressure.

That is still the best definition of \"done\" I have for this phase.

<p class="post-note"><strong>Safety note:</strong> islet is a personal project and is not medical advice. It does not make dosing decisions.</p>

