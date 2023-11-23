import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:provider/provider.dart';

class NotificationModel {
  late bool isEnabled;
  late TimeOfDay notificationTime;

  NotificationModel({required this.isEnabled, required this.notificationTime});
}

class NotificationProvider extends ChangeNotifier {
  List<NotificationModel> notifications = [];

  void addNotification(NotificationModel notification) {
    notifications.add(notification);
    notifyListeners();
  }

  void removeNotification(NotificationModel notification) {
    notifications.remove(notification);
    notifyListeners();
  }
}

class NotificationScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => NotificationProvider(),
      child: NotificationForm(),
    );
  }
}

class NotificationForm extends StatefulWidget {
  @override
  _NotificationFormState createState() => _NotificationFormState();
}

class _NotificationFormState extends State<NotificationForm> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  late TimeOfDay _selectedTime;

  @override
  void initState() {
    super.initState();
    _selectedTime = TimeOfDay.now();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Notification Settings'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              SwitchListTile(
                title: Text('Enable Notifications'),
                value: Provider.of<NotificationProvider>(context)
                    .notifications
                    .isNotEmpty,
                onChanged: (value) {
                  if (value) {
                    _scheduleNotification();
                  } else {
                    _cancelNotification();
                  }
                },
              ),
              ListTile(
                title: Text('Notification Time'),
                trailing: Text(
                  '${_selectedTime.hour}:${_selectedTime.minute.toString().padLeft(2, '0')}',
                ),
                onTap: () => _selectTime(context),
              ),
              ElevatedButton(
                onPressed: () {
                  if (_formKey.currentState?.validate() ?? false) {
                    _addNotification();
                  }
                },
                child: Text('Add Notification'),
              ),
              // List of added notifications with remove button
              Expanded(
                child: Consumer<NotificationProvider>(
                  builder: (context, provider, _) {
                    return ListView.builder(
                      itemCount: provider.notifications.length,
                      itemBuilder: (context, index) {
                        return ListTile(
                          title: Text(
                              'Notification ${index + 1} - ${provider.notifications[index].notificationTime.format(context)}'),
                          trailing: IconButton(
                            icon: Icon(Icons.delete),
                            onPressed: () => _removeNotification(
                                provider.notifications[index]),
                          ),
                        );
                      },
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _selectTime(BuildContext context) async {
    final TimeOfDay? pickedTime = await showTimePicker(
      context: context,
      initialTime: _selectedTime,
    );

    if (pickedTime != null && pickedTime != _selectedTime) {
      setState(() {
        _selectedTime = pickedTime;
      });
    }
  }

  void _scheduleNotification() {
    final provider = Provider.of<NotificationProvider>(context, listen: false);
    final notificationModel = NotificationModel(
      isEnabled: true,
      notificationTime: _selectedTime,
    );

    provider.addNotification(notificationModel);

    // Implement logic to schedule the notification using FlutterLocalNotifications
    // You can refer to the flutter_local_notifications documentation for details.
  }

  void _cancelNotification() {
    final provider = Provider.of<NotificationProvider>(context, listen: false);
    provider.notifications.clear();

    // Implement logic to cancel the scheduled notifications using FlutterLocalNotifications
    // You can refer to the flutter_local_notifications documentation for details.
  }

  void _addNotification() {
    final provider = Provider.of<NotificationProvider>(context, listen: false);
    final notificationModel = NotificationModel(
      isEnabled: true,
      notificationTime: _selectedTime,
    );

    provider.addNotification(notificationModel);

    // You can add logic here to save the notification data (if needed).
  }

  void _removeNotification(NotificationModel notification) {
    final provider = Provider.of<NotificationProvider>(context, listen: false);
    provider.removeNotification(notification);

    // You can add logic here to cancel the removed notification (if needed).
  }
}
