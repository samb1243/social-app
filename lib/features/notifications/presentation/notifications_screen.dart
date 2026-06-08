import 'package:flutter/material.dart';

class NotificationsScreen extends StatelessWidget {
  const NotificationsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Notifications', style: TextStyle(fontWeight: FontWeight.bold)),
      ),
      body: Center(
        child: Text(
          'No notifications yet',
          style: Theme.of(context).textTheme.bodyMedium,
        ),
      ),
    );
  }
}
