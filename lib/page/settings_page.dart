import 'package:flutter/material.dart';
import 'package:flutter_settings_screen_ex/flutter_settings_screen_ex.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:mailto/mailto.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:project/page/login_page.dart';
import 'dart:io' show Platform;
import 'package:flutter/foundation.dart' show kIsWeb;

class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});
  static const keyDarkTheme = "dark-theme";

  Future<void> _changePassword(BuildContext context) async {
    final TextEditingController passwordController = TextEditingController();
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text("Change Password"),
          content: TextField(
            controller: passwordController,
            obscureText: true,
            decoration: const InputDecoration(hintText: "Enter new password"),
          ),
          actions: <Widget>[
            TextButton(
              child: const Text("Cancel"),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: const Text("Change"),
              onPressed: () async {
                if (passwordController.text.isNotEmpty) {
                  User? user = FirebaseAuth.instance.currentUser;
                  if (user != null) {
                    await user.updatePassword(passwordController.text);
                    Navigator.of(context).pop();
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                          content: Text("Password changed successfully")),
                    );
                  }
                }
              },
            ),
          ],
        );
      },
    );
  }

  Future<void> _launchMailto() async {
    final mailtoLink = Mailto(
      to: ['kbasol19@ku.edu.tr'],
      subject: 'Feedback on TripTailor',
      body: 'Here is your feedback:',
    );
    final url = mailtoLink.toString();

    if (await canLaunchUrl(Uri.parse(url))) {
      await launchUrl(Uri.parse(url));
    } else {
      throw 'Could not launch $url';
    }
  }

  Future<void> _rateUs() async {
    if (kIsWeb) {
      DeviceInfoPlugin deviceInfo = DeviceInfoPlugin();
      WebBrowserInfo webBrowserInfo = await deviceInfo.webBrowserInfo;
      String userAgent = webBrowserInfo.userAgent ?? "";
      if (userAgent.contains("Chrome") ||
          userAgent.contains("Safari") ||
          userAgent.contains("Firefox")) {
        _launchURL(Uri.parse(
            "https://play.google.com/store/apps/details?id=com.instagram.android"));
      }
    } else if (Platform.isAndroid) {
      _launchURL(Uri.parse(
          "https://play.google.com/store/apps/details?id=com.instagram.android"));
    } else if (Platform.isIOS) {
      _launchURL(Uri.parse("https://apps.apple.com/app/id389801252"));
    }
  }

  Future<void> _launchURL(Uri url) async {
    if (await canLaunchUrl(url)) {
      await launchUrl(url);
    } else {
      throw 'Could not launch $url';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: ListView(
          children: [
            SimpleSettingsTile(
              title: "Back",
              leading: const Icon(Icons.arrow_back),
              onTap: () {
                Navigator.pop(context);
              },
            ),
            SettingsGroup(title: "General", children: <Widget>[
              SwitchSettingsTile(
                title: "Dark Theme",
                settingKey: keyDarkTheme,
                leading: const Icon(Icons.dark_mode),
                onChange: (_) => {},
              ),
            ]),
            SettingsGroup(title: "Account", children: <Widget>[
              SimpleSettingsTile(
                title: "Sign out",
                leading: const Icon(Icons.logout),
                onTap: () async {
                  await FirebaseAuth.instance.signOut();
                  Navigator.pushAndRemoveUntil(
                    context,
                    MaterialPageRoute(builder: (context) => const LoginPage()),
                    (Route<dynamic> route) => false,
                  );
                },
              ),
              SimpleSettingsTile(
                title: "Change Password",
                leading: const Icon(Icons.lock),
                onTap: () {
                  _changePassword(context);
                },
              ),
              SimpleSettingsTile(
                title: "Delete Account",
                leading: const Icon(Icons.delete_forever),
                subtitle: "This action cannot be undone",
                onTap: () async {
                  User? user = FirebaseAuth.instance.currentUser;
                  if (user != null) {
                    await user.delete();
                    Navigator.pushAndRemoveUntil(
                      context,
                      MaterialPageRoute(
                          builder: (context) => const LoginPage()),
                      (Route<dynamic> route) => false,
                    );
                  }
                },
              ),
            ]),
            SettingsGroup(title: "Feedback", children: <Widget>[
              SimpleSettingsTile(
                title: "Rate us",
                leading: const Icon(Icons.star),
                onTap: () {
                  _rateUs();
                },
              ),
              SimpleSettingsTile(
                title: "Contact us",
                leading: const Icon(Icons.email),
                onTap: () {
                  _launchMailto();
                },
              ),
            ]),
          ],
        ),
      ),
    );
  }
}
