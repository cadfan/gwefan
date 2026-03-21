---
title: "Pwyslais"
date: 2026-03-21T00:02:00+00:00
description: "A journal that asks the questions, because I never will."
tags: ["pwyslais", "development", "personal"]
---

<p class="blog-lead">I am never going to open a journal app and write "today this happened." I know this about myself with absolute certainty. Every journaling app I have tried &mdash; Day One, Notion, Apple Journal, plain text files &mdash; assumes the user will voluntarily sit down and compose an entry. That assumption is the entire reason they fail for me. pwyslais starts from the opposite premise: I will not write unless something asks me to.</p>

## The name

Pwyslais is Welsh for emphasis &mdash; from *pwys* (weight, importance) and *llais* (voice). The system puts weight on what matters and gives it a voice. It emphasises the things your brain skips over: the threads you dropped, the patterns you cannot see, the commitments you made and forgot. It started life as *dyddiadur* (diary), but a diary waits for you to write. This does not wait.

## The input problem

The hard part of a journal is not storing entries. It is not searching them or analysing them. The hard part is getting anything into the system at all.

If you have ADHD, a blank text field is not an invitation. It is a wall. You open the app, see an empty page, think "I should write something," fail to think of what, and close the app. This happens every time. The cognitive load of deciding what to say is enough to prevent you from saying anything.

Pwyslais inverts the relationship. When you open the app, it asks you a question. Not a generic "how was your day" prompt &mdash; a specific, contextual question assembled from what it already knows about your life. If you mentioned a meeting every Wednesday for the last three weeks, the Wednesday morning nudge references that. If you said you needed to phone the dentist and never mentioned it again, the nudge surfaces it. If your mood has been dropping since Tuesday, it notices.

The system does the cognitive work of figuring out what to talk about. You just answer.

<blockquote class="blog-pullquote">A blank page is a wall. A question is a door.</blockquote>

## How the nudge engine works

Every time you open pwyslais, it calls Claude with your recent context: the last few days of entries, any open threads you never resolved, detected patterns, your current mood trajectory, and the time of day. Claude generates a single nudge &mdash; an observation, a question, a gentle reminder, or sometimes nothing at all. The nudge is live, never pre-generated. A cached prompt feels robotic. A live one feels like talking to someone who actually remembers your life.

There is a three-minute cooldown. If you close and reopen the app, you get a fresh nudge. If Claude is slow or unreachable, a library of around thirty bilingual prompts provides the fallback &mdash; time-aware, language-matched, but not contextual. The fallback is good enough to prompt writing. The live nudge is good enough to prompt honest writing.

The prompts are bilingual. If you have been writing in Welsh, the nudge comes in Welsh. If in English, English. No toggle, no setting. It matches what you have been doing.

## The conversation loop

A nudge gets you to write something. But pwyslais does not stop there.

Within a minute of saving an entry, the system processes it in the background. Claude extracts entities &mdash; people, places, projects, emotions, health markers &mdash; and files them into a knowledge graph. A mood badge appears on the entry. Entity tags fade in below the text. The entry is no longer just text. It is structured knowledge the system can reason about.

Then, sometimes, a follow-up question arrives. Delivered via server-sent events, it appears as an indented card below your entry. If you mentioned something stressful in passing, it might ask "want to say more about that?" If your entry was very short, it nudges you to expand. If you mentioned someone for the first time, it asks for context.

This is the loop: nudge &rarr; entry &rarr; extraction &rarr; follow-up &rarr; entry &rarr; extraction. Each turn teaches the system more about your life, which makes the next nudge more relevant, which makes you more likely to respond. The system compounds.

<blockquote class="blog-pullquote">Each turn teaches the system more, which makes the next nudge more relevant, which makes you more likely to respond.</blockquote>

## What it remembers

Behind the conversation loop, the intelligence layer builds a persistent model of your life.

**Entities** accumulate with context and sentiment. The system knows that you mentioned your mother twelve times this month, mostly positively. It knows you mentioned a work deadline six times with increasing anxiety. It tracks first-seen and last-seen dates, mention frequency, and the contexts in which things appear.

**Patterns** emerge from thirty-day scans. If tiredness shows up every Wednesday, the system detects and scores it. Stale patterns deactivate automatically.

**Threads** track things you said you would do. The resolution logic is deliberately conservative &mdash; a vague "had a busy day" does not close a thread about phoning the bank. Only explicit confirmation does. The system would rather nag you about something you already did than let something important slip.

**Weekly reports** land in my inbox every Sunday evening. Claude Opus writes a retrospective covering the week's entries, patterns, mood trends, open threads, and anything notable. The report arrives whether I remember to check the app or not. This is the external memory function &mdash; a summary of my own life that I did not have to compile.

## Why even this is not enough

The nudge engine helps. A contextual question is better than a blank page. But it still requires me to open an app and type. That is still a conscious decision to journal, and for some types of neurodivergent brain, any amount of conscious effort is too much on the wrong day.

The long-term answer is that pwyslais should not depend entirely on me writing. It should be able to learn from what I am already doing. islet already knows what I ate, when my glucose spiked, and how I slept. llywio knows where I drove and which stops I made. My calendar knows what meetings I had. My phone knows where I was.

If pwyslais can pull from those systems in the background, the journal starts filling itself. Not as a complete record &mdash; it still needs my voice for the things that matter &mdash; but as a scaffold. When I open the app and the nudge says "you had a high glucose spike after lunch and drove to Neath &mdash; rough afternoon?" it is not asking me to recall my day from scratch. It already has the shape of my day. I just need to colour it in.

That is the difference between a journal and an external memory system. A journal asks you to remember. An external memory system already remembers, and asks you to reflect.

<blockquote class="blog-pullquote">A journal asks you to remember. An external memory system already remembers, and asks you to reflect.</blockquote>

## Where it stands

<div class="blog-stat-row">
  <div class="blog-stat">
    <div class="blog-stat-num">76</div>
    <div class="blog-stat-label">Commits</div>
  </div>
  <div class="blog-stat">
    <div class="blog-stat-num">180</div>
    <div class="blog-stat-label">Tests</div>
  </div>
  <div class="blog-stat">
    <div class="blog-stat-num">12</div>
    <div class="blog-stat-label">Intelligence tables</div>
  </div>
</div>

The core journal works. The intelligence layer is largely built &mdash; entity extraction, pattern detection, thread tracking, nudges, follow-ups, weekly reports. 180 tests passing. Some merge cleanup and client integration remain.

But the input story is not finished. Right now, the only way to write is text. That is already a friction point. The roadmap includes voice capture via on-device transcription, photo-with-caption entries, and quick mood reactions that require no typing at all. Each removes a barrier between having a thought and getting it into the system.

The name changed because the project did. What started as a diary became something else &mdash; a system that puts emphasis on the parts of your life you would otherwise lose. Pwyslais does not wait for you to write. It asks. It follows up. It remembers what you said last week and uses it to ask better questions this week. And eventually, if the compounding works, it knows your life well enough that opening the app feels less like journaling and more like catching up with someone who has been paying attention.
