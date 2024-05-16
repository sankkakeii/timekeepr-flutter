import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:geolocator/geolocator.dart';
import 'package:permission_handler/permission_handler.dart';

class ClockInScreen extends StatefulWidget {
  const ClockInScreen({super.key});

  static const routeName = '/clock-in';

  @override
  _ClockInScreenState createState() => _ClockInScreenState();
}

class _ClockInScreenState extends State<ClockInScreen> {
  String? currentTime;
  String? orgClockinTime;
  String? userName;
  String? userEmail;
  String errorMessage = '';
  String responseMessage = '';
  bool isLoading = false;
  final storage = const FlutterSecureStorage();

  @override
  void initState() {
    super.initState();
    fetchInitialData();
    updateTime();
  }

  Future<void> fetchInitialData() async {
    try {
      setState(() {
        isLoading = true;
      });

      final token = await storage.read(key: 'auth_token');
      final userResponse = await http.get(
        Uri.parse('https://timekeepr-api-v2.onrender.com/api/user/get-cuser'),
        headers: <String, String>{
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );
      final orgClockResponse = await http.get(
        Uri.parse('https://timekeepr-api-v2.onrender.com/api/user/get-clock'),
        headers: <String, String>{
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      final userData = jsonDecode(userResponse.body);
      final orgClockData = jsonDecode(orgClockResponse.body);

      setState(() {
        userName = '${userData['firstName']} ${userData['lastName']}';
        userEmail = userData['email'];
        orgClockinTime = orgClockData['clockInTime'];
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        errorMessage = 'An error occurred. Please try again';
        isLoading = false;
        print(e);
      });
    }
  }

  Future<void> clockIn() async {
    try {
      setState(() {
        isLoading = true;
      });
      final token = await storage.read(key: 'auth_token');
      var status = await Permission.location.request();
      if (status.isGranted) {
        final position = await getCurrentPosition();
        final body = jsonEncode({
          'email': userEmail,
          'userPosition': [position.latitude, position.longitude],
        });

        final response = await http.post(
          Uri.parse('https://timekeepr-api-v2.onrender.com/api/user/clock-in'),
          headers: <String, String>{
            'Content-Type': 'application/json',
            'Authorization': 'Bearer $token',
          },
          body: body,
        );

        final responseData = jsonDecode(response.body);
        setState(() {
          responseMessage = responseData['message'];
          isLoading = false;
        });
      } else {
        setState(() {
          errorMessage = 'Location permission not granted.';
          isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        errorMessage = 'An error occurred. Please try again';
        isLoading = false;
        print(e);
      });
    }
  }

  Future<Position> getCurrentPosition() async {
    return await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high);
  }

  void updateTime() {
    setState(() {
      currentTime = DateTime.now().toString();
    });
    Future.delayed(Duration(seconds: 1), updateTime);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Clock In'),
      ),
      body: Center(
        child: isLoading
            ? CircularProgressIndicator()
            : Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  const Text(
                    'Good Day',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    userName ?? '',
                    style: const TextStyle(fontSize: 30, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    'Current Time: $currentTime',
                    style: const TextStyle(fontSize: 16),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    'Clock In Time: $orgClockinTime',
                    style: const TextStyle(fontSize: 16),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    responseMessage,
                    style: const TextStyle(fontSize: 16, color: Colors.green),
                  ),
                  Text(
                    errorMessage,
                    style: const TextStyle(fontSize: 16, color: Colors.red),
                  ),
                  ElevatedButton(
                    onPressed: (userName == null || orgClockinTime == null) ? null : clockIn,
                    child: const Text('Clock In'),
                  ),
                ],
              ),
      ),
    );
  }
}
