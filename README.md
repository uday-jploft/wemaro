
# wemaro

# 📹 Flutter Video Call App

A production-ready **Flutter app** featuring **one-to-one video calling** using **WebRTC and Firebase for signaling**, mock **authentication**, and a **fake user list** from a REST API. Built using **clean architecture**, **Riverpod** for state management, and industry-standard Flutter development practices.

---

## 🚀 Features

### ✅ Authentication
- Login screen with **email & password**
- Basic form **validation**
- **Mock login** using [ReqRes API](https://reqres.in) or hardcoded credentials

### ✅ Video Call (WebRTC + Firebase)
- Real-time **one-to-one** video calling
- Generate a **unique meeting ID**
- Join calls via **meeting ID**
- Show **local and remote** video streams
- Toggle **mute/unmute** and **enable/disable** video

### ✅ User List
- Fetch a **list of users** from a fake REST API
- Display **avatars and names** in a scrollable list

### ✅ Production-Readiness
- **Splash screen** and **custom app icon**
- **App versioning**
- Permissions for **camera**, **microphone**, and **internet**
- **Debug signing config** for Android & iOS
- Structured using **clean architecture principles**
- **Error handling** best practices

---

## 📁 Folder Structure

```plaintext
lib/
├── providers/               # provider classes
├── utils/               # Common utilities, services
├── view/
│   ├── auth/           # Authentication screens and logic
│   ├── call/           # Video call logic and UI
│   ├── user_list/      # Fake REST API user list
│   ├── home_screen     # home screen
│   └── widgets/        # common use Widgets
├── splash_screen.dart
├── main.dart


```

## 🔧 Setup & Installation
1. Prerequisites

- Flutter SDK (>= 3.10.0)
- Firebase account
- Android Studio or VS Code
- iOS/macOS setup if targeting iOS


## Installation

git clone https://github.com/uday-jploft/wemaro

```bash
cd wemaro
flutter pub get
flutter run
```


## 🧪 Test Credentials (Mock Auth)

You can use any valid email format with:

Email: eve.holt@reqres.in
Password: anything

OR use hardcoded validation as per your mock logic.

| Technology | Description                              |
| ---------- | ---------------------------------------- |
| Flutter    | UI Framework                             |
| Firebase   | Signaling using Firestore                |
| WebRTC     | Peer-to-peer video & audio communication |
| Riverpod   | State management                         |
| REST API   | Mock authentication & user list          |


## Support

For support, email uday.dev7737@gmail.com.


## Authors

- [@udaysingh7737](https://www.linkedin.com/in/udaysingh7737/)

