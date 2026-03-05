<div align="center">

# ⚡ CodeBoy App

**A Flutter application for adaptive competitive programming practice, powered by AI.**

[![Flutter](https://img.shields.io/badge/Flutter-3.x-02569B?style=flat-square&logo=flutter)](https://flutter.dev/)
[![Dart](https://img.shields.io/badge/Dart-^3.11-0175C2?style=flat-square&logo=dart)](https://dart.dev/)
[![License](https://img.shields.io/badge/License-Private-red?style=flat-square)](#)

</div>

---

## 📖 Overview

**CodeBoy App** is the mobile/web front-end for the CodeBoy competitive programming platform. It connects to the **CodeBoy Server** and provides students with a clean interface to:

- Browse and solve **AI-generated CP problems** tailored to their rating
- Track their **performance history** with beautiful charts
- Manage their **profile and submission statistics**

The app is designed to integrate seamlessly with the **CodeBoy VS Code Extension**, where the actual code editing and submission happens.

---

## ✨ Features

| Feature | Details |
|---|---|
| 🏠 **Home Feed** | View active problem sessions and quick-start a new one |
| 📊 **Progress Charts** | Visualize performance over time with `fl_chart` |
| 🗓️ **Heatmap Calendar** | See your activity streak with a GitHub-style contribution calendar |
| 👤 **Student Profile** | View rating history, recent submissions, and statistics |
| 🔐 **Authentication** | Handle-based login with local persistence via `shared_preferences` |
| 📝 **Problem Viewer** | Read problem statements with full Markdown rendering |
| 💻 **Code Editor** | Built-in syntax-highlighted code editor with `flutter_code_editor` |

---

## 🛠️ Tech Stack

| Technology | Purpose |
|---|---|
| **Flutter + Dart** | Cross-platform UI framework |
| **flutter_bloc** | State management (BLoC pattern) |
| **get_it** | Dependency injection |
| **dio** | HTTP client for API requests |
| **fl_chart** | Performance charts |
| **flutter_heatmap_calendar** | Activity heatmap |
| **flutter_code_editor** | Syntax-highlighted code editor |
| **flutter_markdown** | Markdown rendering for problem descriptions |
| **shared_preferences** | Local handle/session persistence |
| **dartz** | Functional programming utilities (Either, Option) |

---

## ⚙️ Getting Started

### Prerequisites

- [Flutter SDK ^3.11](https://docs.flutter.dev/get-started/install)
- **CodeBoy Server running** at `http://localhost:3000` ([setup guide](https://github.com/Prince-Patel84/codeboy-server))

### Installation

```bash
git clone https://github.com/Prince-Patel84/codeboy-app.git
cd codeboy-app
flutter pub get
flutter run
```

> Run `flutter devices` to pick a target platform (web, Android, iOS, Windows).

---

## 🏗️ Architecture

The app follows a **clean, feature-driven architecture** with BLoC state management:

```
lib/
├── main.dart                    # App entry point
├── injection_container.dart     # Dependency injection setup (get_it)
│
├── core/                        # Shared utilities, constants, base classes
│
└── features/
    ├── auth/                    # Login / handle management
    ├── home/                    # Home feed, student model, active problem display
    └── profile/                 # Student profile, charts, submission history
```

### Key Design Patterns

- **BLoC / Cubit** — All UI states are driven by BLoC events and states
- **Repository pattern** — Data sources are abstracted behind repository interfaces
- **Dependency Injection** — `get_it` wires everything together at startup
- **dartz Either** — API errors are handled functionally with `Either<Failure, Success>`

---

## 🔌 Connecting to the Server

The app communicates with the **CodeBoy Server** for:

1. `GET /api/student/:handle` — Load student profile, rating, submission history
2. `POST /api/tutor/next-problem` — Fetch the next adaptive problem
3. `POST /api/session-result` — Report a solved/failed session

By default, the app expects the server at `http://localhost:3000`. To change this, update the base URL in your network/API configuration.

---

## 📊 Adaptive Difficulty

The platform uses an adaptive rating engine on the server side. Each completed problem session updates the student's practice rating based on:

- ✅ Whether the answer was Accepted
- ⏱️ How fast they solved it vs the time limit
- 💡 How many AI hints they requested

The app reflects this updated rating in the student profile and uses it to inform problem generation.

---

## 📝 Notes

- The app is designed to work **hand-in-hand** with the [CodeBoy VS Code Extension](https://github.com/Prince-Patel84/codeboy-vscode-extension) — the extension handles code editing and local execution, while the app provides profile management and progress tracking.
- Internet connectivity is required to communicate with the CodeBoy backend server.
