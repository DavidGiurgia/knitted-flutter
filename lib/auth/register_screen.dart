import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:zic_flutter/core/providers/user_provider.dart';
import 'package:zic_flutter/tabs/tabs_layout.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final TextEditingController _fullnameController = TextEditingController();
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool _loading = false;

  void _register() async {
    final userProvider = Provider.of<UserProvider>(context, listen: false);

    setState(() => _loading = true);

    if (_emailController.text.isEmpty || _passwordController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please fill in all fields")),
      );
      setState(() => _loading = false);
      return;
    }

    bool success = await userProvider.register(
      _fullnameController.text.trim(),
      _usernameController.text.trim(),
      _emailController.text.trim(),
      _passwordController.text.trim(),
    );

    setState(() => _loading = false);

     if (success) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const TabsLayout()),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Register failed", style: TextStyle(color: Colors.red)),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            TextField(
              controller: _fullnameController,
              decoration: const InputDecoration(labelText: "Full Name"),
            ),
            TextField(
              controller: _usernameController,
              decoration: const InputDecoration(labelText: "Username"),
            ),
            TextField(
              controller: _emailController,
              decoration: const InputDecoration(labelText: "Email"),
            ),
            TextField(
              controller: _passwordController,
              decoration: const InputDecoration(labelText: "Password"),
            ),
            const SizedBox(height: 20),
            _loading
                ? const CircularProgressIndicator()
                : ElevatedButton(
                  onPressed: _register,
                  child: const Text("Sign Up"),
                ),

            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text(
                "Create new account",
                style: TextStyle(fontSize: 18),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
