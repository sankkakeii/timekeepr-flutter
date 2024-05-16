import 'package:flutter/material.dart';

class Break extends StatelessWidget {
  const Break({super.key});

  static const routeName = '/break';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Break'),
      ),
      body: const Center(
        child: Text('Break'),
      ),
    );
  }
}
