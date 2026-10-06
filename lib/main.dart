import 'package:colabhealth/colabhealth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load(fileName: '.env', isOptional: true);

  try {
    if (Firebase.apps.isEmpty) {
      await Firebase.initializeApp();
    }
    FirebaseMessaging.onBackgroundMessage(firebaseMessagingBackgroundHandler);
  } catch (e) {
    AppLogger.error('Firebase/FCM bootstrap', error: e);
  }

  runApp(const ColabHealthApp());
}

class ColabHealthApp extends StatelessWidget {
  const ColabHealthApp({super.key});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => FocusManager.instance.primaryFocus?.unfocus(),
      child: GetMaterialApp(
        title: 'Colab Health',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.light,
        darkTheme: AppTheme.dark,
        themeMode: ThemeStore.themeMode,
        defaultTransition: Transition.cupertino,
        initialRoute: AppPages.initial,
        getPages: AppPages.routes,
      ),
    );
  }
}
