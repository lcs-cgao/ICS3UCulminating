# Preparing to Release on the App Store

Before archiving and submitting this app to the App Store, make one change to the project's Build Settings so that Xcode generates a dSYM file for your Release build. dSYM files allow App Store Connect to symbolicate crash reports — turning raw memory addresses into readable function names and line numbers, which makes debugging production crashes much easier.

## The change

1. In the Xcode project navigator, click the project name at the top (the blue icon).
2. Select your app target under **TARGETS**.
3. Click the **Build Settings** tab.
4. In the search field, type `Debug Information Format`.
5. Find the **Debug Information Format** row. It will show two values — one for Debug and one for Release.
6. Click the **Release** value and change it from **DWARF** to **DWARF with dSYM File**.

That's it. This change only needs to be made once per project.

## Why it's set to DWARF by default in this template

The template sets **Debug Information Format** to DWARF for all configurations. This prevents a warning and a slow simulator launch that would otherwise occur on every run during development. The tradeoff is that Release builds don't produce a dSYM by default — which is fine for day-to-day learning, but needs to be corrected before shipping.
