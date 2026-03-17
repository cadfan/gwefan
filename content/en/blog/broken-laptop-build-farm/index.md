---
title: "A broken laptop as a build farm"
date: 2026-03-03T18:00:00+00:00
description: "A MacBook Pro M2 with a broken screen became a permanent headless iOS and Rust build machine. Here is the setup."
tags: ["infrastructure", "hardware", "ios"]
---

<p class="blog-lead">The screen cracked in a way that made the laptop useless as a laptop but perfectly functional as a computer. The M2 chip, 16GB of RAM, and 512GB of storage still worked. Throwing it away or paying for a screen replacement both seemed wrong. So it became a server.</p>

## The hardware

MacBook Pro M2, 2022. The display is physically intact but the LCD panel has internal damage — a spreading dark region that covers about 60% of the screen. Enough to make it unusable for direct interaction. Not enough to trigger a warranty claim (it was out of warranty anyway).

Everything else works. USB-C ports, Wi-Fi, Bluetooth, the SSD, the speakers. It charges, it boots, it runs macOS. It just cannot show you what it is doing.

## Making it headless

The first step was connecting an external display long enough to configure remote access. Then:

- **Parsec** for visual access — low-latency screen sharing that works well enough for Xcode and simulator interaction
- **SSH** for terminal access — this is how most actual work happens: builds, tests, file transfers
- **VS Code Remote-SSH** for editing — connects over SSH, opens Swift files in a local editor window on the main machine

The Mac is configured to never sleep. Display, disk, system — all disabled. Lid close does nothing. Auto-login enabled. It sits on a shelf plugged into power and Ethernet, drawing about 5 watts idle.

<blockquote class="blog-pullquote">The best server is the one you already own.</blockquote>

## What it builds

**iOS apps.** islet's companion app is a Swift/SwiftUI project. The source lives on my Windows desktop where I do all editing. Files are copied to the Mac via SCP, built with `xcodebuild` via SSH, and tested on the iOS Simulator. The build command is a one-liner:

```bash
xcodebuild -project islet.xcodeproj -scheme islet \
  -destination 'platform=iOS Simulator,name=iPhone 16e' \
  -quiet build
```

When I need to see the simulator, I connect via Parsec. When I just need to know if it compiles, SSH is enough.

**Rust projects.** cymraeg, a Welsh language desktop toolkit, targets macOS among other platforms. The Mac runs `cargo build` and `cargo test` natively.

## The workflow

For iOS development, the typical loop is:

1. Edit Swift files on Windows
2. SCP changed files to the Mac
3. SSH to the Mac, run `xcodebuild`
4. If it fails, read the error output over SSH, fix locally, repeat
5. If it succeeds and I need to see the UI, open Parsec
6. If it succeeds and I just need to verify behaviour, check test output

Steps 2–4 happen without switching windows. The Mac is effectively a build peripheral controlled from the terminal.

## What it replaced

Before this, iOS development meant either:

- Using the Mac as an actual laptop (broken screen made this impractical)
- Not building iOS apps (not acceptable — islet needed a companion app)
- Paying Apple for a cloud Mac (monthly cost for something I already own)

The broken laptop replaced all three options. Total additional cost: one Ethernet cable.

## Gotchas

- **SSH client matters on Windows.** Git Bash's bundled SSH stopped returning stdout when connected to the Mac. The fix was switching to Windows native OpenSSH. The kind of thing that costs two hours to diagnose and thirty seconds to fix.
- **Parsec needs a display.** If the Mac has no physical or virtual display, Parsec has nothing to capture. The broken internal display counts — but if it ever fully dies, an HDMI dummy plug would be needed.
- **Xcode updates are large.** Downloading and installing a multi-gigabyte Xcode update headlessly works fine. But if it requires a restart and the Mac hangs during boot, you need physical access or a previously-configured fallback.

## Is it worth it

The Mac has been running continuously since late February. It has built hundreds of iOS builds, run thousands of tests, and not needed physical interaction.

A Mac Mini M2 costs around £600. A cloud Mac instance costs £40–80/month. The broken MacBook Pro cost nothing beyond what I originally paid for it, and it does the same job.

If you have a Mac with a broken screen, do not sell it for parts. Plug it into power, give it a static IP, set up SSH, and let it work.
