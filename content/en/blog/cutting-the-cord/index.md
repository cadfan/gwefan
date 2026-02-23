---
title: "Cutting the cord: islet runs without Nightscout"
date: 2026-02-23
description: "From cloud dependency to self-hosted single ingress — how per-device tokens and conditional routing made the cutover boring."
tags: ["islet", "architecture", "independence"]
---

<p class="blog-lead">For eight days, islet has been the primary ingestion path. Tonight it became the only one. Nightscout polling is off. Both phones POST directly to a Raspberry Pi in the next room, and the system does not care.</p>

That sounds undramatic because it should be. The entire point of the last three weeks was to make this moment boring.

## The dependency that was hard to see

Nightscout was never just a database. It was the implicit trust boundary for every data flow in the system. Sensor readings went from phone to Nightscout to islet. Treatments went the same path. Every piece of data arrived through someone else's API, on someone else's schedule.

The problem with invisible dependencies is that you only notice them when they break at 3am and the data stops.

## Why two phones made it harder

Both phones run xDrip4iOS forks. They send identical payloads. Same `device: "xDrip4iOS"` field. Same User-Agent header. Same JSON structure. From the server's perspective, they are indistinguishable.

That matters because the two phones serve different roles. One phone's CGM data needs to reach Nightscout (so the other apps that still depend on it can see readings). The other phone's data should stay local — islet is its Nightscout replacement.

The solution was per-device API tokens. Each phone gets a different secret. islet maps token to device label at authentication time, then uses that label for routing decisions. No application changes were required on either phone — xDrip4iOS already supports configurable API secrets.

<blockquote class="blog-pullquote">The best migration strategy requires zero changes from the things being migrated.</blockquote>

## What conditional routing looks like

The routing rule is simple: check the device label, check the skip list, decide whether to relay.

For CGM entries:
- phone identified as "xs": store locally, relay to Nightscout
- phone identified as "zukka": store locally, do not relay

For treatments (insulin, carbs):
- always relay, regardless of source: both phones need to see each other's treatments

This asymmetry is the whole point. One phone is migrated, one is not. The system handles both without either phone knowing about the other's existence.

## The cutover itself

Three commands:

1. Add `ISLET_INGEST_MODE=api` to the environment
2. Comment out the Nightscout polling URL
3. Restart the daemon

The daemon switched from a poll loop (fetch from Nightscout every 60 seconds) to a heartbeat loop (just confirm the service is alive). The API continued accepting uploads without interruption.

Both phones kept posting. Relay kept forwarding. No data gap. No reconfiguration on either device.

## What made it boring

The boring cutover was not an accident. It came from specific decisions made weeks earlier:

1. **Local-first storage** — every record is stored locally before any relay attempt. Relay failure never means data loss.

2. **Idempotent inserts** — INSERT OR IGNORE on deterministic IDs. Duplicate uploads are silently absorbed. During the transition period, polling and direct upload were active simultaneously with no conflicts.

3. **Three ingest modes** — `nightscout` (poll only), `dual` (poll and accept uploads), `api` (uploads only). The migration path was: nightscout, then dual, then api, with each step independently reversible.

4. **Fire-and-forget relay** — relay errors are logged and ignored. The API response is returned after local storage succeeds, not after relay completes. A 5-second Nightscout timeout never blocks a phone upload.

5. **Observability from day one** — device labels in every log line, health endpoint with data lag and circuit breaker state, smoke test script that runs after every deploy.

## What changes now

The architecture is simpler:

Libre 3 sensor, then phone, then islet API, then SQLite.

No intermediate cloud service in the read path. No polling. No dependency on external uptime for local data continuity in the primary path.

Nightscout is still running — it receives relayed data from one phone and serves it to apps that still expect it there. But it is now optional infrastructure, not a critical dependency. If it goes down, islet continues storing data from both phones without interruption.

## What is next

The remaining Nightscout dependency is the relay itself. Once the second phone no longer needs Nightscout for display, the relay can be turned off and Nightscout can be decommissioned entirely.

That is Phase 4 territory — replacing the phone app's dependency on Nightscout with direct islet API consumption. But that is a client-side change, not a server-side one. The server-side ingestion path is complete.

<p class="post-note"><strong>Safety note:</strong> islet is a personal project and is not medical advice. It does not make dosing decisions.</p>
