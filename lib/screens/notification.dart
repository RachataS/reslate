import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:reslate/controllers/notification.dart';

class NotificationScreen extends StatefulWidget {
  const NotificationScreen({Key? key});

  @override
  State<NotificationScreen> createState() => _NotificationScreenState();
}

class _NotificationScreenState extends State<NotificationScreen> {
  List<NotificationData> notifications = [];
  int notificationCount = 0;

  @override
  void initState() {
    super.initState();
    loadPreferences();
  }

  Future<void> loadPreferences() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();

    // Load notification state and times from SharedPreferences
    setState(() {
      notificationCount = prefs.getInt('notificationCount') ?? 0;
      notifications.clear();
      for (int i = 0; i < notificationCount; i++) {
        int hour = prefs.getInt('notificationTime_${i + 1}_hour') ??
            TimeOfDay.now().hour;
        int minute = prefs.getInt('notificationTime_${i + 1}_minute') ??
            TimeOfDay.now().minute;
        notifications.add(
          NotificationData(
            time: TimeOfDay(hour: hour, minute: minute),
            enabled: prefs.getBool('notification_${i + 1}_enabled') ?? false,
          ),
        );
      }
    });

    listenToNotifications();
  }

  Future<void> savePreferences() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();

    // Save notification state and times to SharedPreferences
    prefs.setInt('notificationCount', notificationCount);
    for (int i = 0; i < notificationCount; i++) {
      prefs.setBool('notification_${i + 1}_enabled', notifications[i].enabled);
      prefs.setInt(
          'notificationTime_${i + 1}_hour', notifications[i].time.hour);
      prefs.setInt(
          'notificationTime_${i + 1}_minute', notifications[i].time.minute);
    }
  }

  //  to listen to any notification clicked or not
  listenToNotifications() {
    LocalNotifications.onClickNotification.stream.listen((event) {
      print(event);
      Navigator.pushNamed(context, '/another', arguments: event);
    });
  }

  // Function to format TimeOfDay as a string
  String formatTime(TimeOfDay time) {
    String hour = time.hour.toString().padLeft(2, '0');
    String minute = time.minute.toString().padLeft(2, '0');
    return '$hour:$minute';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        decoration: BoxDecoration(
          gradient: LinearGradient(begin: Alignment.topCenter, colors: [
            Colors.blue[600]!,
            Colors.blue[300]!,
            Colors.blue[100]!,
            // Colors.blue[50]!,
          ]),
        ),
        child: CustomScrollView(
          slivers: [
            SliverAppBar(
              pinned: true,
              automaticallyImplyLeading: false,
              backgroundColor: Colors.transparent,
              title: Text(
                'Notification',
                style: TextStyle(fontSize: 35, color: Colors.white),
              ),
              centerTitle: false,
              actions: [
                Padding(
                  padding: const EdgeInsets.only(right: 15),
                  child: Icon(
                    Icons.notifications_active,
                    size: 50,
                    color: Colors.yellow[700],
                  ),
                )
              ],
            ),
            SliverList(
              delegate: SliverChildBuilderDelegate(
                (BuildContext context, int index) {
                  return buildNotificationItem(index);
                },
                childCount: notifications.length,
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(50.0),
        ),
        backgroundColor: Colors.blue,
        onPressed: () {
          setState(() {
            // Add a new notification
            notificationCount++;
            notifications.add(NotificationData(
              time: TimeOfDay.now(),
              enabled: false,
            ));
          });
          savePreferences();
        },
        child: Icon(
          Icons.add,
          color: Colors.white,
        ),
      ),
    );
  }

  Widget buildNotificationItem(int index) {
    return SizedBox(
      height: 110,
      child: Card(
        color: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
        margin: const EdgeInsets.all(5),
        child: Padding(
          padding: const EdgeInsets.only(right: 20),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              GestureDetector(
                onTap: () => _selectTime(index),
                child: Text(
                  '\t\tTime: ${formatTime(notifications[index].time)}',
                  style: TextStyle(
                    fontSize: 22,
                    color: Colors.black,
                  ),
                ),
              ),
              Spacer(),
              CupertinoSwitch(
                activeColor: Colors.green,
                thumbColor: Colors.white,
                trackColor: Colors.grey,
                value: notifications[index].enabled,
                onChanged: (value) async {
                  setState(() => notifications[index].enabled = value);
                  if (notifications[index].enabled) {
                    final TimeOfDay? selectedTime = await showTimePicker(
                      context: context,
                      initialTime: notifications[index].time,
                    );
                    if (selectedTime != null) {
                      notifications[index].time = selectedTime;
                      LocalNotifications.dailyNotifications(
                        id: index + 1,
                        title: "It's time to review.",
                        body: "พอจะมีเวลาว่างไหม มาทบทวนคำศัพท์ภาษาอังกฤษกัน",
                        payload: "review",
                        scheduledTime: selectedTime,
                      );
                      savePreferences();
                    } else {
                      notifications[index].enabled = false;
                      LocalNotifications.cancel(index + 1);
                      savePreferences();
                    }
                  } else {
                    LocalNotifications.cancel(index + 1);
                    savePreferences();
                  }
                  setState(() {});
                },
              ),
              IconButton(
                icon: Icon(Icons.delete),
                onPressed: () {
                  setState(() {
                    // Remove the notification at the given index
                    notifications.removeAt(index);
                    notificationCount--;
                  });
                  savePreferences();
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _selectTime(int index) async {
    final TimeOfDay? pickedTime = await showTimePicker(
      context: context,
      initialTime: notifications[index].time,
    );
    if (pickedTime != null) {
      setState(() {
        notifications[index].time = pickedTime;
      });
    }
  }
}

class NotificationData {
  TimeOfDay time;
  bool enabled;

  NotificationData({required this.time, required this.enabled});
}
