---
title: "Software for one"
date: 2026-03-21T00:01:00+00:00
description: "Every project I build has exactly one user. That is not a limitation — it is the entire design constraint."
tags: ["personal", "development"]
---

<p class="blog-lead">islet has one user. pwyslais has one user. llywio has one user. ira has one user. I am that user. This is not a limitation &mdash; it is the design constraint that makes everything else possible.</p>

## The advantage

When you build for one person, every decision collapses into a question you can answer immediately: does this work for me? Not "does this work for most users" or "will this confuse new signups" or "should we A/B test this." Does it work for me, right now, on my hardware, with my constraints.

islet runs on SQLite because I have one Raspberry Pi, not a database cluster. pwyslais uses Claude because I already have an API key, not because I evaluated five LLM providers. llywio targets iOS 17 because that is what my phone runs. ira reads iRacing's shared memory directly because there is no abstraction layer to justify when the only consumer is sitting in the same process.

Every technical decision is informed by one person's actual situation, and that specificity produces systems that fit precisely rather than generically.

<blockquote class="blog-pullquote">Specificity produces systems that fit precisely rather than generically.</blockquote>

## The cost

There is no second opinion. When I decide that pwyslais should track forgotten threads with a seven-day nudge window, nobody pushes back on whether seven days is the right number. When I decide that islet's alert thresholds should be configurable via environment variables rather than a settings UI, nobody asks whether that is too technical for a user who is not me.

The design space is unconstrained in ways that feel like freedom but can also mean you never question your own assumptions. Every project benefits from at least one person saying "I would not do it that way." When you are the only user, you have to be that person too.

The other cost is documentation. When you are the only user, you stop writing docs because you know how it works. Then three months pass and you do not. islet has architecture documents because it grew large enough that I forgot how the relay routing worked. pwyslais &mdash; a project literally about remembering things &mdash; will inevitably need the same treatment.

## Why not use what exists

Nightscout exists. Day One exists. Google Maps exists. These are not bad tools. They are excellent tools built for a broad audience, and that breadth is exactly what makes them wrong for specific problems.

Nightscout assumes you want a web-based dashboard with a MongoDB backend. I wanted a daemon on a Pi with SQLite and data that never leaves my house. Day One assumes you will search your own journal. I needed the journal to search itself, because I will not remember to look. Google Maps optimises routes for drivers. llywio optimises routes for delivery workers with time windows, vehicle capacity constraints, and Welsh-language turn-by-turn.

The gap between "good enough for most people" and "exactly right for this person" is where personal software lives. Closing that gap is the entire point.

## The shared architecture

Every project on this site shares a pattern: local-first, self-hosted, SQLite-backed, deployed to hardware I own. This is not ideology. It is practicality. When the internet drops &mdash; which it does, because I live in rural Wales &mdash; islet still tracks glucose, pwyslais still accepts entries, and the mail server still queues outbound messages. Nothing depends on a service I do not control.

The Pi costs &pound;80. Electricity is negligible. There is no monthly subscription. No terms of service change. No API deprecation notice arriving by email on a Friday afternoon. The trade-off is maintenance, and I accept that trade-off because maintaining my own systems teaches me more than subscribing to someone else's.

<blockquote class="blog-pullquote">The trade-off is maintenance, and I accept that trade-off.</blockquote>

## One user is enough

People sometimes ask who these projects are for. The answer is always the same. They are for me. That is not a humble disclaimer &mdash; it is the entire design philosophy. Software for one user can be opinionated in ways that software for a thousand users cannot. It can break backward compatibility whenever it needs to. It can use Welsh labels without localisation infrastructure. It can store everything in a single SQLite file on a Raspberry Pi because that is genuinely, honestly, all it needs.

If other people find value in the code, the design, or the approach, that is a welcome side effect. But it is not the goal. The goal is software that works exactly the way I need it to, and nothing more.
