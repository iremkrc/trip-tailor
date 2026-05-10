import 'package:flutter/material.dart';
import 'package:project/services/notification_service.dart';

class NotificationPage extends StatefulWidget {
  const NotificationPage({super.key});

  @override
  _NotificationPageState createState() => _NotificationPageState();
}

class _NotificationPageState extends State<NotificationPage> {
  //initState() method is called when the state object is created.
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: ElevatedButton(
            onPressed: () {
              NotificationService().showNotification(
                  title: 'Hello', body: 'This is a notification');
            },
            child: const Text('Show Notification')),
      ),
    );
  }
}
