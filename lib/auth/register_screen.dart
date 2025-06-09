import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:zic_flutter/core/app_theme.dart';
import 'package:zic_flutter/core/providers/user_provider.dart';
import 'package:zic_flutter/tabs/tabs_layout.dart';
import 'package:zic_flutter/widgets/button.dart';
import 'package:zic_flutter/widgets/input.dart';

class RegisterScreen extends ConsumerStatefulWidget {
  const RegisterScreen({super.key});

  @override
  ConsumerState<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends ConsumerState<RegisterScreen> {
  final TextEditingController _fullnameController = TextEditingController();
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool _usernameAvailable = false;
  bool _isCheckingUsername = false;

  Future<void> _checkUsernameAvailability() async {
    if (_usernameController.text.trim().isEmpty) return;

    setState(() => _isCheckingUsername = true);
    await Future.delayed(const Duration(seconds: 1)); // Simulate API call

    setState(() {
      _usernameAvailable = _usernameController.text.trim().isNotEmpty;
      //check if username is available
      _isCheckingUsername = false;
    });
  }

  void _register() async {
    if (!_formKey.currentState!.validate() ||
        _isCheckingUsername ||
        !_usernameAvailable) {
      return;
    }

    final success = await ref
        .read(userProvider.notifier)
        .register(
          _fullnameController.text.trim(),
          _usernameController.text.trim(),
          _emailController.text.trim(),
          _passwordController.text.trim(),
        );

    if (success && mounted) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const TabsLayout()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final userAsync = ref.watch(userProvider);
    final theme = Theme.of(context);

    if (userAsync.isLoading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        automaticallyImplyLeading: true,
        title: SvgPicture.asset(
          AppTheme.isDark(context)
              ? 'lib/assets/images/Troop-white.svg'
              : 'lib/assets/images/Troop-black.svg',
          semanticsLabel: 'App Logo',
          height: 24,
        ),
      ),
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.symmetric(horizontal: 24),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 40),
              // Text(
              //   "Create your account",
              //   style: theme.textTheme.headlineMedium?.copyWith(
              //     fontWeight: FontWeight.w700,
              //   ),
              // ),
              // const SizedBox(height: 8),
              Text(
                "Join our community today",

                style: TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.w600,
                  color:
                      AppTheme.isDark(context)
                          ? Colors.grey[200]
                          : Colors.grey[900],
                ),
              ),
              const SizedBox(height: 40),
              CustomBorderedInput(
                controller: _fullnameController,
                hintText: "Enter your full name",
                label: "Full Name",
                prefixIcon: Icons.person_outline,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter your name';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              CustomBorderedInput(
                controller: _usernameController,
                hintText: "Choose a username",
                label: "Username",
                prefixIcon: Icons.alternate_email,

                onChanged: (value) async {
                  await _checkUsernameAvailability();
                },
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please choose a username';
                  }
                  if (!_usernameAvailable) {
                    return 'Please check username availability';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              CustomBorderedInput(
                controller: _emailController,
                hintText: "Enter your email",
                label: "Email",
                prefixIcon: Icons.email_outlined,
                keyboardType: TextInputType.emailAddress,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter your email';
                  }
                  if (!value.contains('@')) {
                    return 'Please enter a valid email';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              CustomBorderedInput(
                controller: _passwordController,
                hintText: "Create a password",
                label: "Password",
                prefixIcon: Icons.lock_outline,
                isPassword: true,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a password';
                  }
                  if (value.length < 6) {
                    return 'Password must be at least 6 characters';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 32),
              CustomButton(
                onPressed: _register,
                text: 'Register',
                isFullWidth: true,
                bgColor: AppTheme.foregroundColor(context),
                isLoading: userAsync.isLoading,
                borderRadius: 12,
              ),
              const SizedBox(height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    "Already have an account? ",
                    style: theme.textTheme.bodyMedium,
                  ),
                  GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: Text(
                      "Log in",
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: AppTheme.primaryColor,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _fullnameController.dispose();
    _usernameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }
}
