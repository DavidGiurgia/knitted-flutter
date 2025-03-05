import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:provider/provider.dart';
import 'package:zic_flutter/auth/register_screen.dart';
import 'package:zic_flutter/core/app_theme.dart';
import 'package:zic_flutter/core/providers/user_provider.dart';
import 'package:zic_flutter/tabs/tabs_layout.dart';
import 'package:zic_flutter/widgets/button.dart';
import 'package:zic_flutter/widgets/input.dart';
import 'package:zic_flutter/widgets/join_room_input.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _codeController = TextEditingController();
  bool _loading = false;
  static const String assetName = 'lib/assets/images/ZIC-logo.svg';

  void _login() async {
    final userProvider = Provider.of<UserProvider>(context, listen: false);

    setState(() => _loading = true);

    if (_emailController.text.isEmpty || _passwordController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please fill in all fields")),
      );
      setState(() => _loading = false);
      return;
    }

    bool success = await userProvider.login(
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
          content: Text("Login failed", style: TextStyle(color: Colors.red)),
        ),
      );
    }
  }

  void _joinGroup() {
    String code = _codeController.text.trim();
    if (code.length != 7) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please enter a valid code.")),
      );
      return;
    }
    print("Joining group with code: $code");
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            children: [
              // Partea de sus: Join Group
              Container(
                color: AppTheme.primaryColor,
                padding: const EdgeInsets.all(32),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Joining a private group?",
                      style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.w700,
                        color: AppTheme.backgroundColor(context),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      "No account needed",
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w500,
                        color:
                            AppTheme.isDark(context)
                                ? Colors.black54
                                : Colors.white70,
                      ),
                    ),
                    const SizedBox(height: 20),
                    JoinTemporaryRoomInput(
                      controller: _codeController,
                      onJoin: _joinGroup,
                    ),
                  ],
                ),
              ),

              // Partea de jos: Login
              Padding(
                padding: const EdgeInsets.fromLTRB(28, 60, 28, 28),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Center(
                      child: SvgPicture.asset(
                        assetName,
                        semanticsLabel: 'ZiC Logo',
                        width: 64,
                      ),
                    ),
                    const SizedBox(height: 42),
                    const Text(
                      "Log in",
                      style: TextStyle(
                        fontSize: 32,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 8),
                    CustomBorderedInput(
                      controller: _emailController,
                      hintText: "Enter your email",
                      label: "Email",
                      fontSize: 18,
                    ),
                    const SizedBox(height: 8),
                    CustomBorderedInput(
                      controller: _passwordController,
                      hintText: "Enter your password",
                      isPassword: true,
                      label: "Password",
                      fontSize: 18,
                    ),
                    const SizedBox(height: 20),
                    _loading
                        ? const Center(child: CircularProgressIndicator())
                        : CustomButton(
                          onPressed: _login,
                          text: 'Login',
                          isFullWidth: true,
                          bgColor: AppTheme.primaryColor,
                        ),
                    const SizedBox(height: 60),
                    CustomButton(
                      onPressed:
                          () => Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => const RegisterScreen(),
                            ),
                          ),
                      text: "Create new account",
                      isFullWidth: true,
                      type: ButtonType.light,
                      bgColor: AppTheme.primaryColor,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
