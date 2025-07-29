import 'package:flutter/material.dart';

class StatusUpdateScreen extends StatelessWidget {
  const StatusUpdateScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Status Update'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text('Change Job Status'),
            const SizedBox(height: 20),
            DropdownButton<String>(
              items: const [
                DropdownMenuItem(value: 'Accepted', child: Text('Accepted')),
                DropdownMenuItem(value: 'In Progress', child: Text('In Progress')),
                DropdownMenuItem(value: 'On Hold', child: Text('On Hold')),
                DropdownMenuItem(value: 'Completed', child: Text('Completed')),
              ],
              onChanged: (value) {},
              hint: const Text('Select Status'),
            ),
          ],
        ),
      ),
    );
  }
} 