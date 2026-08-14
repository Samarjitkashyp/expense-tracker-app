# 💰 Expense Tracker — Flutter App

A clean, modern mobile app for tracking personal expenses and budgets, built with **Flutter**. It connects to the [Expense Tracker backend API](https://github.com/Samarjitkashyp/expense-tracker) for authentication, data storage, and analytics.

> 🔗 **Backend repository:** [github.com/Samarjitkashyp/expense-tracker](https://github.com/Samarjitkashyp/expense-tracker)

---

## ✨ Features

- 🔐 **Secure login & signup** with JWT authentication
- 🧾 **Add, edit & delete expenses** with categories, amounts, and dates
- 🏷️ **Categories** with custom colors and icons
- 📊 **Spending analytics** — visual breakdown by category with charts
- 💵 **Monthly budgets** and budget-vs-spending tracking
- 🔒 **Secure token storage** on the device

---

## 🛠️ Tech Stack

| Concern           | Package                                            |
| ----------------- | -------------------------------------------------- |
| Framework         | [Flutter](https://flutter.dev/)                    |
| State management  | [flutter_riverpod](https://pub.dev/packages/flutter_riverpod) |
| Networking        | [dio](https://pub.dev/packages/dio)                |
| Secure storage    | [flutter_secure_storage](https://pub.dev/packages/flutter_secure_storage) |
| Charts            | [fl_chart](https://pub.dev/packages/fl_chart)      |
| Fonts             | [google_fonts](https://pub.dev/packages/google_fonts) |
| Formatting        | [intl](https://pub.dev/packages/intl)              |

---

## 📁 Project Structure

```
lib/
├── main.dart
├── models/         # Data models (User, Expense, Category, Budget)
├── providers/      # Riverpod state providers (auth, expenses)
├── screens/        # UI screens (login, home, add expense, stats)
├── services/       # API, auth, and storage services
└── widgets/        # Reusable UI components (cards, chips)
```

---

## 🚀 Getting Started

### Prerequisites
- [Flutter SDK](https://docs.flutter.dev/get-started/install) installed
- The [backend API](https://github.com/Samarjitkashyp/expense-tracker) running (see its README)

### 1. Clone the repository
```bash
git clone https://github.com/Samarjitkashyp/expense-tracker-app.git
cd expense-tracker-app
```

### 2. Install dependencies
```bash
flutter pub get
```

### 3. Point the app at your backend
The API base URL is configured in [`lib/services/api_service.dart`](lib/services/api_service.dart).
For a **physical Android device on the same Wi-Fi**, set it to your PC's LAN IP:
```dart
return 'http://192.168.0.237:8000'; // replace with your PC's IP
```
Start the backend with `--host 0.0.0.0` so the phone can reach it.

> 💡 Alternatively, connect via USB and run `adb reverse tcp:8000 tcp:8000`, then use `http://127.0.0.1:8000`.

### 4. Run the app
```bash
flutter run
```

---

## 🎨 App Icon

The launcher icon is generated with [flutter_launcher_icons](https://pub.dev/packages/flutter_launcher_icons).
Place your icon at `assets/icon/app_icon.png` (1024×1024 recommended), then run:
```bash
dart run flutter_launcher_icons
```

---

## 📄 License

This project is provided as-is for personal and educational use.
