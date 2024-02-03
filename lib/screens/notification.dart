import 'package:flutter/material.dart';
import 'package:reslate/controllers/notification.dart';

class notificationScreen extends StatefulWidget {
  const notificationScreen({super.key});

  @override
  State<notificationScreen> createState() => _notificationScreenState();
}

class _notificationScreenState extends State<notificationScreen> {
  @override
  void initState() {
    listenToNotifications();
    super.initState();
  }

//  to listen to any notification clicked or not
  listenToNotifications() {
    print("Listening to notification");
    LocalNotifications.onClickNotification.stream.listen((event) {
      print(event);
      Navigator.pushNamed(context, '/another', arguments: event);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Flutter Local Notifications")),
      body: Container(
        height: double.infinity,
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              ElevatedButton.icon(
                icon: Icon(Icons.timer_outlined),
                onPressed: () async {
                  // Show a time picker to get user-selected time
                  final TimeOfDay? selectedTime = await showTimePicker(
                    context: context,
                    initialTime: TimeOfDay.now(),
                  );

                  // Check if a time was selected
                  if (selectedTime != null) {
                    LocalNotifications.showPeriodicNotifications(
                      title: "It time to review.",
                      body:
                          "Let's review vocabulary. It only takes 2 minutes.\nมาทบทวนคำศัพท์กันเถอะ ใช้เวลาแค่ 2 นาทีเท่านั้น",
                      payload: "This is periodic data",
                      scheduledTime: selectedTime,
                    );
                  }
                },
                label: Text("Periodic Notifications"),
              ),

              // to close periodic notifications
              ElevatedButton.icon(
                  icon: Icon(Icons.delete_outline),
                  onPressed: () {
                    LocalNotifications.cancel(1);
                  },
                  label: Text("Close Periodic Notifcations")),
              ElevatedButton.icon(
                  icon: Icon(Icons.delete_forever_outlined),
                  onPressed: () {
                    LocalNotifications.cancelAll();
                  },
                  label: Text("Cancel All Notifcations")),
              ElevatedButton.icon(
                icon: Icon(Icons.access_time),
                onPressed: () async {
                  // Show a time picker to get user-selected time
                  final TimeOfDay? selectedTime = await showTimePicker(
                    context: context,
                    initialTime: TimeOfDay.now(),
                  );

                  // Check if a time was selected
                  if (selectedTime != null) {
                    // Get the current date and combine it with the user-selected time
                    DateTime currentDate = DateTime.now();
                    DateTime scheduledTime = DateTime(
                      currentDate.year,
                      currentDate.month,
                      currentDate.day,
                      selectedTime.hour,
                      selectedTime.minute,
                    );

                    // Call the showCustomTimeNotification method
                    LocalNotifications.showCustomTimeNotification(
                      title: "Custom Time Notification",
                      body: "This is a notification with a custom time",
                      payload: "Custom time payload",
                      scheduledTime: scheduledTime,
                    );
                  }
                },
                label: Text("Custom Time Notification"),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
