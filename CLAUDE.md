# CLAUDE.md

Guidance for working in this repository.

## Project overview

**Clicker** is a Garmin smartwatch app — a handheld tally counter (count people,
objects, reps). Written in **Monkey C** on the **Connect IQ SDK**
(compiler **9.1.0** at time of writing). App type is `watch-app`. The UI is a big
centered counter with two small on-screen markers pointing at the physical
buttons used for +1 and reset.

## Build / run / export

All commands run from the project root and need the `developer_key` (signing key).

```bash
# Build a .prg for one device (use any id from manifest.xml <iq:products>)
monkeyc -d fenix7 -f monkey.jungle -o bin/clicker.prg -y developer_key

# Run in the simulator: start the sim once (separate window), then load the .prg
connectiq
monkeydo bin/clicker.prg fenix7

# Export an all-device .iq package for the Connect IQ Store
monkeyc -e -f monkey.jungle -o bin/clicker.iq -y developer_key

# Strict type-check (recommended before publishing) — add -l 3
monkeyc -d fenix7 -f monkey.jungle -o bin/clicker.prg -y developer_key -l 3
```

The SDK tools (`monkeyc`, `monkeydo`, `connectiq`) live under
`~/Library/Application Support/Garmin/ConnectIQ/Sdks/<version>/bin` (macOS).

## Architecture

App → View → Delegate (standard Connect IQ split):

- **`source/ClickerApp.mc`** — `Application.AppBase`. `getInitialView()` returns
  `[view, delegate]` (a `ClickerView` + `ClickerDelegate`).
- **`source/ClickerView.mc`** — rendering and state. The count is persisted with
  `Application.Storage` under the key `"count"`, loaded in `initialize()`, saved
  on every change. `onUpdate()` draws the counter, the reset hint, and the button
  markers. The hint text and the left "reset" arrow switch based on
  `Capabilities.usesTouchReset()` (see below).
- **`source/ClickerDelegate.mc`** — input. `onSelect()` (main START/SELECT button)
  and `onTap()` (touchscreen) both do +1, play `Attention.TONE_KEY`, and `vibrate()`
  (a short `Attention.VibeProfile`, guarded by `Attention has :vibrate` and the
  user's `vibrateOn` setting). Reset is a `WatchUi.Confirmation` →
  `ResetConfirmationDelegate.onResponse()` (zeroes on `CONFIRM_YES`), triggered by
  `onMenu()` on button watches and by `onHold()` (screen long-press) on touch
  watches without a left button.
- **`source/Capabilities.mc`** — `module Capabilities` with `usesTouchReset()`:
  returns true for touch watches that lack an UP button (e.g. venu3, vivoactive6),
  via `DeviceSettings.isTouchScreen` + `inputButtons & BUTTON_INPUT_UP`. Both the
  view (which gesture to advertise) and the delegate (which gesture to handle) call
  it so they stay in sync. NOTE: vivoactive6 has no menu button at all, so the
  touch-reset path is the *only* way to reset there.

Resources:
- `resources/strings/strings.xml` — English strings (`AppName`, `ResetHint`,
  `ResetHintTouch`, `ResetPrompt`).
- `resources-rus/strings/strings.xml` — Russian strings (see quirk below).
- `resources/drawables/` — `drawables.xml` + `launcher_icon.png`, bitmap id `LauncherIcon`.

`manifest.xml`: version 3, `type="watch-app"`, `minApiLevel="3.1.0"`, ~69 products.
`monkey.jungle`: just `project.manifest = manifest.xml`.

## Project-specific gotchas

These cost real time in this project — check them first:

- **Device ids must match the installed SDK.** SDK 9.1.0 does **not** recognize
  `fenix6/6s/6x`, `venu/venu2/venu2s`, `vivoactive4/4s`, `fr245`, `fr945` —
  listing any of them fails the build with "Device ids ... not recognized".
  Cross-check against installed device images:
  `~/Library/Application Support/Garmin/ConnectIQ/Devices/`.
- **`type` must be `watch-app`** (hyphenated). `watchapp` fails with
  "Unknown app type".
- **`launcherIcon` is required** in `<iq:application>`. Removing it fails with
  "A launcher icon must be specified in the application manifest." Keep the pair:
  `launcherIcon="@Drawables.LauncherIcon"` ↔ `<bitmap id="LauncherIcon" .../>`.
- **App display name** comes from the `AppName` string resource (referenced as
  `name="@Strings.AppName"`), not from any manifest literal.
- **`dc.fillPolygon`** expects `Array<Array[Numeric, Numeric]>` (2-element point
  tuples). Do **not** cast points to `Array<Number>` — that fails type checking;
  let the literal infer its type.
- **Guard optional APIs**, e.g. `if (Toybox has :Attention) { ... }`, so the app
  still runs on devices/firmware that lack them.

## Known quirks

- **RU strings are not compiled in.** `manifest.xml` declares only
  `<iq:language>eng</iq:language>`, but `resources-rus/` exists. The Russian
  strings are therefore ignored at build time. To actually ship them, add
  `<iq:language>rus</iq:language>` to the manifest. (Left as-is intentionally.)
- App `id` is a 32-char hex string rather than a canonical hyphenated UUID. It
  builds and runs fine; no need to change it.

## Conventions

- **Never commit the signing key.** `developer_key` / `developer_key.pem` are
  gitignored and must stay out of version control — they are the identity used to
  publish and update the Store listing. If lost or leaked, you can't push updates
  to the same app.
- Use Monkey C type annotations (`import Toybox.Lang;` and `as Type` signatures),
  matching the existing files.
- Keep `resources/strings` and `resources-rus/strings` in sync (same string ids).
- Never edit anything under `bin/` — it is generated and gitignored.

## Docs

- API docs: https://developer.garmin.com/connect-iq/api-docs/
- Monkey C language overview: https://developer.garmin.com/connect-iq/monkey-c/
- Reference guides: https://developer.garmin.com/connect-iq/reference-guides/

## Possible future work

- Unit tests via Monkey C's test runner (`(:test)` functions,
  `monkeyc --unit-test` then `monkeydo <prg> <device> -t`).
- Periodically re-sync the `<iq:products>` list as the SDK adds/removes devices.
