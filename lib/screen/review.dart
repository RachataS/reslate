import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class reviewPage extends StatefulWidget {
  const reviewPage({super.key});

  @override
  State<reviewPage> createState() => _reviewPageState();
}

class _reviewPageState extends State<reviewPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: Text(
          "Select Mode",
          style: TextStyle(color: Colors.blue[400]!),
        ),
        backgroundColor: Colors.grey.shade50,
        elevation: 0,
      ),
      body: Center(
        child: Column(
          // mainAxisAlignment: MainAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(15, 80, 15, 15),
              child: SizedBox(
                width: 250,
                height: 250,
                child: ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blue[400],
                        fixedSize: const Size(300, 50),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(50))),
                    onPressed: () {
                      SystemSound.play(SystemSoundType.click);
                      dialogMode(true, false);
                    },
                    icon: Icon(Icons.workspaces_filled),
                    label: Text(" Multiple Choice")),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(15),
              child: SizedBox(
                width: 250,
                height: 250,
                child: ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blue[400],
                        fixedSize: const Size(300, 50),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(50))),
                    onPressed: () {
                      SystemSound.play(SystemSoundType.click);
                      dialogMode(false, true);
                    },
                    icon: Icon(Icons.apps_rounded),
                    label: Text(" Match Card")),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> dialogMode(multiple, card) async {
    Dialog wordSelect = Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Container(
        width: 300,
        height: 300,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (multiple == true)
              Text(
                "Mutiple Choice",
                style: TextStyle(fontSize: 20),
              ),
            if (card == true)
              Text('Match Card', style: TextStyle(fontSize: 20)),
            Padding(
              padding: const EdgeInsets.all(20),
              child: SizedBox(
                width: 250,
                child: ElevatedButton(
                  onPressed: () {},
                  child: Text("Saved words"),
                  style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue[400],
                      fixedSize: const Size(300, 50),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(50))),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(0),
              child: SizedBox(
                width: 250,
                child: ElevatedButton(
                  onPressed: () {},
                  child: Text("Wrong answer"),
                  style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue[400],
                      fixedSize: const Size(300, 50),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(50))),
                ),
              ),
            ),
          ],
        ),
      ),
    );
    showDialog(context: context, builder: (BuildContext context) => wordSelect);
  }
}
