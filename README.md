# 🎯 Tap Rush 2.0

**Tap Rush 2.0** is a fast-paced, interactive tapping game built with **Flutter**. Tap the moving target before time runs out, challenge yourself across three difficulty levels, and try to beat your personal best!

> **Current platform:** Android. The Flutter game code can also be used for iOS, but an iOS build has not yet been tested or released.

## ✨ Features

- 🎮 **Three difficulty levels:** Easy, Medium, and Hard, each with different round durations, target sizes, and movement speeds.
- 🎯 **Moving target:** Tap the animated target to earn points.
- ⏱️ **Countdown timer:** Race against the clock to maximize your score.
- ⏸️ **Game controls:** Start, pause, resume, restart, or end a round early.
- 🔊 **Sound effects:** Hear feedback when you hit the target, with an on/off toggle and a **Test Sound** button.
- 📳 **Haptic feedback:** Optional vibration when tapping targets, plus a **Test Vibration** button (device support varies).
- 🏆 **Personal best scores:** High scores are stored locally for each difficulty using `shared_preferences`.
- 🌙 **Dark gaming interface:** A colorful target and a clean, dark-themed layout.
- 📱 **App lifecycle support:** Automatically pauses gameplay when the app goes into the background.

## 🛠️ Tech Stack

| Technology | Purpose |
| --- | --- |
| Flutter & Dart | Game UI, animations, and gameplay logic |
| `audioplayers` | Tap sound effects |
| `shared_preferences` | Local high score storage |
| Flutter `HapticFeedback` | Device vibration / haptic feedback |

## 🚀 Getting Started

### Prerequisites

- Flutter SDK installed and configured
- Android Studio or VS Code with Flutter/Dart extensions
- An Android device or emulator

Check your environment:

```bash
flutter doctor
```

### Installation

1. Clone the repository:

   ```bash
   git clone https://github.com/YOUR_USERNAME/tap-rush-flutter.git
   cd tap-rush-flutter
   ```

2. Install dependencies:

   ```bash
   flutter pub get
   ```

3. Run the game:

   ```bash
   flutter run
   ```

> Replace `YOUR_USERNAME` with your GitHub username, or use your repository's actual clone URL.

## 📦 Build an Android APK

To generate a release APK:

```bash
flutter build apk --release
```

The generated file will be at:

```text
build/app/outputs/flutter-apk/app-release.apk
```

You can transfer this APK to a compatible Android phone for installation. Public distribution may require additional signing and release configuration.

## 🕹️ How to Play

1. Launch **Tap Rush 2.0**.
2. Choose **Easy**, **Medium**, or **Hard**.
3. Tap **Start Game**.
4. Tap the moving target as many times as possible before the timer reaches zero.
5. Use **Pause / Resume** to take a break, or **Restart / End Game** to control your round.
6. Try to beat your saved best score for each difficulty!

Use the sound and vibration icons to turn feedback on or off. You can test each feature from the menu before starting a round.

## 📁 Project Structure

```text
tap-rush-flutter/
├── android/                 # Android platform project
├── assets/
│   ├── sounds/
│   │   └── tap.wav          # Tap sound effect
│   └── images/              # Optional app icon / artwork
├── lib/
│   └── main.dart            # Main game UI and logic
├── pubspec.yaml             # Flutter dependencies and assets
└── README.md
```

> The `assets/images/` directory is only needed if you have added custom artwork or a launcher icon.

## 🔧 Troubleshooting

**Sound not playing?**

- Check that `assets/sounds/tap.wav` exists.
- Ensure the Flutter assets section in `pubspec.yaml` includes `assets/sounds/`.
- Run `flutter pub get` and rebuild the app.
- Check the phone's media volume and the game's sound toggle.

**No vibration?**

- Enable vibration in the game's top-right control.
- Try **Test Vibration**.
- Check your phone's haptic feedback settings. Haptic intensity varies by device.

## 🔮 Future Improvements

- 🍎 Build and test an iOS version using the same Flutter codebase
- 🎨 Additional visual effects and polish
- 🏅 More achievements and gameplay challenges

## 🤝 Contributions

Suggestions, bug reports, and pull requests are welcome. Please open an issue to discuss larger changes before submitting them.

---

**Built with Flutter 💙 — Tap fast. Score big.**
