---
title: "Welsh all the way down"
date: 2026-03-13T14:00:00+00:00
description: "Welsh runs through everything I build — navigation apps that speak it, websites that serve it, corpora that teach it to machines, and a toolkit that brings it to the desktop."
tags: ["welsh", "culture", "projects"]
---

<p class="blog-lead">I am a Welsh speaker. Not a heritage learner, not someone who did a Duolingo streak. Welsh is the language I grew up with, the language I think in when I am not concentrating, the language on street signs in the place I live. When I build software, Welsh goes in from the start — not as a translation layer bolted on later, but as a first-class citizen.</p>

## The thread

Every major project I work on has a Welsh dimension. Not because I set out to build Welsh software, but because I set out to build software that works for me, and I happen to be Welsh.

**llywio** — a delivery route optimisation app for iOS. The name is Welsh for "navigate." The app provides voice navigation in Welsh using iOS's built-in speech synthesiser (`AVSpeechSynthesizer` with the `cy-GB` voice). This was not a trivial addition. Mapbox's navigation SDK does not support Welsh. The workaround intercepts English-language instructions, translates them, and speaks them through the system voice. It works. It sounds slightly robotic. It is still better than hearing "Turn left onto Heol y Bont" pronounced by an English TTS engine that treats Welsh phonemes like a foreign language it once heard about in passing.

**gwefan** — this website. The name is Welsh for "website." The site is bilingual, built with Hugo's multi-language support. Welsh is the primary language (`cy`), English is the secondary (`en`). The nav, the slugs, the content structure — Welsh first, English alongside. The Welsh content is sparse right now because I write it myself (AI-generated Welsh is not good enough to publish), but the structure is ready for it.

**corpws-chris** — a Welsh language corpus for AI training. A collection of Welsh text, cleaned and formatted, intended to improve Welsh language support in large language models. The project exists because Welsh is underrepresented in training data, and every Welsh speaker who interacts with AI tools notices the consequences: awkward grammar, anglicised word order, mutations that are wrong or missing entirely.

**cymraeg-os** — a Welsh productivity layer for desktop operating systems. Still early, written in Rust. The goal is keyboard layout detection, Welsh spellcheck integration, and system-level language defaults that make Windows, macOS, and Linux work properly in Welsh. "Properly" means: the keyboard produces circumflexes without dead-key sequences, the spellchecker knows that "ysgol" is not a misspelling of "school," and the date format says "Mawrth" not "March."

## Why it is hard

Welsh has about 880,000 speakers. That is enough for a living language with literature, media, education, and daily use. It is not enough for software localisation to happen automatically.

Here is what "not enough" looks like in practice:

- **Voice assistants** do not speak Welsh. Siri, Alexa, and Google Assistant have no Welsh language models.
- **Spellcheckers** are patchy. LibreOffice has a Welsh dictionary. Microsoft Word's is limited. Browser spellcheck has none.
- **Keyboards** are awkward. Welsh uses â, ê, î, ô, û, ŵ, ŷ — vowels with circumflexes (to bach). On most keyboard layouts, typing these requires dead-key sequences or memorised alt codes. The UK Extended layout helps but is not the default on any platform.
- **AI models** handle Welsh poorly. They generate plausible-looking text with incorrect mutations, English-influenced syntax, and vocabulary gaps. A Welsh speaker can tell immediately. A non-speaker cannot, which is worse.

None of these are unsolvable problems. They are neglected problems. The solutions exist — better training data, proper keyboard layouts, voice models — but they are not priorities for companies whose Welsh-speaking user base rounds to zero percent.

<blockquote class="blog-pullquote">If you want software that works in your language, sometimes you have to build it yourself.</blockquote>

## What I am actually doing about it

I am not building a Welsh Siri. I am not competing with Google Translate. I am doing the small, specific things that make my own computing experience work in Welsh:

- **Voice navigation** that pronounces place names correctly
- **A website** that serves Welsh content to Welsh-speaking visitors
- **A text corpus** that gives AI models better Welsh training data
- **A desktop toolkit** that makes the operating system feel less hostile to the language

Each of these is a weekend project, not a startup. Each solves a problem I personally have. The cumulative effect is a computing environment where Welsh is not an afterthought.

## The name thing

Most of my projects have Welsh names. gwefan (website), llywio (navigate), cymraeg (Welsh language), corpws (corpus). Some people find this confusing. I find it natural. The names are descriptive in the language I think in. If you needed to look up what "llywio" means, you now know — and you will not forget it.

There is a quiet political dimension to naming software in Welsh. It normalises the language in a space — technology — where it is almost entirely absent. I do not make a fuss about it. The names are just there, alongside English documentation and bilingual interfaces. Welsh all the way down, without asking permission.
