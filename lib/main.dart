import 'package:clear_labs/map_page.dart';
import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(home: PermissionPage());
  }
}

class PermissionPage extends StatefulWidget {
  const PermissionPage({super.key});

  @override
  State<PermissionPage> createState() => _PermissionPageState();
}

class _PermissionPageState extends State<PermissionPage> {
  @override
  void initState() {
    super.initState();
    getPermission();
  }

  void getPermission() async {
    final _locresult = await Permission.location.request();

    if (_locresult.isGranted) {
      Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (BuildContext context) => MapPage()),
          (route) => false);
    } else if (_locresult.isDenied) {
      requestPermission();
    } else {
      manualPermission();
    }
  }

  void requestPermission() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return AlertDialog(
          title: Text("Permission Required"),
          content:
              Text("Please Allow Permission so that we can get your Location"),
          actions: [
            TextButton(
              onPressed: () {
                getPermission();
                Navigator.of(context).pop();
              },
              child: Text("Okay"),
            ),
          ],
        );
      },
    );
  }

  void manualPermission() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return AlertDialog(
          title: Text("Permission Required"),
          content:
              Text("Please Allow Permission so that we can get your Location"),
          actions: [
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton(
                  onPressed: () {
                    openAppSettings();
                  },
                  child: Text("Open App Settings"),
                ),
                TextButton(
                  onPressed: () {
                    getPermission();
                    Navigator.of(context).pop(true);
                  },
                  child: Text("Retry"),
                ),
              ],
            ),
          ],
        );
      },
    );
  }

  Widget build(BuildContext context) {
    return Scaffold();
  }
}
