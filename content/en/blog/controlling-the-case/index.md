---
title: "Controlling the case"
date: 2026-03-25T00:01:00+00:00
description: "The Raspberry Pi case came with hardware I could not control properly. So I wrote the software myself."
tags: ["casectl", "hardware", "raspberry-pi", "development"]
---

<p class="blog-lead">In late March, I bought a Freenove case kit for griffpi &mdash; the Raspberry Pi that runs everything. Three PWM fans, four addressable LEDs, a small OLED screen, and an STM32 expansion board that ties it all together over I2C. The case came with a Python script. The script was not good enough.</p>

## The problem

The stock software was a single monolithic script that assumed it was the only thing running on the Pi. It pinned a CPU core polling temperature in a tight loop. It had no configuration file. It could not be controlled remotely. If you wanted to change the fan speed, you edited the script, killed the process, and restarted it.

This is fine for a demo. It is not fine for a Pi that runs a glucose data platform, a mail server, a website, and a Cloudflare tunnel. I needed something that ran as a proper service, responded to commands, and did not waste resources.

## The architecture

casectl is a daemon with a plugin system. Every feature &mdash; fan control, LED patterns, OLED screens, temperature monitoring, MQTT integration &mdash; is a plugin. The daemon loads plugins at startup, exposes a REST API, and runs a background loop that ticks each plugin at its configured interval.

The plugin architecture was a deliberate decision. The Freenove board has a specific set of hardware, but the next case might have different hardware. Or I might add a USB temperature probe. Or a relay board. Plugins mean I can add capabilities without touching the core daemon.

<blockquote class="blog-pullquote">Every feature is a plugin. The daemon does not know what a fan is. It knows what a plugin is.</blockquote>

Eight built-in plugins ship with v0.2.0: fan control (five modes including temperature-based auto and custom curves), LED control (rainbow, breathing, follow-temp, manual colour with sixteen named colours and hex codes), OLED display (four cycling info screens), system monitoring, MQTT with Home Assistant auto-discovery, automation rules, alerting via webhook, and Prometheus metrics.

## Three ways in

The daemon is the core. But I interact with the case three different ways depending on what I am doing.

**The CLI** is for quick commands from an SSH session. `casectl fan mode follow-temp` sets the fans to temperature-tracking mode. `casectl led color red` turns the LEDs red. `casectl doctor` runs a hardware diagnostic. It is Click-based, with proper help text and tab completion.

**The web dashboard** is for when I want to see everything at once. It runs on the daemon and uses HTMX for live updates without a JavaScript framework. Mode dropdowns, colour pickers, fan speed sliders, OLED screen toggles. It is not beautiful. It is functional.

**The TUI** is for monitoring. `casectl top` shows a live-updating terminal dashboard with CPU temperature, fan speeds, LED state, memory usage, and disk space. Interactive controls let you cycle fan modes and adjust speed without leaving the terminal. It is the interface I use most often.

## Building hardware software

I build data pipelines and web services. I do not build hardware control software. The transition was interesting.

The hardest part was not the I2C communication or the PWM duty cycles. Those are well-documented. The hardest part was the feedback loop. When I write a bug in islet, I get a wrong number in a database. When I write a bug in casectl, a fan either spins at full speed or stops entirely. The consequences are physical and immediate.

The OLED screen was the most satisfying part. Four cycling screens showing CPU temperature with a gauge, memory and disk usage, network stats, and system uptime. The display is 128&times;64 pixels &mdash; every pixel matters. Getting the layout right at that resolution required a different kind of thinking than responsive web design. There is no scrolling. There is no "below the fold." Everything that matters has to fit on screen at once.

<blockquote class="blog-pullquote">When you write a bug in hardware control software, the consequences are physical and immediate.</blockquote>

## The documentation site

casectl has its own documentation site at [casectl.griffiths.cymru](https://casectl.griffiths.cymru). API reference, CLI reference, configuration guide, plugin development documentation. It felt excessive for a project with one user, but writing the docs forced me to think about the API surface properly. Several rough edges got smoothed in the process of explaining them.

## Where it stands

<div class="blog-stat-row">
  <div class="blog-stat">
    <div class="blog-stat-num">8</div>
    <div class="blog-stat-label">Plugins</div>
  </div>
  <div class="blog-stat">
    <div class="blog-stat-num">313</div>
    <div class="blog-stat-label">Tests</div>
  </div>
  <div class="blog-stat">
    <div class="blog-stat-num">5</div>
    <div class="blog-stat-label">Days to build</div>
  </div>
</div>

casectl runs as a systemd service on griffpi. The fans follow the CPU temperature. The LEDs breathe in a slow rainbow when idle. The OLED cycles through system stats every few seconds. It does exactly what I need, controlled from whichever interface suits the moment, and nothing more.

The [source is on GitHub](https://github.com/cadfan/casectl) under MIT. It is specific to the Freenove FNK0107 series, but the plugin architecture means adapting it to different hardware is a matter of writing new plugins rather than rewriting the core.
