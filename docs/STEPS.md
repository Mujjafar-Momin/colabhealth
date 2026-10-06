# Steps — Data Sources & Setup

How ColabHealth counts daily steps, how to set it up, and how the install /
permission / zero-state flows behave.

---

## 1. Overview

Steps use a two-source strategy for an accurate, live count:

| Priority | Source | Role |
|---|---|---|
| 1 (primary) | **Health Connect** (Android) / **HealthKit** (iOS) | True daily total from midnight, aggregating Google Fit & other apps |
| 2 (live top-up) | **Phone pedometer** (`pedometer`) | Adds steps taken since the last health read, with no double-counting |
| 3 (fallback) | **Pedometer only** | Used when no health provider is available, via a persisted daily baseline |

If no source yields data (provider missing or permission denied), the screen
shows **0 steps** with a prompt — never an error or infinite spinner.

---

## 2. Components

| File | Responsibility |
|---|---|
| `lib/data/src/services/health_service.dart` | Health Connect/HealthKit: availability, install, permission, `todaySteps()` |
| `lib/data/src/services/pedometer_service.dart` | Pedometer stream + `ACTIVITY_RECOGNITION` permission |
| `lib/data/src/repository/steps_repository.dart` | Orchestrates health + pedometer + cache + Firestore |
| `lib/presentation/steps/controllers/steps_controller.dart` | State machine: source selection, live top-up, prompts |
| `lib/presentation/steps/views/steps_view.dart` | Ring, chart, and the install/permission prompt cards |
| `lib/data/src/local/app_storage.dart` | Persisted pedometer daily baseline |

---

## 3. Android setup (required)

All of this is already configured in the repo — listed here for reference.

**`android/app/src/main/AndroidManifest.xml`**
```xml
<uses-permission android:name="android.permission.ACTIVITY_RECOGNITION"/>
<uses-permission android:name="android.permission.health.READ_STEPS"/>
<uses-permission android:name="android.permission.health.READ_SLEEP"/>

<!-- MainActivity must be a FragmentActivity for the health permission launcher -->
<!-- Permission-rationale intent filters (Android 14+ and ≤13 alias) -->
<!-- <queries> entry for com.google.android.apps.healthdata -->
```

**`android/app/src/main/kotlin/.../MainActivity.kt`**
```kotlin
class MainActivity : FlutterFragmentActivity()
```

**`android/app/build.gradle.kts`** → `minSdk = 26`.

---

## 4. iOS setup

1. Enable the **HealthKit** capability in Xcode (Runner target → Signing &
   Capabilities).
2. Add usage descriptions to `ios/Runner/Info.plist`:
   ```xml
   <key>NSHealthShareUsageDescription</key>
   <string>Read your step count to show daily activity.</string>
   <key>NSHealthUpdateUsageDescription</key>
   <string>ColabHealth does not write health data.</string>
   ```
3. HealthKit requires a **real device** — it is unavailable in the simulator.

---

## 5. Runtime flow

```
StepsController.init()
 ├─ _initHealth()
 │   ├─ stepsAvailability()
 │   │    needsInstall  → dataStatus = needsInstall   (show Install card)
 │   │    notSupported  → pedometer-only mode
 │   │    available     → hasStepsPermission() || requestStepsAuthorization()
 │   │                     granted → healthActive = true; _readHealthSteps()
 │   │                     denied  → dataStatus = needsPermission (show Grant card)
 │   └─
 ├─ _initPedometer()
 │   granted → listen to pedometer stream (live top-up / fallback)
 │   denied  → permissionDenied = true only if health is not active
 └─ if still no data → show 0 steps
```

### Live top-up (no double counting)
When Health Connect is active, the controller records the health total and the
pedometer cumulative value at that moment. Each pedometer tick then applies:

```
todaySteps = healthBaseTotal + (cumulativeNow − cumulativeAtHealthRead)
```

So the base comes from Health Connect and only the *delta* comes from the sensor.

### Pedometer-only baseline (fallback)
Without a health provider, the pedometer's cumulative-since-boot value is
converted to "today" using a **persisted** baseline
(`stepBaseline` + `stepBaselineDate` in `AppStorage`):

- Re-anchors when the **day rolls over** or the **device reboots**
  (cumulative drops below the stored baseline).
- Preserves steps already counted earlier today, so reopening the app mid-day
  continues the count instead of resetting to 0.

---

## 6. User-facing states (Steps screen)

| State | What the user sees | Action |
|---|---|---|
| `needsInstall` | "Connect your step data" card | **Install Health Connect** → Play Store |
| `needsPermission` | "Allow step access" card | **Grant permission** → consent dialog |
| Pedometer denied (no health) | Offline banner + saved steps | Pull-to-refresh / retry |
| All denied / unavailable | **0 steps** + prompt card | Install or grant to populate |
| OK | Live ring, hourly chart, distance/calories | Pull-to-refresh to re-read |

Controller entry points used by the UI:
- `installHealthConnect()` — opens the store, then re-runs `init()`.
- `requestHealthPermission()` — requests access on demand, then reads steps.
- `retry()` — resets health anchors and re-initializes (pull-to-refresh).

---

## 7. Testing on a physical device

1. `flutter clean && flutter run` (native changes need a full rebuild).
2. Open the **Steps** tab.
3. If prompted, **Install Health Connect**, then grant step read access.
4. Walk a few steps — the ring should increment live and persist across app
   restarts within the same day.

> **Limitation:** the pedometer can only count from when its baseline is first
> anchored today; it cannot recover steps taken before the app ever read the
> sensor. Health Connect provides the true full-day total and is therefore the
> primary source.
