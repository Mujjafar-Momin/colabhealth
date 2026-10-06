# Firebase Push Notifications (FCM)

How Cloud Messaging is wired in ColabHealth, how to configure it, and how to send a test push.

Related: [SETUP.md](SETUP.md) · root [README.md](../README.md)

---

## 1. How it works here

| Concern                  | Implementation                                                                        |
|--------------------------|---------------------------------------------------------------------------------------|
| Remote push (FCM)        | `lib/data/src/services/push_notification_service.dart`                                |
| Local display / channels | `lib/data/src/services/notification_service.dart`                                     |
| Background handler       | `firebaseMessagingBackgroundHandler` (top-level, in `push_notification_service.dart`) |
| Bootstrap                | `lib/main.dart` (registers bg handler) + `splash_screen.dart` (inits services)        |

FCM message types:

- **Notification messages** (sent from the Firebase Console): Android/iOS draw the system-tray
  notification automatically when the app is backgrounded/terminated.
- **Foreground messages**: the OS does **not** draw these, so the app renders them itself via
  `NotificationService.showRemote(...)` through the `reminders` channel.

---

## 2. Initialization flow

```
main() (lib/main.dart)
 ├─ Firebase.initializeApp()
 └─ FirebaseMessaging.onBackgroundMessage(firebaseMessagingBackgroundHandler)

SplashScreen._decide()
 ├─ NotificationService.init()        // creates Android channels, timezones
 └─ PushNotificationService.init()    // permission + token + listeners
```

`PushNotificationService.init()`:

1. Requests notification permission (`alert / badge / sound`).
2. Sets iOS foreground presentation options.
3. Fetches and logs the **FCM device token** (and listens for refreshes).
4. Subscribes to `onMessage` (foreground), `onMessageOpenedApp` (tap).

The background handler is a top-level function annotated with
`@pragma('vm:entry-point')` so it survives tree-shaking and runs in its own isolate; it
re-initializes Firebase in that isolate.

---

## 3. Android configuration

Already present / required:

- `firebase_messaging: ^15.1.5` in `pubspec.yaml`.
- `google-services.json` in `android/app/` (from the Firebase Console).
- `POST_NOTIFICATIONS` permission in the manifest (Android 13+ runtime prompt is handled by
  `requestPermission()`).
- The `reminders` notification channel (importance `high`) is created in
  `NotificationService.init()`.

No extra Gradle changes are needed beyond the standard
`com.google.gms.google-services` plugin that `flutterfire`/Firebase setup adds.

---

## 4. iOS configuration

1. In Xcode (Runner target → **Signing & Capabilities**) add:
    - **Push Notifications**
    - **Background Modes** → check *Remote notifications*.
2. Upload your **APNs Authentication Key (.p8)** to Firebase Console → Project Settings → **Cloud
   Messaging** → Apple app config.
3. Ensure `GoogleService-Info.plist` is in `ios/Runner/`.
4. Test on a **real device** (APNs is unavailable in the simulator).

---

## 5. Get the device token

Run the app and watch the console — the token is printed on startup:

```
================ FCM TOKEN ================
<your-device-fcm-token>
==========================================
```

You can also re-fetch it programmatically via
`PushNotificationService.instance.refreshToken()`.

---

## 6. Send a test push

### A) Firebase Console (quickest)

1. Console → **Messaging** → **Create your first campaign** → **Firebase Notification messages**.
2. Enter a title & body → **Send test message**.
3. Paste the FCM token from §5 → **Test**.

### B) Server / cURL (HTTP v1 API)

```bash
curl -X POST \
  "https://fcm.googleapis.com/v1/projects/<PROJECT_ID>/messages:send" \
  -H "Authorization: Bearer <OAUTH2_ACCESS_TOKEN>" \
  -H "Content-Type: application/json" \
  -d '{
    "message": {
      "token": "<DEVICE_FCM_TOKEN>",
      "notification": { "title": "Hello", "body": "From ColabHealth" }
    }
  }'
```

`<OAUTH2_ACCESS_TOKEN>` is a short-lived token for a Firebase service account (e.g.
`gcloud auth application-default print-access-token`). The legacy server-key API is deprecated —
prefer HTTP v1.

---

## 7. Verify each state

| App state      | Expected                                                         |
|----------------|------------------------------------------------------------------|
| **Foreground** | `onMessage` fires → local notification drawn via `showRemote`    |
| **Background** | OS shows the tray notification automatically                     |
| **Terminated** | `firebaseMessagingBackgroundHandler` runs; tapping opens the app |
| **Tap**        | `onMessageOpenedApp` logs the message id (hook navigation here)  |

---

## 8. Notification channels

Defined in `NotificationService`:

| Channel id  | Name      | Importance | Used for                                      |
|-------------|-----------|------------|-----------------------------------------------|
| `reminders` | Reminders | high       | Daily sleep reminders + foreground FCM pushes |
| `alarms`    | Alarms    | max        | Full-screen wake-up alarm                     |

Keep remote pushes on the `reminders` channel (as `showRemote` does) so their importance and sound
match the app's other notifications.
