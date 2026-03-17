---
title: "Emailing a bakery for carb data"
date: 2026-03-05T18:00:00+00:00
description: "I emailed Jenkins Bakery in Swansea to ask for the carbohydrate content of a corned beef pasty. They replied. The data went into islet's food template system."
tags: ["islet", "diabetes", "self-hosting"]
---

<p class="blog-lead">The hardest part of carbohydrate counting is not the maths. It is the data. Supermarket food has labels. Restaurant food has menus with calorie counts. But the pasty from the bakery on your high street — the one you have been buying for years — has nothing. You guess. You are always wrong.</p>

## The problem

islet has a food template system. When you log a meal, it checks the description against a library of known foods and returns an instant carbohydrate estimate without needing an AI call. The library covers packaged foods with published nutritional data — Tunnock's Caramel Wafers, Penguin bars, sliced bread by brand and thickness.

But the foods I eat most often are not packaged. They are from local bakeries, takeaways, and the cafe by the docks. The nutritional data does not exist online. Nobody has entered "Jenkins Bakery corned beef pasty" into MyFitnessPal with any accuracy. The template system had a gap exactly where it mattered most.

## The email

I emailed Jenkins Bakery. From my self-hosted mail server. To their public address.

The email was short: I have Type 1 diabetes, I buy your pasties regularly, I need the carbohydrate content per pasty to dose insulin correctly. Do you have nutritional information you can share?

They replied the next day with a spreadsheet attached. Carbohydrates per 100g for their main product range. Not per portion — but weighing a pasty once and doing the maths is a solved problem.

<blockquote class="blog-pullquote">Sometimes the best data pipeline is an email.</blockquote>

## The loop

The data from Jenkins went into islet as a food template entry. Now when I log "corned beef pasty" the system returns an instant estimate based on the bakery's own figures — not a guess, not an AI approximation, not a generic "pasty" entry from a crowd-sourced database.

The full loop looks like this:

1. I eat a pasty
2. I tell islet "corned beef pasty, Jenkins"
3. islet matches the template, returns the carb count
4. glucore factors the carbs into its COB model and forward prediction
5. The iOS app shows the predicted glucose trajectory

Step 3 used to be a 2-second AI call that returned a rough estimate. Now it is a local lookup that returns the manufacturer's data in under a millisecond.

## Why this matters

Every Type 1 diabetic has a mental library of carb values. You know that a slice of Hovis wholemeal is about 17g because you have read the packet a hundred times. You know that a banana is somewhere between 20g and 30g depending on size. You learn the numbers for the foods you eat repeatedly.

The food template system is that mental library made explicit. Instead of remembering that the Jenkins pasty is "probably about 35g" and being wrong by 10g either way, the system stores the real number. Over time, the library grows to cover the foods that actually appear in your diet — not the foods that appear in generic databases.

The interesting thing is that the data source varies. Some entries come from packet labels (photographed and transcribed). Some come from manufacturer websites. Some come from emailing a bakery in Swansea and asking nicely.

## The self-hosting angle

The email went out through Stalwart, my mail server running on the same Raspberry Pi that runs islet. It was relayed through Brevo's SMTP service for deliverability. The reply came back through Cloudflare's email routing into the same Stalwart instance.

There is something satisfying about the circularity: the Pi that processes my glucose data also sent the email that produced the carb data that improves the glucose processing. One box, one person's infrastructure, doing a small useful thing.

<div class="post-note">If you are a small food business and a diabetic customer asks for nutritional data — please share it if you have it. It costs nothing and it matters more than you might think.</div>
