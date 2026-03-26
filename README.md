# 🎬 Teleprompter

A minimal, distraction-free teleprompter for macOS. Built for creators who need their script scrolling cleanly below the camera.

![macOS](https://img.shields.io/badge/macOS-12%2B-black?style=flat-square&logo=apple)
![Swift](https://img.shields.io/badge/Swift-5.9-orange?style=flat-square&logo=swift)
![License](https://img.shields.io/badge/license-MIT-green?style=flat-square)

---

## Features

- **Paste or type** your script and hit Start
- **Smooth 60fps scrolling** with adjustable speed
- **Adjustable font size** on the fly during playback
- **Three text colors** — White, Yellow, Green
- **Fade overlays** at top and bottom for a professional look
- **Full keyboard-friendly controls** — Play/Pause, Faster, Slower, Restart, Back
- Dark UI designed to stay out of your way

## Requirements

- macOS 12 Monterey or later
- Apple Silicon or Intel Mac

## Build & Run

```bash
git clone https://github.com/Dioscurias/Teleprompter.git
cd Teleprompter
make run
```

No Xcode required. Builds with the Swift compiler included in Xcode Command Line Tools.

> Install Command Line Tools if needed: `xcode-select --install`

## Usage

1. **Edit screen** — paste your script, choose text color, set speed and font size
2. Press **Start**
3. In the teleprompter view, use the control bar at the bottom:
   | Button | Action |
   |--------|--------|
   | ▶ Play / ⏸ Pause | Start or pause scrolling |
   | Faster / Slower | Adjust scroll speed |
   | A+ / A− | Increase or decrease font size |
   | ↺ | Restart from the top |
   | ← Back | Return to the editor |

## Project Structure

```
Sources/
  main.swift               — entry point
  AppDelegate.swift        — window & menu setup
  EditViewController.swift — script editor screen
  PromptViewController.swift — teleprompter display
Resources/
  Info.plist
  AppIcon.icns
Scripts/
  make_icon.swift          — generates the app icon
Makefile                   — build system
```

---

A tool by [Nikoloz Sharvashidze](https://github.com/Dioscurias)
