import 'package:flutter/material.dart';

class reviewPage extends StatefulWidget {
  const reviewPage({super.key});

  @override
  State<reviewPage> createState() => _reviewPageState();
}

class _reviewPageState extends State<reviewPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SizedBox(
              width: 200,
              height: 200,
              child: ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue[400],
                      fixedSize: const Size(300, 50),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(50))),
                  onPressed: () {},
                  icon: Icon(Icons.workspaces_filled),
                  label: Text(" Multiple Choice")),
            ),
          ],
        ),
      ),
    );
  }
}
