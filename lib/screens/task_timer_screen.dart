import 'package:flutter/material.dart';

class TaskTimerScreen extends StatelessWidget {
  const TaskTimerScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Task Timer'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text('Task Timer Placeholder'),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {},
              child: const Text('Start'),
            ),
            ElevatedButton(
              onPressed: () {},
              child: const Text('Pause'),
            ),
            ElevatedButton(
              onPressed: () {},
              child: const Text('Stop'),
            ),
          ],
        ),
      ),
    );
  }
} 