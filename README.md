# Clicker — tally counter for Garmin

*Читать на [русском](README_ru.md).*

A simple Garmin watch app (Connect IQ / Monkey C) that works as a handheld tally
clicker: count people, objects, reps, etc.

## Features

- **+1** — press the main watch button (START/SELECT), or tap the screen on
  touch models. Every press plays the watch's system sound
  (`Attention.TONE_KEY`).
- **Reset to 0** — long-press the menu button (MENU / hold UP) shows a
  confirmation dialog; choosing "Yes" zeroes the counter.
- The current value is saved in `Application.Storage`, so it survives leaving the
  app or rebooting the watch.

Controls: `onSelect` / `onTap` → +1, `onMenu` → reset (see
[`source/ClickerDelegate.mc`](source/ClickerDelegate.mc)).

## Project structure

```
manifest.xml                     app description and device list
monkey.jungle                    build configuration
source/ClickerApp.mc             entry point (AppBase)
source/ClickerView.mc            counter rendering + value storage
source/ClickerDelegate.mc        button/tap handling, sound, reset
resources/strings/strings.xml    strings (eng)
resources-rus/strings/...        strings (rus)
resources/drawables/...          app icon
```

---

## 1. Set up the environment

1. Install the **Connect IQ SDK Manager**:
   <https://developer.garmin.com/connect-iq/sdk/>
   Use it to download the latest SDK and the device images (Devices).
2. Install **VS Code** and the **Monkey C** extension (published by Garmin) — it
   provides build/run commands and syntax highlighting.
3. Generate a **developer key** (one-time) — it is required to sign the app:

   ```bash
   openssl genrsa -out developer_key.pem 4096
   openssl pkcs8 -topk8 -inform PEM -outform DER \
       -in developer_key.pem -out developer_key -nocrypt
   ```

   Pass the resulting `developer_key` file to the build commands (the `-y` flag).

Make sure the SDK tools (`monkeyc`, `monkeydo`, `connectiq`) are on your `PATH`
(the SDK Manager usually puts them in `~/.Garmin/ConnectIQ/Sdks/<version>/bin`).

---

## 2. Run in the simulator

### Via VS Code (easiest)

1. Open the project folder in VS Code.
2. `Ctrl/Cmd + Shift + P` → **Monkey C: Build for Device** (pick a device, e.g.
   `fenix7`) — the extension will ask for the developer key on first run.
3. `Ctrl/Cmd + Shift + P` → **Monkey C: Run App** — builds the project, launches
   the simulator, and installs the app into it. Press `F5` to run with debugging.

### Via the command line

```bash
# 1. build a .prg for a specific device
monkeyc -d fenix7 -f monkey.jungle -o bin/clicker.prg -y developer_key

# 2. start the simulator (separate window, leave it running)
connectiq

# 3. install and run the app in the simulator
monkeydo bin/clicker.prg fenix7
```

In the simulator the buttons are emulated with the mouse/keyboard; on touch
devices a click on the screen works. The simulator menu (Simulation → ...) lets
you check the sound and button behavior.

---

## 3. Install on your own watch (sideload)

1. Build a `.prg` for the exact model of your watch (see the id list in
   [`manifest.xml`](manifest.xml)):

   ```bash
   monkeyc -d fenix7 -f monkey.jungle -o bin/clicker.prg -y developer_key
   ```

2. Connect the watch to the computer with a USB cable — it mounts as a storage
   device (`GARMIN`).
3. Copy `bin/clicker.prg` into the **`GARMIN/APPS`** folder on the watch
   (on some models it is `Garmin/Apps`).
4. Safely eject the watch. The app will appear in the list of Connect IQ apps /
   activities.

> Sideloading is fine for personal testing. An app built with your developer key
> runs on your watch without publishing to the store.

---

## 4. Publish to the Garmin Connect IQ Store

1. Build the **`.iq` package file** (it bundles builds for every device in the
   manifest):

   ```bash
   monkeyc -e -f monkey.jungle -o bin/clicker.iq -y developer_key
   ```

   The VS Code equivalent: **Monkey C: Export Project**.

2. Register a developer account and sign in to the dashboard:
   <https://apps.garmin.com/developer/dashboard>
3. Click **Upload an App** and upload `bin/clicker.iq`.
4. Fill in the app listing: name, description, category, screenshots (you can
   capture them in the simulator), and the store icon.
5. Submit for review. After Garmin approves it, the app becomes available to
   users in the Connect IQ Store / the Garmin Connect app.

### Useful before publishing

- Check that `manifest.xml` lists every device you want to support and that the
  app builds for each of them.
- Run a type check: `monkeyc ... -l 3` (strict type-check) helps catch errors
  before uploading.
- Garmin takes the app version from the uploaded `.iq`; to update, upload a new
  `.iq` to the listing again.
