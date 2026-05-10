import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_settings_screen_ex/flutter_settings_screen_ex.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:project/page/settings_page.dart';
import 'package:project/services/notification_service.dart';
import '../controllers/user_controller.dart';
import '../firebase_options.dart';
import '../page/home_page.dart';
import '../page/login_page.dart';
import 'dart:io' show Platform;

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load();


  if (!kIsWeb) {
    if (Platform.isAndroid) {
      await Firebase.initializeApp(
          name: 'android', options: DefaultFirebaseOptions.currentPlatform);
    } else {
      await Firebase.initializeApp(
          options: DefaultFirebaseOptions.currentPlatform);
    }
    NotificationService().initNotification();
  } else {
    await Firebase.initializeApp(
        options: DefaultFirebaseOptions.currentPlatform);
  }
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});
  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  void initState() {
    super.initState();
    Settings.init(cacheProvider: SharePreferenceCache());
    NotificationService().initNotification();
    NotificationService().scheduleDailyNotifications(
        hourAndMinuteList: ["09:00"],
        title: "✨Outfit Suggestion✨",
        body: "Did you check your outfit for today?");
    NotificationService().scheduleDailyNotifications(
        hourAndMinuteList: ["15:00"],
        title: "🌎Plan Your Next Trip🏖️",
        body: "Check popular locations!");
  }

  @override
  Widget build(BuildContext context) {
    final isDarkTheme =
        Settings.getValue<bool>(SettingsPage.keyDarkTheme, defaultValue: false);
    return ValueChangeObserver<bool>(
        cacheKey: SettingsPage.keyDarkTheme,
        defaultValue: false,
        builder: (_, isDarkTheme, __) => MaterialApp(
              theme: isDarkTheme ? ThemeData.dark() : ThemeData.light(),
              debugShowCheckedModeBanner: false,
              home: UserController.user != null
                  ? const HomePage()
                  : const LoginPage(),
            ));
  }
}



