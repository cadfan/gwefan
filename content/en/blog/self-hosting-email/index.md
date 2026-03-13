---
title: "Self-hosting email in 2026"
date: 2026-03-02T18:00:00+00:00
description: "Running your own mail server on a Raspberry Pi. What works, what hurts, and whether it is worth it."
tags: ["infrastructure", "self-hosting"]
---

<p class="blog-lead">I run my own email server. On a Raspberry Pi. In my house. It sends and receives real email. People reply to it. It has not lost a message. I would not recommend it to most people.</p>

## The approach

The fundamental problem with self-hosting email is that the internet assumes you are a spammer until proven otherwise. Residential IP addresses have no reputation. ISPs block the ports you need. Even with every DNS record configured perfectly, the big providers will silently drop your messages for weeks until they decide you are probably legitimate.

The solution is to avoid the hard parts entirely:

- **Inbound mail** arrives via a third-party email routing service, not directly to my IP. The routing service handles MX records and forwards mail to the Pi through a secure tunnel.
- **Outbound mail** goes through a reputable SMTP relay. The relay has established IP reputation, so messages land in inboxes instead of spam folders.

The mail server itself runs on the Pi in Docker. It handles IMAP (so I can read mail on my phone), spam scoring, DKIM signing, and mailbox storage. It does not face the public internet directly for either sending or receiving.

## What works

- **IMAP from my phone.** I access email over a private VPN connection to the Pi. No port forwarding, no public IMAP endpoint.
- **Webmail from anywhere.** A lightweight webmail client runs on the Pi, accessible through a tunnel. It is not fast. It is functional.
- **DNS authentication.** DMARC, SPF, and DKIM are all configured. Aggregate reports from the big providers show 100% pass rates for relayed messages.
- **Multiple addresses.** Adding a new address is editing one config line. No monthly fee per mailbox.
- **Real conversations.** I have emailed businesses, received replies, carried on threads. It works the way email is supposed to work.

## What hurts

- **The inbound path has custom glue.** The routing service cannot deliver directly to a mail server behind a tunnel. A small bridge service converts the incoming webhook to SMTP and delivers locally. It works, but it is a bespoke component. When it breaks, the debugging path crosses multiple systems.
- **Debugging delivery failures is painful.** When an email does not arrive, the failure could be anywhere in a chain of services. Each has its own logs, its own failure modes, and its own way of being unhelpful about what went wrong.
- **Documentation is thin.** The mail server software is excellent. Its docs assume you already know how every SMTP extension works and where every config option lives. The learning curve is steep.
- **Spam filtering is basic.** Built-in scoring works for a single-user server receiving a few messages a day. For higher volume, you would want additional filtering.

<blockquote class="blog-pullquote">Self-hosting email is not hard because the software is bad. It is hard because email itself is an adversarial protocol built on mutual distrust.</blockquote>

## Is it worth it

For most people: no. Gmail and Fastmail are better in every measurable way. They are more reliable, more searchable, better at spam filtering, and require zero maintenance.

For me: yes, but not for the obvious reasons. I do not do it primarily for privacy (outbound mail passes through a relay). I do not do it for uptime guarantees (a power cut at home takes it offline). I do it because:

- **It completes the infrastructure.** The Pi runs my website, my glucose data platform, and my mail. One machine, one person's digital life.
- **It is educational.** I now understand DKIM, DMARC, SPF, and SMTP relay at a level that reading about them never achieved.
- **It works.** I emailed a bakery from my self-hosted server and [they replied](/blog/bakery-carb-data/). That is the bar, and it clears it.

<div class="blog-stat-row">
  <div class="blog-stat">
    <div class="blog-stat-num">0</div>
    <div class="blog-stat-label">Lost messages</div>
  </div>
  <div class="blog-stat">
    <div class="blog-stat-num">5W</div>
    <div class="blog-stat-label">Idle draw</div>
  </div>
  <div class="blog-stat">
    <div class="blog-stat-num">£0</div>
    <div class="blog-stat-label">Monthly cost</div>
  </div>
</div>

The SMTP relay free tier covers far more emails per day than I send. The routing service is free. The Pi was already running. The only real cost is my time, and I have already spent it.
