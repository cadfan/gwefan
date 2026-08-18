---
title: "How I test things"
date: 2026-04-05T00:02:00+00:00
description: "Three projects, three kinds of testing, one shared principle: if you cannot verify it automatically, you do not know if it works."
tags: ["testing", "development", "islet", "casectl", "cable-club"]
---

<p class="blog-lead">islet has over 600 tests. casectl has 313. cable-club has 19 accuracy tests that compare framebuffer output pixel-by-pixel against a reference emulator. These are different projects in different languages solving different problems, and they all test heavily. This is not an accident.</p>

## The principle

If you cannot verify a claim automatically, you do not actually know if it is true. You think it works. You believe it works. You tested it manually once and it seemed fine. None of that counts. What counts is a command you can run that tells you, definitively, whether the system does what it is supposed to do.

This is not a controversial position in professional software engineering. But in personal projects &mdash; projects with one user, no deadlines, no code review &mdash; testing is the first thing that gets cut. You know how it works because you just wrote it. Why test what you can see?

Because you will change it. Because you will forget how it works. Because the thing you can see is the happy path, and the thing that breaks is the edge case you did not think about.

<blockquote class="blog-pullquote">If you cannot verify it automatically, you do not actually know if it is true.</blockquote>

## islet: testing a data pipeline

islet processes glucose readings from a continuous glucose monitor. The data flows from a phone app through an ingest API into SQLite, where it gets analysed, scored, and served back through a REST API. The pipeline has multiple stages, and each stage transforms data in ways that are easy to get subtly wrong.

The testing strategy is layered. Unit tests verify that individual functions &mdash; glucose scoring, time-window calculations, trend analysis &mdash; produce correct output for known inputs. Integration tests verify that the ingest API accepts data in the correct format, stores it in the right tables, and rejects malformed requests. End-to-end tests verify that a glucose reading posted to the ingest endpoint eventually appears in the correct format from the query API.

The most valuable tests are the ones that verify behaviour across schema migrations. islet is on schema version 6. Each migration transforms existing data, and the tests verify that data written under the old schema reads correctly under the new one. Without those tests, I would have broken production data at least twice.

<div class="blog-stat-row">
  <div class="blog-stat">
    <div class="blog-stat-num">600+</div>
    <div class="blog-stat-label">islet tests</div>
  </div>
  <div class="blog-stat">
    <div class="blog-stat-num">313</div>
    <div class="blog-stat-label">casectl tests</div>
  </div>
  <div class="blog-stat">
    <div class="blog-stat-num">19/19</div>
    <div class="blog-stat-label">cable-club accuracy</div>
  </div>
</div>

## casectl: testing hardware without hardware

casectl controls physical hardware &mdash; fans, LEDs, an OLED display &mdash; on a Raspberry Pi. The tests run on my Windows development machine, which has none of that hardware. This is the core tension: how do you test a hardware controller without the hardware?

The answer is the plugin architecture. Every hardware interaction goes through a plugin interface. The tests use mock plugins that record what the daemon asked them to do without touching real I2C buses or GPIO pins. The daemon does not know the difference.

This lets me test the full control flow &mdash; API request arrives, daemon routes it to the correct plugin, plugin returns success, daemon updates its state &mdash; without a Raspberry Pi present. The mock verifies that the daemon sent the right command with the right parameters. The real plugin on the Pi translates that command into hardware actions.

The tests I trust most are the ones that verify the daemon's state machine: what happens when the fan mode changes while a temperature reading is in progress, what happens when two API requests arrive simultaneously, what happens when a plugin fails to respond. State machines are where personal projects accumulate the most bugs, because the developer only manually tests the happy path.

## cable-club: testing a system against reality

CPU test suites verify individual instructions. Accuracy tests verify the whole system. I covered this in detail in [Extracting the judge](/blog/extracting-the-judge/), but the key insight is worth repeating: a GBA emulator can pass every standard test and still produce wrong output, because the tests do not exercise the interactions between subsystems.

The cable-club accuracy harness does not test cable-club against a specification. It tests cable-club against another emulator &mdash; NanoBoyAdvance, which is cycle-accurate and passes 100% of the standard suites. This is a different philosophy from islet and casectl, where the tests verify behaviour against expected values I defined. In cable-club, the expected values come from an independent implementation of the same system.

This approach has a limitation: if NanoBoyAdvance has a bug, cable-club will replicate it. But for a project at this stage, matching a battle-tested reference emulator is the right bar. The alternative &mdash; testing against the actual GBA hardware &mdash; requires capture hardware I do not have. Reference emulator hashes are the practical gold standard.

## What testing costs and what it pays back

Writing tests takes time. For casectl, roughly a third of the development time went to tests. For islet, the proportion is higher because the migration tests are complex. For cable-club, the accuracy harness itself became a [separate open-source project](/blog/extracting-the-judge/).

What it pays back is the ability to change things. islet has gone through six schema migrations. casectl was refactored from a monolithic daemon to a plugin architecture. cable-club was rewritten from scratch. In each case, the tests told me immediately what the change broke and what still worked. Without them, every change would require manually verifying every feature, and I would stop making changes because the verification cost would exceed the benefit.

<blockquote class="blog-pullquote">What testing pays back is the ability to change things.</blockquote>

For personal projects with one user, testing is not about quality assurance in the corporate sense. It is about giving yourself permission to keep building. The tests are not a gate. They are a safety net that lets you move fast without worrying about what you are breaking behind you.
