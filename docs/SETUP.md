# Project Setup & Initialization

This guide walks you from a fresh clone to a running ColabHealth build on a
physical device, and explains how the app initializes at launch.

- For push notifications, see [PUSH_NOTIFICATIONS.md](PUSH_NOTIFICATIONS.md).
- For an architecture overview, see the root [README.md](../README.md).

---

## 1. Prerequisites

| Tool | Version | Notes |
|---|---|---|
| Flutter SDK | 3.38.x (stable) | `flutter --version` |
| Dart | ≥ 3.10.9 | Bundled with Flutter |
| Android SDK | compileSdk latest, **minSdk 26** | Required by Health Connect + firebase_auth |
| Xcode | 15+ (for iOS) | HealthKit requires a real device |
| A physical device | — | Steps, Health Connect and alarms **do not work on emulators** |

> ⚠️ **Use a real phone.** The step-counter sensor, Health Connect and the
> background alarm are hardware/OS features that emulators do not provide.

---

## 2. Clone & install dependencies

```bash
git clone <repo-url> colabhealth
cd colabhealth
flutter pub get
```

---

## 3. Environment variables (`.env`)

The free calories API key is read at runtime via `flutter_dotenv`.

```bash
cp .env.example .env
```

Then edit `.env`:

```dotenv
# Get a free key at https://api-ninjas.com/profile
API_NINJAS_KEY=your_real_key_here
```

- `.env` is **git-ignored** — never commit it.
- Loading is optional (`dotenv.load(..., isOptional: true)` in `lib/main.dart`),
  so the app still runs without it and falls back to cached/placeholder calories.

---

## 4. Firebase configuration

The app uses Firebase for Auth (Google Sign-In), Firestore and Cloud Messaging.

### Android
1. Firebase Console → project **colab-health** → **Project Settings**.
2. Under **Your apps**, select/add the Android app with package
   `com.colab.colabhealth`.
3. Add the signing fingerprints so Google Sign-In works:
   ```bash
   cd android && ./gradlew signingReport
   ```
   Copy the **SHA-1** and **SHA-256** from the `debug` variant into
   Project Settings → Your apps → Add fingerprint.
4. **Authentication → Sign-in method → enable Google.**
5. Download the updated **`google-services.json`** → place in `android/app/`.

### iOS (optional)
1. Add an iOS app with bundle id matching `ios/Runner`.
2. Download **`GoogleService-Info.plist`** → place in `ios/Runner/`.
3. Enable the **Push Notifications** and **Background Modes** capabilities
   (see [PUSH_NOTIFICATIONS.md](PUSH_NOTIFICATIONS.md)).

> `google-services.json` / `GoogleService-Info.plist` hold project identifiers,
> not secrets, but are kept out of version control by convention. A missing file
> will fail the Firebase build step — `main.dart` and `splash_screen.dart` guard
> `Firebase.initializeApp()` in try/catch so the app degrades gracefully.

---

## 5. Health Connect (Android steps & sleep)

Steps are read primarily from **Health Connect** (which aggregates Google Fit and
other providers); the pedometer adds live increments on top.

Already configured in the repo:
- `android/app/src/main/AndroidManifest.xml`
  - `MainActivity` extends `FlutterFragmentActivity` (required by the `health`
    plugin's permission launcher).
  - Permissions: `health.READ_STEPS`, `health.READ_SLEEP`,
    `ACTIVITY_RECOGNITION`.
  - Permission-rationale intent filters (Android 14+ and ≤13 alias).
  - `<queries>` entry for `com.google.android.apps.healthdata`.
- `minSdk 26` in `android/app/build.gradle.kts`.

On-device, the user flow is handled by the app:
1. **Health Connect not installed** → the Steps screen shows an *Install Health
   Connect* card (opens the Play Store).
2. **Permission not granted** → a *Grant permission* card requests access.
3. **Still denied** → steps gracefully show `0` plus live pedometer steps.

See the step flow details in [STEPS.md](STEPS.md).

---

## 6. Run the app

```bash
# Simplest — reads API key from .env
flutter run

# Or inject the key at build time instead of using .env
flutter run --dart-define=API_NINJAS_KEY=your_real_key_here
```

> After changing native files (AndroidManifest, Kotlin, Gradle) do a full
> rebuild — **hot restart is not enough**:
> ```bash
> flutter clean && flutter pub get && flutter run
> ```

### Build flavors
Flavors are defined in `lib/core/src/utils/app_enums.dart`
(`dev`, `stage`, `prod`). Wire them to Gradle/Xcode schemes if you need
per-flavor Firebase projects; the default build targets `prod`.

---

## 7. Initialization sequence

The app boots through a splash screen that prepares every service before routing.

```
main()                                   (lib/main.dart)
 ├─ WidgetsFlutterBinding.ensureInitialized()
 ├─ dotenv.load('.env', isOptional)
 ├─ Firebase.initializeApp()             (if not already)
 ├─ FirebaseMessaging.onBackgroundMessage(firebaseMessagingBackgroundHandler)
 └─ runApp(ColabHealthApp)               → GetMaterialApp, initialRoute = /splash

SplashScreen._decide()                   (lib/presentation/splash/splash_screen.dart)
 ├─ AppStorage.init()                    get_storage ready (sync reads)
 ├─ Firebase.initializeApp()             (guarded)
 ├─ ApiClient.initialize()               Dio + interceptors
 ├─ NotificationService.init()           local-notif channels + timezones
 ├─ PushNotificationService.init()       FCM permission + token + listeners
 ├─ AlarmService.init()                  android_alarm_manager_plus
 └─ route decision:
      not logged in      → LoginScreen
      onboarding pending → OnboardingScreen
      otherwise          → HomeScreen (bottom-nav shell)
```

Per-screen dependencies are registered lazily through GetX `Bindings`
(e.g. `HomeBinding` puts the Dashboard/Steps/Sleep/Calories/Settings
controllers when the home shell loads).

---

## 8. Troubleshooting

| Symptom | Cause / Fix |
|---|---|
| `Permission launcher not found` | `MainActivity` must extend `FlutterFragmentActivity` (already fixed). Full rebuild. |
| Steps stuck at 0 | On a real device, install Health Connect + grant step access, or walk with the app open for the pedometer fallback. Emulators have no sensor. |
| Google Sign-In fails | Add debug **SHA-1/SHA-256** to Firebase and re-download `google-services.json`. |
| No FCM push received | See [PUSH_NOTIFICATIONS.md](PUSH_NOTIFICATIONS.md) — check token, permission, and channel. |
| Calories show placeholder | Missing/invalid `API_NINJAS_KEY` in `.env`. |
| Native change not applied | `flutter clean && flutter run` (hot restart doesn't rebuild native). |
