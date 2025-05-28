// path screens/userinfo

import 'package:flutter/material.dart';
import 'interaction.dart';

class UserInfoScreen extends StatefulWidget {
  const UserInfoScreen({super.key});

  @override
  State<UserInfoScreen> createState() => _UserInfoScreenState();
}

class _UserInfoScreenState extends State<UserInfoScreen> {
  final _nameController = TextEditingController();
  final _ageController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.orange.shade50,
      appBar: AppBar(title: const Text("Tu aventura empieza aquí")),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          children: [
            const Text("¿Cómo te llamas?", style: TextStyle(fontSize: 20)),
            TextField(
              controller: _nameController,
              decoration: const InputDecoration(hintText: 'Tu nombre'),
            ),
            const SizedBox(height: 20),
            const Text("¿Cuántos años tienes?", style: TextStyle(fontSize: 20)),
            TextField(
              controller: _ageController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(hintText: 'Tu edad'),
            ),
            const SizedBox(height: 30),
            ElevatedButton(
              onPressed: () {
                final name = _nameController.text.trim();
                final age = _ageController.text.trim();
                if (name.isNotEmpty && age.isNotEmpty) {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => InteractionCountScreen(userName: name),
                    ),
                  );
                }
              },
              child: const Text("Continuar"),
            )
          ],
        ),
      ),
    );
  }
}
