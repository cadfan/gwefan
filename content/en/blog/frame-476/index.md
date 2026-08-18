---
title: "Frame 476"
date: 2026-04-04T00:01:00+00:00
description: "A GBA emulator crashed deterministically at frame 476. The first theory was wrong. The second theory was wrong. The third one explained everything."
tags: ["cable-club", "emulation", "debugging", "rust"]
---

<p class="blog-lead">FireRed crashed eight seconds after boot. Every time. Frame 476. Not a hang, not a glitch &mdash; the CPU branched to garbage in palette RAM and stopped executing real instructions. The crash was 100% deterministic. Same frame, same instruction, same corrupted address. That kind of determinism means there is a root cause, and it is findable.</p>

## The symptom

Pokemon FireRed uses a sound engine called m4a (MusicPlayer2000). It runs in IWRAM &mdash; the GBA's fast 32KB internal RAM &mdash; and mixes audio samples into a buffer every VBlank. A register called R5 tracks the write position in the buffer. Normally, R5 stays within the buffer boundaries: a 1,584-byte region starting at 0x030061B0.

At frame 476, R5 was at 0x030079CC. That is 6,172 bytes past the start of the buffer &mdash; well outside the allocated region, deep into unrelated IWRAM data. When the mixer wrote the right channel sample to [R5 + 0x630], it hit address 0x03007FFC. That address is the IRQ handler pointer. The write overwrote the interrupt handler with audio sample data. The next interrupt branched to garbage.

<div class="blog-stat-row">
  <div class="blog-stat">
    <div class="blog-stat-num">476</div>
    <div class="blog-stat-label">Crash frame</div>
  </div>
  <div class="blog-stat">
    <div class="blog-stat-num">4,383</div>
    <div class="blog-stat-label">IWRAM writes (vs 554 normal)</div>
  </div>
  <div class="blog-stat">
    <div class="blog-stat-num">0x03007FFC</div>
    <div class="blog-stat-label">Corrupted address</div>
  </div>
</div>

## The first theory: timer drift

The m4a engine uses Timer 0 to count elapsed audio samples. Timer 0 overflows at roughly 13,381 Hz, which works out to 224 overflows per VBlank &mdash; exactly matching the number of samples the mixer writes per frame.

The theory: timers were not ticking during DMA transfers in the emulator. On real GBA hardware, timers are independent hardware counters that free-run regardless of what the CPU or DMA is doing. If the emulator paused timers during DMA, Timer 0 would fall behind. The m4a engine would read a stale counter, compute the wrong number of samples, and the mixer's write pointer would drift.

I implemented the fix. Wired up `tick_during_dma()` so timers advanced properly during DMA transfers, using O(1) batch computation to avoid per-cycle overhead.

Then I ran three tests.

| Test | Crash frame | Result |
|------|-------------|--------|
| Timer fix enabled | 476 | Still crashes |
| Timer fix disabled | 476 | Still crashes |
| HALT fast-forward disabled | 476 | Still crashes |

Same frame. Every time. The timer theory was wrong.

<blockquote class="blog-pullquote">Three independent tests. Same crash frame every time. The timer theory was dead.</blockquote>

## The second theory: DMA source drift

The DMA controller copies audio samples from the mixer buffer to the GBA's FIFO audio registers. DMA1 handles the left channel, DMA2 handles the right. The source address advances by approximately 224 bytes per VBlank and resets every seven VBlanks.

Tracing the DMA source addresses revealed anomalies. Some frames showed 240-byte advances instead of 224 &mdash; sixteen extra bytes. These anomalies correlated with frames that had elevated DMA cycle counts. The extra DMA cycles caused extra timer overflows, which caused extra FIFO pops, which triggered extra DMA refills of sixteen bytes each.

But this was a symptom, not the cause. The DMA source drift was a downstream effect of something else. R5 was advancing linearly through IWRAM without wrapping at the buffer boundary. The question was why.

## The real cause: stale prefetch after BX

The ARM7TDMI has two execution modes: ARM (32-bit instructions) and Thumb (16-bit instructions). The BX instruction switches between them. The CPU also has a prefetch pipeline &mdash; it fetches the next instruction before finishing the current one, so execution can proceed without waiting for memory.

Here is the problem. When the CPU is in Thumb mode, the prefetch contains a 16-bit value fetched from the current PC. When BX switches to ARM mode, the pipeline still holds that 16-bit Thumb prefetch. If the target address of the BX happens to match the address already in the prefetch buffer, the CPU thinks it already has the next instruction and skips the fetch. But it has a 16-bit Thumb value where it needs a 32-bit ARM instruction. It decodes half an instruction plus whatever was adjacent in memory.

In the m4a mixer, this manifested as a corrupted STR instruction. The mixer loop should have stored a sample to the buffer and wrapped R5 at the boundary. Instead, the corrupted instruction skipped the store that would have reset R5, and the pointer advanced linearly through IWRAM until it reached the IRQ handler.

The fix was one line: flush the prefetch pipeline on every BX instruction.

```rust
// Before: BX branched but kept stale prefetch
// After: flush forces a fresh fetch at the new PC
cpu.prefetch = None;
```

One line. Four hours of investigation. Frame 476 became frame infinity.

<blockquote class="blog-pullquote">One line. Four hours of investigation. Frame 476 became frame infinity.</blockquote>

## Why accuracy testing matters

This bug would not have been caught by the standard ARM test suites. The jsmolka tests verify individual instructions in isolation. They do not run the m4a sound engine, they do not trigger DMA-driven audio, and they do not exercise the prefetch pipeline across mode switches in the specific pattern that FireRed's mixer uses.

The bug only appeared because the accuracy harness ran FireRed for 476 real frames and compared the result against NanoBoyAdvance. Without frame-level accuracy testing, this would have been a "sometimes the game crashes" report with no reproducible path to the root cause.

The timer fix was also correct, even though it was not the cause of this crash. Timers should tick during DMA &mdash; that is how the real hardware works. The investigation produced two fixes: one for the bug I was looking for, and one for a bug I was not.

## What debugging an emulator teaches you

Emulator bugs do not look like application bugs. There is no stack trace. There is no error message. There is a program counter pointing at data instead of instructions, and a four-hour trail of disproved theories between you and the one-line fix.

The skills transfer, though. Following a deterministic crash through layers of indirection &mdash; from a visible symptom to a memory corruption to a pipeline hazard &mdash; is the same discipline as debugging any complex system. The difference is that the system you are debugging is a CPU, and the bug is that your CPU does not behave exactly like the real one.

Frame 476 is fixed. The [next post](/blog/extracting-the-judge/) covers the accuracy test harness that made finding it possible.
