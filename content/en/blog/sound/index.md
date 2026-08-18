---
title: "Sound"
date: 2026-04-05T00:01:00+00:00
description: "What it sounds like when your GBA emulator plays music for the first time."
tags: ["cable-club", "emulation", "audio", "rust"]
---

<p class="blog-lead">For the first four days, cable-club was silent. The screen showed FireRed's intro &mdash; the title screen, the Oak speech, the options menu &mdash; but there was no sound. Audio registers existed as stubs that accepted writes and returned zeros. The game thought it was playing music. Nothing came out.</p>

## The GBA's audio hardware

The Game Boy Advance has two audio systems running simultaneously.

The **PSG** (Programmable Sound Generator) is inherited from the original Game Boy. Four channels: two square waves with configurable duty cycle and frequency sweep, one custom waveform channel that plays samples from a 32-byte wave RAM, and one noise channel driven by a linear feedback shift register. Each channel has its own length counter and volume envelope. This is the chip-tune hardware &mdash; the beeps, the bloops, the sound effects.

The **FIFO** (First In, First Out) channels are the GBA's addition. Two DMA-driven channels that play 8-bit PCM samples at the Timer 0 overflow rate. This is where the music lives. Games like FireRed stream pre-mixed audio samples through the FIFO channels, timed to DMA transfers triggered by Timer 0 overflows. The m4a sound engine handles the mixing in software, writing samples to a buffer in IWRAM that DMA copies to the audio hardware.

Both systems feed into a final mixer controlled by the SOUNDBIAS register, which sets the output sample rate and bias level. The GBA's DAC runs at 32,768 Hz (or configurable multiples). Everything &mdash; PSG channels, FIFO channels, master volume, panning &mdash; mixes down to a stereo output.

## Building the PSG

Each PSG channel is a small state machine. Channel 1 (square wave with sweep) is the most complex: a frequency sweep unit that shifts the period up or down at configurable intervals, a length counter that optionally silences the channel after a set duration, a volume envelope that ramps volume up or down over time, and a duty cycle selector that shapes the square wave (12.5%, 25%, 50%, or 75% high).

Channel 3 (wave) reads samples from a 32-nibble wave RAM &mdash; each nibble is a 4-bit amplitude value. The channel steps through the wave table at a rate determined by the frequency register, producing a custom waveform. Games use this for bass lines and melodic sounds that do not fit a square wave.

Channel 4 (noise) is a 15-bit or 7-bit linear feedback shift register. The shift register produces pseudo-random values at a configurable clock rate, creating white noise or metallic tones depending on the width. Explosions, rain, static.

<blockquote class="blog-pullquote">Each PSG channel is a small state machine. Together, they are the voice of the Game Boy.</blockquote>

## Building the FIFO

The FIFO channels are simpler in concept but harder in timing. Each FIFO is a 32-byte buffer. When Timer 0 (or Timer 1, depending on configuration) overflows, the FIFO pops one sample and sends it to the mixer. When the FIFO runs low, it triggers a DMA transfer that refills it from the game's audio buffer in memory.

The timing has to be right. If the FIFO pops too fast, it underflows and produces silence or clicks. If it pops too slowly, audio lags behind the game. The relationship between Timer 0's overflow rate, the DMA transfer size, and the game's audio buffer management is the critical path. Get it wrong and the audio drifts, crackles, or &mdash; as I learned with the [Frame 476 bug](/blog/frame-476/) &mdash; crashes the game.

## The output path

The final step was getting audio out of the emulator and into speakers. SDL2's audio subsystem provides a callback-driven ring buffer: the audio thread calls a function whenever it needs more samples, and the emulator fills the buffer with the mixed output from the previous frame.

The mixing itself is straightforward. Each active PSG channel contributes a sample scaled by its current volume. Each FIFO channel contributes its current sample scaled by its volume setting. Left and right channels are mixed separately based on the panning configuration in the sound control registers. The result is clamped to the output range and written to the SDL2 buffer.

<div class="blog-stat-row">
  <div class="blog-stat">
    <div class="blog-stat-num">4</div>
    <div class="blog-stat-label">PSG channels</div>
  </div>
  <div class="blog-stat">
    <div class="blog-stat-num">2</div>
    <div class="blog-stat-label">FIFO channels</div>
  </div>
  <div class="blog-stat">
    <div class="blog-stat-num">32 KHz</div>
    <div class="blog-stat-label">Output rate</div>
  </div>
</div>

## The moment it worked

There is a specific moment when building an emulator where the screen has been working for days and you have been debugging in silence. Then you wire up the audio output, run the ROM, and the title screen music plays. It is not a gradual thing. One frame there is silence, the next frame there is the FireRed title theme.

It was not perfect. The first version had a slight crackle from buffer underflows during DMA-heavy frames. The PSG volume envelopes were stepping too fast, making sound effects decay unnaturally. The noise channel's LFSR was using the wrong tap position for 7-bit mode, producing a buzz instead of a hiss.

But the music played. The structure was there. Each fix after that was incremental &mdash; adjusting envelope timing, fixing the noise tap, smoothing the buffer management. The hard part was not the fixes. The hard part was the architecture that made the fixes possible: a clean separation between PSG synthesis, FIFO management, and the output path, so each could be debugged independently.

<blockquote class="blog-pullquote">One frame there is silence, the next frame there is the FireRed title theme.</blockquote>

cable-club v0.3.0 plays FireRed with sound. The [source is on GitHub](https://github.com/cadfan/cable-club). Next: the link cable networking that started all of this.
