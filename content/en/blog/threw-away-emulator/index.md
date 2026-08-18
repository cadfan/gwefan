---
title: "I threw away a working emulator"
date: 2026-03-31T00:01:00+00:00
description: "The first GBA emulator booted Pokemon FireRed in two days. I deleted it and started over. Here is why."
tags: ["cable-club", "emulation", "rust", "development"]
---

<p class="blog-lead">On March 29, I started writing a Game Boy Advance emulator from scratch in Rust. By March 30 &mdash; seventeen commits and roughly thirty-six hours later &mdash; Pokemon FireRed was playing its intro cinematic. The CPU passed 100% of the standard ARM and Thumb test suites. The relay server was working. I had a functioning emulator. Then I threw it away.</p>

## Why a GBA emulator

My nephew Declan has never seen a Game Boy. I wanted to trade Pokemon with him over the internet, the way I did with a link cable twenty years ago. That is the entire motivation.

Existing emulators can play GBA games. Some even support link cable emulation. But none of them make it easy to connect two people over the internet with a room code, trade a Charmander, and disconnect. The networking is always an afterthought bolted onto an emulator designed for single-player use. I wanted the link cable to be the point, not the afterthought.

The project is called cable-club, after the room in the original Pokemon games where you go to trade.

## The first attempt

The first version was built from the GBATEK technical reference &mdash; Martin Korth's comprehensive documentation of the GBA hardware. I read the spec, implemented each subsystem, and tested against the standard test ROM suites.

It worked. The ARM7TDMI CPU passed 532 out of 532 ARM instruction tests and all Thumb tests. The PPU rendered tile-based backgrounds in modes 0, 1, 3, and 4. The DMA controller moved data. The timers ticked. The relay server handled room codes and frame synchronisation over TCP. FireRed loaded, executed its init sequence, and played the Game Freak logo animation.

<div class="blog-stat-row">
  <div class="blog-stat">
    <div class="blog-stat-num">17</div>
    <div class="blog-stat-label">Commits</div>
  </div>
  <div class="blog-stat">
    <div class="blog-stat-num">532/532</div>
    <div class="blog-stat-label">ARM tests</div>
  </div>
  <div class="blog-stat">
    <div class="blog-stat-num">36h</div>
    <div class="blog-stat-label">Elapsed</div>
  </div>
</div>

But "it boots" is not the same as "it is correct."

## What was wrong

The CPU handlers were written from the spec alone, without studying how battle-tested emulators handle edge cases. GBATEK tells you what the ARM7TDMI does. It does not tell you what happens when a game writes to a register in a way the spec calls "unpredictable." Real games do unpredictable things constantly.

When FireRed moved past the logo animation into actual gameplay, the CPU jumped into a data table. Program counter at 0x08352xxx &mdash; ROM address space, but the bytes at that address were not instructions. They were data. The CPU had silently taken a wrong branch sometime during init and ended up executing lookup table entries as ARM opcodes. No crash. No error. Just a black screen.

This is the fundamental problem with emulators: CPU bugs do not crash. They produce wrong results that cascade silently until something visible breaks. The symptom &mdash; a black screen with no IO writes &mdash; was hundreds of instructions downstream from the actual cause.

<blockquote class="blog-pullquote">"It boots" is not the same as "it is correct."</blockquote>

I could have debugged that. Added instruction tracing, compared against a reference emulator, found the divergence. But the architecture had a deeper problem: there was no systematic way to verify accuracy. The test ROM suites test individual instructions in isolation. They do not test the complex interactions between the CPU, memory bus, DMA controller, and interrupt system that real games depend on.

## The rewrite

On April 2, I created a new repository. Same language, same goal, different approach.

The rewrite studied mGBA &mdash; the most accurate open-source GBA emulator &mdash; as an architectural reference. Not a fork, not a line-by-line copy. A studied rewrite where every subsystem was implemented by reading the GBATEK spec and then verifying the approach against how mGBA handles the same problem. Where mGBA makes a different choice, I investigated why. Usually, mGBA was right because it had years of edge-case fixes that the spec does not capture.

The other change was building an accuracy test harness from day one. Not just unit tests for individual instructions, but frame-level comparison against reference emulators. Run a test ROM for a fixed number of frames, hash the framebuffer, compare against a known-good hash from NanoBoyAdvance (a cycle-accurate GBA emulator). If the hash matches, the frame is correct. If it does not, something is wrong and you get a diff image showing exactly which pixels differ.

This is the difference between "passes tests" and "matches reality."

## What the rewrite produced

In four days, the rewrite went from an empty repository to v0.3.0:

<div class="blog-stat-row">
  <div class="blog-stat">
    <div class="blog-stat-num">19/19</div>
    <div class="blog-stat-label">Accuracy tests</div>
  </div>
  <div class="blog-stat">
    <div class="blog-stat-num">79</div>
    <div class="blog-stat-label">Commits</div>
  </div>
  <div class="blog-stat">
    <div class="blog-stat-num">v0.3.0</div>
    <div class="blog-stat-label">With audio</div>
  </div>
</div>

ARM7TDMI with a prefetch pipeline that handles self-modifying code. Real BIOS boot sequence (not just HLE stubs). All background modes, OBJ sprites with 4bpp and 8bpp, affine transformations, alpha blending. Full DMA with mid-transfer timer ticks. SRAM save persistence. A complete APU with PSG synthesis and FIFO audio mixing. And 19 out of 19 accuracy tests passing against NanoBoyAdvance reference hashes.

FireRed boots to the Oak intro. With sound.

## The cost of starting over

The first attempt was not wasted. It taught me where the hard problems are &mdash; the prefetch pipeline, the save detection protocol, the difference between HLE and real BIOS behaviour. That knowledge made the rewrite faster, not slower.

But the real lesson was about testing infrastructure. The first attempt had unit tests for CPU instructions and called it verified. The rewrite has frame-level accuracy tests against a gold-standard reference emulator. One approach tells you that individual pieces work. The other tells you that the whole system produces correct output.

I will write more about the accuracy harness and the specific bugs it caught. For now: the emulator that booted FireRed in thirty-six hours was impressive. The emulator that matches NanoBoyAdvance frame-for-frame is correct. Those are different things, and the difference matters.

<blockquote class="blog-pullquote">The emulator that booted FireRed in thirty-six hours was impressive. The emulator that matches NanoBoyAdvance frame-for-frame is correct. Those are different things.</blockquote>

The [source is on GitHub](https://github.com/cadfan/cable-club). The link cable networking &mdash; the original reason for building this &mdash; is next.
