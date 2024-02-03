import 'package:flutter/material.dart';
import 'package:learn_app_backend/learn_app_backend.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Home'),
        backgroundColor: Theme.of(context).primaryColor,
        foregroundColor: Theme.of(context).colorScheme.onPrimary,
      ),
      bottomNavigationBar: BottomAppBar(
        child: Padding(
          padding: const EdgeInsets.all(15),
          child: Row(
            children: [
              IconButton(
                onPressed: () {
                  DataBaseHandler.insertMcTopic(testTopic());
                },
                icon: const Icon(Icons.home),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
