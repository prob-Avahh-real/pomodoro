# Pomodoro

A Pomodoro timer app for iOS/macOS built with SwiftUI.

## Features

- Focus timer with configurable intervals
- Short and long break management
- 5 sound themes (Anime, Funny, Cat, Retro, Gentle)
- Synthesized sound engine — no external audio files
- Haptic feedback
- Local notifications

## Tech Stack

- **Language:** Swift 5.9
- **Framework:** SwiftUI
- **Platform:** iOS 17+ / macOS 14+
- **Audio:** AVFoundation (AVAudioEngine)

## Project Structure

```
Sources/Pomodoro/
  Engine/      — Sound engine (AVAudioEngine synthesis)
  Models/      — Timer data models and settings
  ViewModels/  — PomodoroViewModel (ObservableObject)
  Views/       — Timer UI and Settings view
Tests/PomodoroTests/
```

## Development

```bash
# Build
swift build

# Test
swift test

# Lint
swiftlint

# Generate Xcode project
xcodegen
```
