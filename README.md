# ColabHealth

A production-oriented Flutter **health & fitness tracker**. It shows a user's daily
health metrics — **Steps** (Health Connect / HealthKit + phone pedometer),
**Calories** (free REST API) and **Sleep** (manual log + optional Health-platform
import) — with a dashboard, detail screens, local persistence/offline support,
Google authentication, Firebase push notifications and a true wake-up alarm.

> Built for the Senior Mobile Developer / Flutter Technical Assessment.

---

## Documentation

| Doc | Covers |
|---|---|
| [docs/SETUP.md](docs/SETUP.md) | Project setup, environment, Firebase config, and the app initialization sequence |
| [docs/STEPS.md](docs/STEPS.md) | Step data sources (Health Connect + pedometer), install/permission flows |
| [docs/PUSH_NOTIFICATIONS.md](docs/PUSH_NOTIFICATIONS.md) | Firebase Cloud Messaging setup, sending & testing pushes |

---

## 1. Tech stack & versions

| Tool | Version |
|---|---|
| Flutter | 3.38.10 (stable) |
| Dart | ≥ 3.10.9 (bundled with the above) |
| Min Android SDK | 26 (Health Connect / firebase_auth) |
| State management | **GetX** |
| Networking | **Dio** |
| Local storage | **get_storage** |

Key packages: `get`, `get_storage`, `dio`, `firebase_core/auth`, `cloud_firestore`,
`google_sign_in`, `pedometer`, `health`, `android_alarm_manager_plus`,
`flutter_local_notifications`, `fl_chart`, `permission_handler`, `intl`.

---

## 2. Running the app

```bash
flutter pub get

# Option A — put the key in a git-ignored .env (loaded at runtime):
cp .env.example .env            # then set API_NINJAS_KEY=...
flutter run

# Option B — inject at build time instead:
flutter run --dart-define=API_NINJAS_KEY=YOUR_FREE_KEY
```

Get a free key at https://api-ninjas.com (endpoint: `/v1/caloriesburned`).
Without a key the app still runs and shows cached/placeholder calories, with a
clear message — all other features work.

> 📘 Full step-by-step setup, Firebase config and the initialization sequence are
> in **[docs/SETUP.md](docs/SETUP.md)**. After any native change (manifest, Kotlin,
> Gradle) run `flutter clean && flutter run`.

### Firebase / Google Sign-In (one-time)
1. Firebase Console → project **colab-health** → **Project Settings**.
2. Add your app's **SHA-1** and **SHA-256** fingerprints (debug SHA-1 from
   `cd android && ./gradlew signingReport`).
3. **Authentication → Sign-in method → enable Google**.
4. Download the updated `google-services.json` → `android/app/`.
5. (iOS) add an iOS app, download `GoogleService-Info.plist` → `ios/Runner/`.

---

## 3. Architecture

A layered, feature-first architecture (inspired by a production messenger app),
with barrel files and strict separation of concerns:

```
lib/
├── colabhealth.dart        # master barrel
├── core/                   # theme, spacing, enums, utils, extensions (no UI logic)
├── data/
│   ├── local/              # AppStorage (get_storage) + keys
│   ├── model/              # typed models (+ ResBaseModel<T> response envelope)
│   ├── network/            # Dio ApiClient + interceptor + endpoints + ApiConfig
│   ├── services/           # pedometer, auth, firestore, health, notifications, alarm
│   └── repository/         # orchestrate API + cache + Firestore (no UI, no widgets)
└── presentation/
    ├── splash / auth / onboarding
    ├── home/               # bottom-nav shell
    └── dashboard / steps / sleep / calories / settings
        └── {bindings, controllers, views, widgets}   # per feature
```

**Golden rule:** API / business logic never lives in widgets. Widgets observe a
controller; the controller calls a repository; the repository talks to the
service/network/cache. Each screen has its own `Binding` (GetX DI).

### Context-free theming
Theme colours and text styles are resolved **without `BuildContext`**:
`AppColors.current` / `AppTextStyles.semiBold16`. Light/dark switching works via
`Get.changeThemeMode` (rebuilds the tree) + a persisted mode in `ThemeStore`;
`ThemeMode.system` is resolved through `Get.isPlatformDarkMode`.

---

## 4. State management — why GetX

- **Reactive & granular:** `.obs` + `Obx` rebuild only the widgets that read a
  value, avoiding unnecessary rebuilds.
- **DI + routing in one:** `Bindings` lazily create controllers per route; named
  routes keep navigation declarative.
- **Context-free:** lets us keep theming/snackbars/navigation out of the widget
  tree, which suited the "no BuildContext theme" requirement.

Every data flow follows **loading → success → error (+ retry)** via a shared
`ViewState { idle, loading, success, error }` enum on each controller.

---

## 5. API / data approach

| Metric | Source |
|---|---|
| **Steps** | **Health Connect / HealthKit** daily total (primary) + **pedometer** live top-up; pedometer-only fallback with a persisted per-day baseline. See [docs/STEPS.md](docs/STEPS.md). |
| **Calories** | **Free REST API** (API Ninjas `/caloriesburned`), parsed into `CaloriesModel`. Walking minutes are derived from the day's steps. |
| **Sleep** | **Manual log** (source of truth) with the §3.4 computed breakdown; optional **import from Apple Health / Health Connect** when a wearable has staged data. |

All network calls go through `ApiClient` (Dio) and return a typed
`ResBaseModel<T>`. The interceptor injects the API key and logs traffic in debug.
Errors are mapped to friendly messages; every data screen offers **Retry**.

### Sleep calculations (assessment §3.4)
`SleepModel` stores raw start/end times; durations are **computed**, never stored:
- `Total Sleep = (Sleep End − Sleep Start) − Awake Time`
- `Deep / REM / Light = Σ (stage End − stage Start)`
- `Awake Time = Σ awake periods`

---

## 6. Local persistence & offline handling

**`get_storage`** was chosen because its reads are **synchronous**, so cached data
paints on the very first frame — the dashboard is never blank on cold start, even
offline. It's ideal for small JSON blobs (cached metrics, sleep logs, settings).

What's cached: `cached_steps`, `cached_calories`, `cached_sleep_logs`,
`last_sync_time`, `theme_mode`, step target & sleep schedule.

**Offline flow:** on startup the cache is shown instantly; a background refresh
updates it on success, or keeps the cache and shows an **"Offline — showing last
saved data"** banner + Retry on failure. **Firestore** is the synced source of
truth when signed in; `get_storage` mirrors it for offline use. Sleep logs, which
have no backend requirement, are themselves source-of-truth locally.

---

## 7. Feature highlights

- **Onboarding:** permissions, avatar/mask pick, step-target, sleep schedule, reminder toggle.
- **Dashboard:** today's date + calendar sheet, reusable `MetricCard`s for Steps/Calories/Sleep.
- **Steps:** live pedometer ring, hourly bar chart, set-target bottom sheet → Firestore.
- **Sleep:** routine summary, stage chart, history, detail screen with the §3.4 table, wake alarm.
- **Calories:** live API with breakdown, loading/error/retry, offline fallback.
- **Settings:** profile (name + avatar), **light/dark/system** theme, reminders, sign-out.
- **Bottom sheets everywhere** instead of dialogs (calendar, target, sleep log, theme, avatar).

---

## 8. Assumptions

- Steps are read from Health Connect / HealthKit when available (true daily total),
  with the pedometer adding live increments; without a provider the pedometer alone
  is baselined to "today". The hourly bar chart is shaped from the day's total (no
  historical hourly store yet).
- "Calories" = calories burned (activity), fetched from a free API; walking
  duration is approximated from steps (~100 steps/min).
- Sleep stage data from Health platforms exists only when a wearable recorded it;
  otherwise manual logging is used.
- A single signed-in user per device; Firestore holds their profile & history.

---

## 9. Security

- **No secrets committed.** The API key is passed via `--dart-define`.
- No passwords/keys/certificates in the repo; `.env*` and `firebase_options.dart`
  are git-ignored.

---