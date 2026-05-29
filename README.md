# FukuJin

**Advanced window pinning and screen-monitoring automation for macOS.**

FukuJin is a macOS menu bar utility for power users who need to keep an eye on
background tasks without disrupting their primary workflow. It lets you tear off
and pin any application window as a persistent, customizable overlay, and can
watch the content of those windows with on-device OCR to trigger automated
actions.

---

## 🚀 Key Features

### 📌 Persistent Window Overlays (Pinning)

Never lose track of important background processes again. Select any live
application window and pin it to the front of your screen. Whether it's a
terminal running a long build, a chat window, or a video, the pinned window acts
as a Picture-in-Picture (PiP) overlay that stays visible no matter which app you
are using.

### 👁️ Text Watch (Real-Time OCR Automation)

Don't just watch your windows — let FukuJin watch them for you. Using efficient,
on-device optical character recognition (OCR), FukuJin continuously scans the
content of your pinned windows.

- **Keyword monitoring** — Set up rules to watch for specific words or phrases
  (e.g. `Build Succeeded`, `Error`, or a username in a chat).
- **Automated actions** — When the target text appears, FukuJin fires a
  notification so you can stay in deep work until your attention is actually
  needed.
- **Selectable recognition languages** — Pick which languages the OCR matches
  against from the 🌐 globe button in the settings window (multi-select, English
  by default). Your selection is persisted between launches.

> **Powered by Apple's built-in Vision framework.** OCR runs entirely on-device
> using macOS's standard text-recognition technology — no network access, no
> third-party services.

> **Tip for non-English matching.** Vision's accuracy is highest when it focuses
> on a single script. If matching in a non-English language (e.g. Japanese) is
> unreliable while English is also enabled, try narrowing the recognition
> languages down to **just that one language** — it often resolves the issue.
> Note that recognition of non-Latin scripts is inherently less accurate than
> English, especially for terminal/monospace fonts.

### 🎛️ Granular Overlay Controls

Tune the display of every pinned window independently so it never obstructs your
workflow:

- **Opacity control** — Make a pinned window semi-transparent so you can read or
  type in the window underneath while still keeping an eye on it.
- **FPS throttling** — Lower the capture frame rate. Perfect for mostly-static
  windows like terminals, drastically cutting CPU usage and saving battery while
  keeping the information fresh.

### ⚡ Seamless OS Integration & Focus Management

FukuJin is built to feel like a native part of macOS.

- **Menu bar access** — Unobtrusive by design; lives in the menu bar for quick
  access to pinned windows and configuration.
- **Smart window activation** — Clicking a pinned overlay instantly brings the
  original application window to the front and gives it focus, so you transition
  seamlessly from *monitoring* to *interacting*.

---

## 📋 Requirements

- **macOS 15 (Sequoia) or later**
- **Screen Recording** permission — required by ScreenCaptureKit to capture live
  window content.
- **Accessibility** permission — required to enumerate windows and bring the
  original app to the front on click.

FukuJin requests these permissions on first launch. Grant them under
**System Settings → Privacy & Security**.

---

## 📦 Install

The easiest way to install FukuJin is via [Homebrew](https://brew.sh) Cask:

```bash
brew tap s-age/fukujin
brew install --cask fukujin
```

The distributed `.app` is signed with a Developer ID certificate and notarized
by Apple, so it launches without Gatekeeper warnings.

---

## 🛠️ Build from source

FukuJin is a Swift Package Manager project (`swift-tools-version: 6.0`).

```bash
# Build (debug)
swift build

# Run the test suite
swift test

# Build a signed .app bundle and install it to /Applications
./Scripts/build.sh --install
```

`Scripts/build.sh` builds a release `.app` bundle with a Hardened Runtime and
code-signs it (falling back to an ad-hoc signature if no signing identity is
found). Useful options:

| Option        | Description                            |
|---------------|----------------------------------------|
| `--clean`     | Clean build artifacts before building  |
| `--test`      | Run tests before building              |
| `--install`   | Copy the bundle to `/Applications`     |
| `--no-sign`   | Skip code signing                      |
| `--skip-icon` | Skip icon generation                   |

Run `./Scripts/build.sh --help` for the full list.

---

## 📄 License

FukuJin is released under the [MIT License](LICENSE).
