import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:geolocator/geolocator.dart';
import 'package:permission_handler/permission_handler.dart';

class Menu extends StatelessWidget {
  const Menu({Key? key}) : super(key: key);

  static const routeName = '/menu';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Menu'),
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              GridView.count(
                shrinkWrap: true,
                crossAxisCount: 2,
                children: [
                  _buildMenuItem(context, 'Clock In', Icons.timer, '/clock-in'),
                  _buildMenuItem(
                      context, 'Clock Out', Icons.timer_off, clockOut),
                  _buildMenuItem(context, 'Start Break', Icons.free_breakfast,
                      '/break'),
                  _buildMenuItem(
                      context, 'End Break', Icons.breakfast_dining, endBreak),
                ],
              ),
              const SizedBox(height: 20),
              const Text(
                'User Clock In Information:',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              // Add your clock in information widget here
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMenuItem(
      BuildContext context, String title, IconData icon, dynamic onTap) {
    return GestureDetector(
      onTap: onTap is String
          ? () {
              Navigator.pushNamed(context, onTap);
            }
          : onTap,
      child: Card(
        elevation: 3,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(15),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 50, color: Theme.of(context).primaryColor),
            const SizedBox(height: 10),
            Text(
              title,
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> clockOut() async {
    try {
      final storage = FlutterSecureStorage();
      final token = await storage.read(key: 'auth_token');
      final userEmail = await storage.read(key: 'user_email');
      var status = await Permission.location.request();
      if (status.isGranted) {
        final position = await Geolocator.getCurrentPosition(
            desiredAccuracy: LocationAccuracy.high);
        final body = jsonEncode({
          'email': userEmail,
          'userPosition': [position.latitude, position.longitude],
        });

        final response = await http.post(
          Uri.parse('https://timekeepr-api-v2.onrender.com/api/user/clock-out'),
          headers: <String, String>{
            'Content-Type': 'application/json',
            'Authorization': 'Bearer $token',
          },
          body: body,
        );

        final responseData = jsonDecode(response.body);
        print(responseData);
        // Handle response as needed
      } else {
        // Handle if location permission is not granted
      }
    } catch (e) {
      // Handle error
    }
  }

  Future<void> endBreak() async {
    try {
      final storage = const FlutterSecureStorage();
      final token = await storage.read(key: 'auth_token');
      final userEmail = await storage.read(key: 'user_email');
      var status = await Permission.location.request();
      if (status.isGranted) {
        final position = await Geolocator.getCurrentPosition(
            desiredAccuracy: LocationAccuracy.high);
        final body = jsonEncode({
          'email': userEmail,
          'userPosition': [position.latitude, position.longitude],
        });

        final response = await http.post(
          Uri.parse('https://timekeepr-api-v2.onrender.com/api/user/end-break'),
          headers: <String, String>{
            'Content-Type': 'application/json',
            'Authorization': 'Bearer $token',
          },
          body: body,
        );

        final responseData = jsonDecode(response.body);
        print(responseData);
        // Handle response as needed
      } else {
        // Handle if location permission is not granted
      }
    } catch (e) {
      // Handle error
    }
  }
}
