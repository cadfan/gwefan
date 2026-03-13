---
title: "A follower app in a week"
date: 2026-03-07T00:30:00+00:00
description: "Building an Android follower app for islet — a read-only CGM dashboard for family members who want to see glucose data without managing diabetes."
tags: ["islet", "android", "kotlin"]
---

<p class="blog-lead">The iOS app is for the person wearing the sensor. The Android app is for everyone else. My partner checks my glucose when I am asleep or driving. She does not need meal logging, prediction charts, or food templates. She needs a number, a trend arrow, and a colour that tells her whether to worry.</p>

## Different user, different app

islet's iOS companion is a tool for managing diabetes — food logging, AI-assisted carb estimation, treatment input, prediction overlays. It is complex because the problem is complex. But a follower does not need any of that. A follower needs:

- Current glucose value, large and readable
- Trend direction
- A chart showing recent history
- A clear signal when data is stale

That is the entire scope. No write operations. No meal logging, no treatments, no settings beyond connection configuration.

## Kotlin and Compose

The app is built with Jetpack Compose and targets a single screen — a follower dashboard. The glucose value dominates the layout. The trend arrow uses the same directional mapping as the iOS app. The colour system matches: cold indigo for low, green for in-range, warm amber through red for rising highs.

The chart is a custom Canvas composable — not a library. It draws the same segmented glucose line as the iOS SwiftUI chart, with colour transitions at the same thresholds. A cursor scrubber lets you drag across the chart to inspect historical values. Duration picker toggles between 3-hour, 6-hour, 12-hour, and 24-hour windows.

Below the chart, an expandable log shows recent meals and treatments — read-only, pulled from the same API.

## Auto-configuration

Setup is one field: the islet server URL. The app validates the connection by hitting the health endpoint, confirms it gets a valid response, and saves the configuration.

On launch, the app checks for a saved configuration and either shows the dashboard or the setup screen. No onboarding wizard, no tutorial, no permissions dialogs.

<blockquote class="blog-pullquote">The best setup experience is no setup experience.</blockquote>

## Quality pass

The initial scaffold went from zero to working dashboard in two sessions. The third session was a quality pass: detekt for static analysis, dead code removal, test expansion from the initial smoke tests to 66 unit tests covering chart data preparation, glucose zone classification, staleness detection, and direction arrow mapping.

The app moved from a top-level `android/` directory to `android-companion/` to make its role clear — this is not the future Android equivalent of the iOS app. It is a focused follower tool that may grow, but its identity is not "islet for Android." It is "islet for the people around the person with diabetes."

## What it costs

Around 2,700 Kotlin SLOC. One `build.gradle.kts`. No external charting library. No dependency injection framework. No architecture astronautics. The ViewModel talks to the API client, the Composables observe the state, the chart draws itself. It is the simplest thing that could work, and it does work.

The Warm Amber theme carries across from iOS — same dark background, same accent colour, same glucose range palette. A family member switching between checking the iOS app over someone's shoulder and checking the Android follower on their own phone sees the same visual language. That consistency was not accidental but it was also not expensive. A shared colour spec and a few hex values go further than a design system.
