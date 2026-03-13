---
title: "Replacing Nightscout"
date: 2026-02-23T18:00:00+00:00
description: "How islet went from polling someone else's server to running its own ingest API — with per-device routing, token auth, and zero downtime."
tags: ["islet", "infrastructure", "diabetes"]
---

<p class="blog-lead">For the first two weeks, islet was a parasite. It polled Nightscout every sixty seconds, pulled down whatever was new, and stored it in SQLite. Nightscout did the hard work of receiving data from CGM apps. islet just copied it. That dependency was always temporary.</p>

## Why Nightscout had to go

Nightscout is a good project. It solved CGM data sharing when nobody else would. But as a dependency inside islet, it created three problems:

- **Single point of failure.** If the Node.js container on the Pi crashed, or the MongoDB instance behind it stalled, islet stopped receiving data. Two services failing instead of one.
- **Data latency.** Polling every 60 seconds means readings arrive 30 seconds late on average. For trend analysis and forward prediction, that delay matters.
- **Ownership.** islet stores everything in SQLite. Nightscout stores everything in MongoDB. Two copies of the same data in two formats, with Nightscout as the source of truth for ingest. If islet is going to be the platform, it needs to own the data pipeline end to end.

The fix was obvious in principle: make islet accept data directly from the CGM apps, the same way Nightscout does.

## The Nightscout-compatible API

xDrip4iOS (and its fork Zukka) can POST glucose entries, treatments, and device status to any server that speaks the Nightscout API format. The format is documented, stable, and simple — JSON arrays with a handful of required fields.

islet gained three endpoints:

- `POST /api/v1/entries` — glucose readings from the CGM
- `POST /api/v1/treatments` — insulin doses, carb entries, notes
- `POST /api/v1/devicestatus` — phone battery, uploader status

The key decision was to use Nightscout's own API shape rather than inventing a new one. This meant existing CGM apps could switch from Nightscout to islet by changing one URL. No app changes required.

## Per-device routing

At the time of the transition, I was running two phones — one as the CGM source paired to the Libre 3 sensor, one for treatments and meal logging. Both phones POSTed directly to islet, but they needed different handling. CGM data still needed relaying to Nightscout for its web dashboard. Treatment data only islet cared about.

islet solves this with a token map. Each device gets its own API token. The server resolves which device sent a request, labels the data accordingly, and applies routing rules — some data gets relayed downstream, some is stored locally only.

<blockquote class="blog-pullquote">Same API, same data format, different routing rules per device. The complexity is in the config, not the code.</blockquote>

## The mode switch

islet's daemon has three ingest modes, controlled by an environment variable:

- `nightscout` — the original: poll Nightscout, store locally
- `api` — the new default: accept direct POSTs, no polling
- `dual` — run both (used during the transition)

The transition took one afternoon. Set dual mode, restart the daemon, reconfigure Zukka to point at islet instead of Nightscout, verify data flows. Once confirmed, switch to API mode and stop the polling loop.

The topology has simplified since then. I now run a single phone — an iPhone 12 Pro with Zukka — posting everything directly to islet. Nightscout became a downstream consumer, not the source of truth. The two-phone setup was a transitional step that the per-device routing was designed to handle, but it turned out to be temporary.

## What this unlocked

With islet owning ingest, several things became possible:

- **Real-time processing.** Data arrives via POST, not via a polling loop. Trend analysis and prediction run against fresh data immediately.
- **Per-device metadata.** Every reading carries a device label. The dashboard can show which phone uploaded what. Debugging data gaps means checking one source, not the whole pipeline.
- **Nightscout as optional.** Nightscout still runs for its web UI and for Share API compatibility. But if it goes down, islet keeps receiving and processing data. The dependency inverted.
- **Token-scoped access.** The Android follower app uses its own read-only token. Family members use separate ones. Each consumer gets exactly the access it needs.

## Current state

islet's API handles all ingest. The daemon has not polled Nightscout in weeks. The Nightscout polling code still exists — it is tested, maintained, and available as a fallback — but it is no longer the default path.

The entire ingest layer is around 800 Python SLOC with 140 tests covering token auth, device resolution, relay routing, and all three ingest modes. It was the most satisfying piece of engineering in the project so far, because it removed a dependency by building a better version of the thing it depended on.

<div class="post-note">islet does not give insulin dosing advice. All data processing is informational. The safety contract is documented in the project's architecture and enforced in code.</div>
