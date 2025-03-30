import 'package:cipherx/utils/constants.dart';
import 'package:cipherx/utils/restore_system_chrome.dart';
import 'package:flutter/material.dart';

class NotificationScreen extends StatefulWidget {
  const NotificationScreen({super.key});

  @override
  State<NotificationScreen> createState() => _NotificationScreenState();
}

class _NotificationScreenState extends State<NotificationScreen> {
  List<Map<String, String>> notifications = [
    {
      "title": "Payment Received",
      "message": "You have added \₹1000 to your wallet.",
      "time": "2m ago",
      "icon": "💰"
    },
    {
      "title": "New Expense Added",
      "message": "You added a new expense: \₹50 for groceries.",
      "time": "10m ago",
      "icon": "🛒"
    },
    {
      "title": "Budget Alert",
      "message": "You have exceeded 80% of your monthly budget.",
      "time": "1h ago",
      "icon": "⚠️"
    },
  ];

  Future<void> _refreshNotifications() async {
    await Future.delayed(const Duration(seconds: 2)); // Simulate refresh delay
    setState(() {
      notifications.shuffle(); // Just to simulate new data
    });
  }

  @override
  Widget build(BuildContext context) {
    restoreSystemChrome(color: AppColors.tonesAppColor400);
    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppColors.tonesAppColor400,
        title: const Text("Notifications"),
        centerTitle: true,
      ),
      body: RefreshIndicator(
        onRefresh: _refreshNotifications,
        child: notifications.isEmpty
            ? const Center(
          child: Text(
            "No notifications yet!",
            style: TextStyle(fontSize: 16, color: Colors.grey),
          ),
        )
            : ListView.builder(
          padding: const EdgeInsets.all(12),
          itemCount: notifications.length,
          itemBuilder: (context, index) {
            final notification = notifications[index];
            return Card(
              margin: const EdgeInsets.only(bottom: 10),
              elevation: 2,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              child: ListTile(
                leading: Text(
                  notification["icon"]!,
                  style: const TextStyle(fontSize: 24),
                ),
                title: Text(
                  notification["title"]!,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                subtitle: Text(notification["message"]!),
                trailing: Text(
                  notification["time"]!,
                  style: const TextStyle(fontSize: 12, color: Colors.grey),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
