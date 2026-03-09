# PopUpBot

[![한국어](https://img.shields.io/badge/lang-한국어-blue)](README_ko.md)

A lightweight native macOS menu bar app that opens a Telegram bot chat in a floating pop-up window via a global hotkey.

## Requirements

- macOS 14.0 (Sonoma) or later
- Swift 5.9+
- Telegram account (web login required on first launch)

## Build & Run

### Quick Start (development)

```bash
swift build -c release
.build/release/PopUpBot
```

### Create .app Bundle

```bash
./Scripts/build-app.sh
open build/PopUpBot.app
```

### Install

```bash
cp -r build/PopUpBot.app ~/Applications/
```

## Usage

1. On launch, a speech-bubble icon appears in the menu bar.
2. On first run, a settings dialog asks for your Telegram Bot API token and bot username.
3. Log in to Telegram Web (one-time).
4. Press **Option + Space** to toggle the pop-up chat window.

## Features

- **Global Hotkey** — Configurable shortcut (default `Option + Space`) to toggle the panel.
- **Floating Panel** — Always-on-top, resizable & draggable window positioned at the bottom-left.
- **Native Notifications** — Receive macOS notifications for incoming messages when the panel is hidden.
- **Zoom Control** — `⌘+` / `⌘-` / `⌘0` to adjust font size; persisted across sessions.
- **Settings Window** — Configure bot token and username via a dedicated settings UI.
- **Dismiss Shortcuts** — `Esc` or `⌘W` to close the panel; clicking outside also hides it.

## Menu Bar

- **Open/Close Chatbot** — Toggle the pop-up panel
- **Font Size** — Zoom in / out / reset
- **Change Shortcut** — Record a new global hotkey
- **Settings…** — Bot token & username configuration
- **Quit** — Exit the app

## Project Structure

```
Sources/PopUpBot/
├── main.swift                # App entry point
├── AppDelegate.swift         # App lifecycle management
├── HotKeyManager.swift       # Global hotkey (Carbon API)
├── PopUpPanel.swift          # Floating WebView panel & notifications
├── SettingsWindow.swift      # Bot credentials settings UI
└── StatusBarController.swift # Menu bar icon & menu
```

## License

MIT
