---
title: "ira gets race planning: from telemetry display to session companion"
date: 2026-03-01T12:00:00+00:00
description: "Seven commits in a day turned ira from a telemetry viewer into a race planning tool — with race guides, session registrations, owned content filtering, and a unit test suite."
tags: ["ira", "iracing", "c"]
---

<p class="blog-lead">ira started as a telemetry display. Connect to iRacing's shared memory, show speed and RPM, log to CSV. Useful but narrow. On Saturday it gained race guides, session registrations, owned content detection, and a test suite. Seven commits. One day. A different kind of application.</p>

## What ira was

A C program that did three things well:

1. Read telemetry from iRacing's shared memory at 60Hz
2. Log that telemetry to CSV for post-session analysis
3. Launch helper applications automatically when a session starts

All local. No network calls. No authentication. The iRacing SDK gives you shared memory for free, and everything ira did was built on that foundation.

## What changed

iRacing has an HTTP API behind OAuth2. It knows what content you own, what races are scheduled, who is registered for upcoming sessions, and what the next race time is for every series. All of that information is useful before you click "Join" &mdash; and none of it was accessible from ira.

Saturday's sprint added four capabilities:

**Race guide** &mdash; fetch the week's schedule for any series: track name, session times, registration counts. Instead of opening the iRacing website to check what's running, the information is available from the terminal.

**Session registrations** &mdash; see which upcoming sessions have registrations open, how many drivers are signed up, and when they start. Useful for picking sessions with healthy grids rather than guessing.

**Owned content filtering** &mdash; query the member info API for owned cars and tracks, then filter the race schedule to only show series where you actually own the required content. No more scrolling past races you can't enter.

**Next race time** &mdash; calculate when the next session starts for a series using the schedule's repeat interval. A simple question ("when does the next MX-5 race go off?") that previously required mental arithmetic or a browser tab.

## The test suite

The same day also added the project's first unit test suite. Filter logic, model parsing, time calculations &mdash; the kind of code that is easy to get subtly wrong and hard to debug through manual testing.

One immediate payoff: the vibe review that ran after implementation caught three bugs &mdash; UTC timestamp handling, a session registration cache issue, and an integer overflow edge case. All three were found because the tests made the expected behaviour explicit enough to reason about.

<blockquote class="blog-pullquote">The first test suite a project gets is always the most valuable one.</blockquote>

## Why C

ira is written in C11. Not because C is the right choice for HTTP API clients &mdash; it is not &mdash; but because the project started as a telemetry tool, and shared memory access in C is natural. The iRacing SDK is a C API. The data structures map directly. There is no marshalling, no bindings layer, no impedance mismatch.

Adding HTTP and JSON on top of that means pulling in libraries (libcurl, cJSON) and writing more boilerplate than a higher-level language would require. But the alternative &mdash; rewriting the telemetry layer in another language &mdash; would lose the direct SDK integration that makes the core of the application clean.

So the project stays in C and accepts the trade-off: more explicit code for API work, but a single language and build system for the entire application.

## What is next

The race planning features are read-only for now. The logical next step is making them actionable: filtering the race guide against your owned content automatically, presenting a "what can I race right now" view, and eventually integrating with the telemetry side so that pre-race information flows into the session context.

ira is still a terminal application. But it is no longer just a telemetry viewer.
