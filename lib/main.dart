import 'package:car_info/screens/home_screen.dart';
import 'package:car_info/screens/login_screen.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:shared_preferences/shared_preferences.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();

  bool timer = true;
  if(await checkTimer()) {
    timer = false;
  }
  runApp(MyApp(value: timer));
}

Future<bool> checkTimer() async {
  final Future<SharedPreferences> _prefs = SharedPreferences.getInstance();
  final prefs = await _prefs;
  if(prefs.containsKey('timer')) {
    DateTime past = DateTime.parse(prefs.getString('timer')!);
    DateTime curr = DateTime.now();
    if (curr.difference(past).inHours >= 2) {
      return true;
    }
  }
  return false;
}

class MyApp extends StatelessWidget {
  final bool value;
  const MyApp({Key? key, required this.value}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Car Info',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: StreamBuilder(
        stream: FirebaseAuth.instance.authStateChanges(),
        builder: (context, userSnapshot) {
          if(userSnapshot.hasData && value) {
            return const HomeScreen();
          } else {
            return const LoginScreen();
          }
        },
      ),
    );
  }
}