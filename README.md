<div align="center">

# 🔢 NumQuest v2

### *Can you crack the secret number?*

![Flutter](https://img.shields.io/badge/Flutter-3.0%2B-02569B?style=for-the-badge&logo=flutter&logoColor=white)
![Dart](https://img.shields.io/badge/Dart-3.0%2B-0175C2?style=for-the-badge&logo=dart&logoColor=white)
![SQLite](https://img.shields.io/badge/SQLite-sqflite-003B57?style=for-the-badge&logo=sqlite&logoColor=white)
![Platform](https://img.shields.io/badge/Platform-Android-3DDC84?style=for-the-badge&logo=android&logoColor=white)

<br>

> **A beautifully crafted, dark-themed Flutter number guessing game**  
> featuring SQLite persistence, smart AI-style hints, scoring, streaks & silky-smooth animations.

<br>

---

**👨‍💻 Muhammad Talha** &nbsp;|&nbsp; **📋 SP23-BCS-086** &nbsp;|&nbsp; **📚 Lab Assignment 02 — Flutter Mobile Development**

---

</div>

<br>

## 📱 App Screens

| Home | Game | Result | History |
|:---:|:---:|:---:|:---:|
| Difficulty picker + quick stats | Live input, smart range, lives | Score, grade & guess trail | Sessions list + stats dashboard |

<br>

---

## ✨ Features

### ✅ Assignment Requirements

| Requirement | Status |
|---|:---:|
| Random number generation (Math.Random) | ✅ |
| Input validation — empty, non-numeric, out-of-range | ✅ |
| Feedback — Correct / Too High / Too Low | ✅ |
| SQLite database storing all attempts | ✅ |
| Home Screen (game entry point) | ✅ |
| Result Screen (win / lose outcome) | ✅ |
| History Screen (full SQLite data view) | ✅ |
| Runs on Android device / emulator | ✅ |

<br>

### 🚀 Extra Features

```
🌑  Deep dark violet/purple aesthetic — premium feel, no plain black
🎮  3 Difficulty Levels → Rookie (1–50) · Hunter (1–100) · Legend (1–999)
🧠  Smart Range Hint — live narrowing range using binary-search logic
❤️  Lives System — animated glowing dots, color shifts as lives drop
⚡  Score System — based on difficulty, attempts used & lives remaining
📊  Letter Grade (S / A / B / C / D) — performance-based grading
🔥  Win Streak Tracking — current streak & all-time best streak
🎉  Floating particle animation on win screen
💀  Skull + bounce animation on loss screen
👆  Swipe-to-delete sessions in history
📈  Stats dashboard — circular win rate, bar charts, 6-tile stat grid
✨  Page transitions with slide, fade & scale animations
📳  Haptic feedback on every meaningful interaction
```

<br>

---

## 🗂 Project Structure

```
numquest/
│
├── lib/
│   │
│   ├── main.dart                    ← App entry point, Provider setup, theme
│   │
│   ├── utils/
│   │   ├── theme.dart               ← Colors, TextStyles, Difficulty config
│   │   └── game_ctrl.dart           ← Game logic (ChangeNotifier state)
│   │
│   ├── models/
│   │   └── models.dart              ← GameAttempt · GameSession · AppStats
│   │
│   ├── db/
│   │   └── database_helper.dart     ← SQLite CRUD singleton (DB)
│   │
│   ├── widgets/
│   │   └── widgets.dart             ← NeonCard · GradBtn · GuessBubble · LivesRow …
│   │
│   └── screens/
│       ├── home_screen.dart         ← Menu — difficulty picker, quick stats
│       ├── game_screen.dart         ← Active game — input, hints, lives bar
│       ├── result_screen.dart       ← Win / Lose result, score & grade
│       └── history_screen.dart      ← Sessions list + full stats dashboard
│
└── pubspec.yaml
```

<br>

---

## 🗄️ Database Schema

> Powered by **sqflite** — two tables, fully relational.

### 📋 Table: `attempts`

| Column | Type | Description |
|---|---|---|
| `id` | INTEGER PK | Auto-increment primary key |
| `sessionId` | TEXT | Links this attempt to a session |
| `attemptNo` | INTEGER | 1, 2, 3 … within the session |
| `guessed` | INTEGER | The number the user entered |
| `target` | INTEGER | The secret number |
| `result` | TEXT | `correct` · `high` · `low` |
| `timestampMs` | INTEGER | Unix timestamp in milliseconds |

<br>

### 📋 Table: `sessions`

| Column | Type | Description |
|---|---|---|
| `id` | INTEGER PK | Auto-increment primary key |
| `sessionId` | TEXT UNIQUE | Unique ID per game session |
| `target` | INTEGER | The secret number |
| `totalAttempts` | INTEGER | Total guesses made |
| `won` | INTEGER | `1` = won · `0` = lost |
| `difficulty` | TEXT | `Rookie` · `Hunter` · `Legend` |
| `startMs` | INTEGER | Session start timestamp |
| `endMs` | INTEGER | Session end timestamp |

<br>

---

## 📦 Dependencies

| Package | Version | Purpose |
|---|---|---|
| `sqflite` | ^2.3.0 | SQLite database engine |
| `path` | ^1.9.0 | Database file path resolution |
| `provider` | ^6.1.1 | Reactive state management |
| `intl` | ^0.19.0 | Date & time formatting |

<br>

---

## 🚀 How to Run

### Prerequisites
- ✅ Flutter SDK **≥ 3.0.0**
- ✅ Android device or emulator connected
- ❌ Flutter Web **not supported** (`sqflite` is Android/iOS only)

<br>

### Steps

```bash
# 1. Navigate to project folder
cd numquest

# 2. Install all dependencies
flutter pub get

# 3. Run on connected Android device or emulator
flutter run
```

> 💡 **Tip:** Run `flutter devices` to see all available targets before running.

<br>

---

## 🎮 How to Play

```
1.  Open the app                  →  You land on the Home screen
2.  Pick a difficulty             →  Rookie · Hunter · Legend
3.  Tap  🚀 Start Game           →  Game begins!
4.  Type a number & press Send    →  Get instant feedback
5.  Read the hint                 →  📉 Too High  ·  📈 Too Low  ·  🎯 Correct!
6.  Watch the Smart Range         →  It narrows after every guess
7.  Win before lives run out      →  Earn a Score + Letter Grade
8.  All results auto-saved        →  Check 📜 History anytime
```

<br>

---

## 🏆 Scoring System

| Factor | Effect on Score |
|---|---|
| Difficulty max range | Higher range = higher base score |
| Lives remaining | More lives left = big bonus |
| Total attempts used | Fewer guesses = less penalty |
| Grade (S→D) | Attempts ÷ Lives ratio |

```
Score = (difficulty.max × 10) + (livesLeft × 50) − (attempts × 20)
Minimum: 100 pts  ·  Maximum: unlimited
```

<br>

---

<div align="center">

## 👨‍💻 Developer

<br>

**Muhammad Talha**

📋 Registration No: **SP23-BCS-086**

📚 Lab Assignment 02 — Flutter Mobile Development

📅 Due: April 30, 2026

<br>

---

*Built with ❤️ using Flutter & Dart*

</div>