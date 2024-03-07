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
  late TimeOfDay notificationTime1;
  late TimeOfDay notificationTime2;
  late TimeOfDay notificationTime3;

  @override
  void initState() {
    loadPreferences();
    super.initState();
  }

  Future<void> loadPreferences() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();

    // Load notification state and times from SharedPreferences
    setState(() {
      noti1On = prefs.getBool('noti1On') ?? false;
      noti2On = prefs.getBool('noti2On') ?? false;
      noti3On = prefs.getBool('noti3On') ?? false;

      int hour1 =
          prefs.getInt('notificationTime1_hour') ?? TimeOfDay.now().hour;
      int minute1 =
          prefs.getInt('notificationTime1_minute') ?? TimeOfDay.now().minute;
      notificationTime1 = TimeOfDay(hour: hour1, minute: minute1);

      int hour2 =
          prefs.getInt('notificationTime2_hour') ?? TimeOfDay.now().hour;
      int minute2 =
          prefs.getInt('notificationTime2_minute') ?? TimeOfDay.now().minute;
      notificationTime2 = TimeOfDay(hour: hour2, minute: minute2);

      int hour3 =
          prefs.getInt('notificationTime3_hour') ?? TimeOfDay.now().hour;
      int minute3 =
          prefs.getInt('notificationTime3_minute') ?? TimeOfDay.now().minute;
      notificationTime3 = TimeOfDay(hour: hour3, minute: minute3);
    });

    listenToNotifications();
  }

  Future<void> savePreferences() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();

    // Save notification state and times to SharedPreferences
    prefs.setBool('noti1On', noti1On);
    prefs.setBool('noti2On', noti2On);
    prefs.setBool('noti3On', noti3On);

    prefs.setInt('notificationTime1_hour', notificationTime1.hour);
    prefs.setInt('notificationTime1_minute', notificationTime1.minute);

    prefs.setInt('notificationTime2_hour', notificationTime2.hour);
    prefs.setInt('notificationTime2_minute', notificationTime2.minute);

    prefs.setInt('notificationTime3_hour', notificationTime3.hour);
    prefs.setInt('notificationTime3_minute', notificationTime3.minute);
  }

  //  to listen to any notification clicked or not
  listenToNotifications() {
    LocalNotifications.onClickNotification.stream.listen((event) {
      print(event);
      Navigator.pushNamed(context, '/another', arguments: event);
    });
  }

  bool noti1On = false;
  bool noti2On = false;
  bool noti3On = false;

  // Function to get the time for notification 1
  String getNotificationTimeText1() {
    return noti1On ? 'Time: ${formatTime(notificationTime1)}' : 'Time: Not set';
  }

  // Function to get the time for notification 2
  String getNotificationTimeText2() {
    return noti2On ? 'Time: ${formatTime(notificationTime2)}' : 'Time: Not set';
  }

  // Function to get the time for notification 3
  String getNotificationTimeText3() {
    return noti3On ? 'Time: ${formatTime(notificationTime3)}' : 'Time: Not set';
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
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            colors: [
              Colors.blue[600]!,
              Colors.blue[300]!,
              Colors.blue[100]!,
            ],
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.only(
            top: 10,
            left: 8,
            right: 8,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 70, 20, 20),
                child: Row(
                  children: [
                    Text('Notification',
                        style: TextStyle(fontSize: 35, color: Colors.white)),
                    Spacer(),
                    Icon(
                      Icons.notifications_active,
                      size: 50,
                      color: Colors.yellow[700],
                    )
                  ],
                ),
              ),
              SizedBox(
                height: 110,
                child: Card(
                  color: Colors.white,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15)),
                  margin: const EdgeInsets.all(5),
                  child: Padding(
                      padding: const EdgeInsets.only(right: 20),
                      child: TextButton(
                        onPressed: () async {
                          if (noti1On) {
                            // If noti1On is already true, show time picker and update scheduled time
                            final TimeOfDay? selectedTime =
                                await showTimePicker(
                              context: context,
                              initialTime: notificationTime1,
                            );
                            if (selectedTime != null) {
                              notificationTime1 = selectedTime;
                              LocalNotifications.dailyNotifications(
                                id: 1,
                                title: "It's time to review.",
                                body:
                                    "Let's review vocabulary. It only takes 2 minutes.\nมาทบทวนคำศัพท์กันเถอะ ใช้เวลาแค่ 2 นาทีเท่านั้น",
                                payload: "review",
                                scheduledTime: selectedTime,
                              );
                              savePreferences();
                            }
                            setState(() {});
                          } else {
                            // If noti1On is false, set it to true and proceed as before
                            noti1On = true;
                            setState(() {});
                            final TimeOfDay? selectedTime =
                                await showTimePicker(
                              context: context,
                              initialTime: notificationTime1,
                            );
                            if (selectedTime != null) {
                              notificationTime1 = selectedTime;
                              LocalNotifications.dailyNotifications(
                                id: 1,
                                title: "It's time to review.",
                                body:
                                    "Let's review vocabulary. It only takes 2 minutes.\nมาทบทวนคำศัพท์กันเถอะ ใช้เวลาแค่ 2 นาทีเท่านั้น",
                                payload: "review",
                                scheduledTime: selectedTime,
                              );
                              savePreferences();
                            } else {
                              noti1On = false;
                              LocalNotifications.cancel(1);
                              notificationTime1 = TimeOfDay.now();
                              savePreferences();
                            }
                          }
                        },
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              '\t\t${getNotificationTimeText1()}',
                              style: TextStyle(
                                fontSize: 22,
                                color: Colors.black,
                              ),
                            ),
                            Spacer(),
                            CupertinoSwitch(
                              activeColor: Colors.green,
                              thumbColor: Colors.white,
                              trackColor: Colors.grey,
                              value: noti1On,
                              onChanged: (value) async {
                                setState(() => noti1On = value);
                                if (noti1On) {
                                  final TimeOfDay? selectedTime =
                                      await showTimePicker(
                                    context: context,
                                    initialTime: notificationTime1,
                                  );
                                  if (selectedTime != null) {
                                    notificationTime1 = selectedTime;
                                    LocalNotifications.dailyNotifications(
                                      id: 1,
                                      title: "It's time to review.",
                                      body:
                                          "Let's review vocabulary. It only takes 2 minutes.\nมาทบทวนคำศัพท์กันเถอะ ใช้เวลาแค่ 2 นาทีเท่านั้น",
                                      payload: "review",
                                      scheduledTime: selectedTime,
                                    );
                                    savePreferences();
                                  } else {
                                    noti1On = false;
                                    LocalNotifications.cancel(1);
                                    notificationTime1 = TimeOfDay.now();
                                    savePreferences();
                                  }
                                } else {
                                  LocalNotifications.cancel(1);
                                  notificationTime1 = TimeOfDay.now();
                                  savePreferences();
                                }
                                setState(() {});
                              },
                            ),
                          ],
                        ),
                      )),
                ),
              ),
              SizedBox(
                height: 110,
                child: Card(
                  color: Colors.white,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15)),
                  margin: const EdgeInsets.all(5),
                  child: Padding(
                      padding: const EdgeInsets.only(right: 20),
                      child: TextButton(
                        onPressed: () async {
                          if (noti2On) {
                            final TimeOfDay? selectedTime =
                                await showTimePicker(
                              context: context,
                              initialTime: notificationTime2,
                            );
                            if (selectedTime != null) {
                              notificationTime2 = selectedTime;
                              LocalNotifications.dailyNotifications(
                                id: 2,
                                title: "It's time to review.",
                                body:
                                    "Let's review vocabulary. It only takes 2 minutes.\nมาทบทวนคำศัพท์กันเถอะ ใช้เวลาแค่ 2 นาทีเท่านั้น",
                                payload: "review",
                                scheduledTime: selectedTime,
                              );
                              savePreferences();
                            }
                            setState(() {});
                          } else {
                            noti2On = true;
                            setState(() {});
                            final TimeOfDay? selectedTime =
                                await showTimePicker(
                              context: context,
                              initialTime: notificationTime2,
                            );
                            if (selectedTime != null) {
                              notificationTime2 = selectedTime;
                              LocalNotifications.dailyNotifications(
                                id: 2,
                                title: "It's time to review.",
                                body:
                                    "Let's review vocabulary. It only takes 2 minutes.\nมาทบทวนคำศัพท์กันเถอะ ใช้เวลาแค่ 2 นาทีเท่านั้น",
                                payload: "review",
                                scheduledTime: selectedTime,
                              );
                              savePreferences();
                            } else {
                              noti2On = false;
                              LocalNotifications.cancel(2);
                              notificationTime2 = TimeOfDay.now();
                              savePreferences();
                            }
                          }
                        },
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              '\t\t${getNotificationTimeText2()}',
                              style: TextStyle(
                                fontSize: 22,
                                color: Colors.black,
                              ),
                            ),
                            Spacer(),
                            CupertinoSwitch(
                              activeColor: Colors.green,
                              thumbColor: Colors.white,
                              trackColor: Colors.grey,
                              value: noti2On,
                              onChanged: (value) async {
                                setState(() => noti2On = value);
                                if (noti2On) {
                                  final TimeOfDay? selectedTime =
                                      await showTimePicker(
                                    context: context,
                                    initialTime: notificationTime2,
                                  );
                                  if (selectedTime != null) {
                                    notificationTime2 = selectedTime;
                                    LocalNotifications.dailyNotifications(
                                      id: 2,
                                      title: "It's time to review.",
                                      body:
                                          "Let's review vocabulary. It only takes 2 minutes.\nมาทบทวนคำศัพท์กันเถอะ ใช้เวลาแค่ 2 นาทีเท่านั้น",
                                      payload: "review",
                                      scheduledTime: selectedTime,
                                    );
                                    savePreferences();
                                  } else {
                                    noti2On = false;
                                    LocalNotifications.cancel(2);
                                    notificationTime2 = TimeOfDay.now();
                                    savePreferences();
                                  }
                                } else {
                                  LocalNotifications.cancel(2);
                                  notificationTime2 = TimeOfDay.now();
                                  savePreferences();
                                }
                                setState(() {});
                              },
                            ),
                          ],
                        ),
                      )),
                ),
              ),
              SizedBox(
                height: 110,
                child: Card(
                  color: Colors.white,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15)),
                  margin: const EdgeInsets.all(5),
                  child: Padding(
                      padding: const EdgeInsets.only(right: 20),
                      child: TextButton(
                        onPressed: () async {
                          if (noti3On) {
                            final TimeOfDay? selectedTime =
                                await showTimePicker(
                              context: context,
                              initialTime: notificationTime3,
                            );
                            if (selectedTime != null) {
                              notificationTime3 = selectedTime;
                              LocalNotifications.dailyNotifications(
                                id: 3,
                                title: "It's time to review.",
                                body:
                                    "Let's review vocabulary. It only takes 2 minutes.\nมาทบทวนคำศัพท์กันเถอะ ใช้เวลาแค่ 2 นาทีเท่านั้น",
                                payload: "review",
                                scheduledTime: selectedTime,
                              );
                              savePreferences();
                            }
                            setState(() {});
                          } else {
                            noti3On = true;
                            setState(() {});
                            final TimeOfDay? selectedTime =
                                await showTimePicker(
                              context: context,
                              initialTime: notificationTime3,
                            );
                            if (selectedTime != null) {
                              notificationTime3 = selectedTime;
                              LocalNotifications.dailyNotifications(
                                id: 3,
                                title: "It's time to review.",
                                body:
                                    "Let's review vocabulary. It only takes 2 minutes.\nมาทบทวนคำศัพท์กันเถอะ ใช้เวลาแค่ 2 นาทีเท่านั้น",
                                payload: "review",
                                scheduledTime: selectedTime,
                              );
                              savePreferences();
                            } else {
                              noti2On = false;
                              LocalNotifications.cancel(3);
                              notificationTime3 = TimeOfDay.now();
                              savePreferences();
                            }
                          }
                        },
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              '\t\t${getNotificationTimeText3()}',
                              style: TextStyle(
                                fontSize: 22,
                                color: Colors.black,
                              ),
                            ),
                            Spacer(),
                            CupertinoSwitch(
                              activeColor: Colors.green,
                              thumbColor: Colors.white,
                              trackColor: Colors.grey,
                              value: noti3On,
                              onChanged: (value) async {
                                setState(() => noti3On = value);
                                if (noti3On) {
                                  final TimeOfDay? selectedTime =
                                      await showTimePicker(
                                    context: context,
                                    initialTime: notificationTime3,
                                  );
                                  if (selectedTime != null) {
                                    notificationTime3 = selectedTime;
                                    LocalNotifications.dailyNotifications(
                                      id: 3,
                                      title: "It's time to review.",
                                      body:
                                          "Let's review vocabulary. It only takes 2 minutes.\nมาทบทวนคำศัพท์กันเถอะ ใช้เวลาแค่ 2 นาทีเท่านั้น",
                                      payload: "review",
                                      scheduledTime: selectedTime,
                                    );
                                    savePreferences();
                                  } else {
                                    noti3On = false;
                                    LocalNotifications.cancel(3);
                                    notificationTime3 = TimeOfDay.now();
                                    savePreferences();
                                  }
                                } else {
                                  LocalNotifications.cancel(3);
                                  notificationTime3 = TimeOfDay.now();
                                  savePreferences();
                                }
                                setState(() {});
                              },
                            ),
                          ],
                        ),
                      )),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
