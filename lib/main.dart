import 'package:flutter/material.dart';
import 'package:timekeepr/screens/break.dart';
import 'package:timekeepr/screens/login.dart';
import 'package:timekeepr/screens/clock-in.dart';
import 'package:timekeepr/screens/menu.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Timekeepr',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      routes: {
        // SplashScreen.routeName: (context) => const SplashScreen(),
        LoginScreen.routeName: (context) => const LoginScreen(),
        ClockInScreen.routeName: (context) => const ClockInScreen(),
        Menu.routeName: (context) => const Menu(),
        Break.routeName: (context) => const Break(),
      },
      home: const LoginScreen(),
      // home: const ClockInScreen(),
    );
  }
}
