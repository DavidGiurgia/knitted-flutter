import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/svg.dart';
import 'package:flutter_tabler_icons/flutter_tabler_icons.dart';
import 'package:zic_flutter/auth/join_room_screen.dart';
import 'package:zic_flutter/auth/register_screen.dart';
import 'package:zic_flutter/core/app_theme.dart';
import 'package:zic_flutter/core/providers/user_provider.dart';
import 'package:zic_flutter/screens/shared/custom_toast.dart';
import 'package:zic_flutter/tabs/tabs_layout.dart';
import 'package:zic_flutter/widgets/button.dart';
import 'package:zic_flutter/widgets/input.dart';

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  void _login() async {
    if (!_formKey.currentState!.validate()) return;

    final email = _emailController.text.trim();
    final password = _passwordController.text.trim();

    final success = await ref
        .read(userProvider.notifier)
        .login(email, password);

    if (success) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const TabsLayout()),
      );
    } else {
      CustomToast.show(
        context,
        "Invalid credentials. Please try again.",
        color: Colors.red,
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

    if (userAsync.hasError) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text("Error: ${userAsync.error}")));
      });
    }

    if (userAsync.hasValue && userAsync.value != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const TabsLayout()),
        );
      });
    }

    return Scaffold(
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.symmetric(horizontal: 24),
        child: ConstrainedBox(
          constraints: BoxConstraints(
            minHeight:
                MediaQuery.of(context).size.height -
                MediaQuery.of(context).padding.top -
                kToolbarHeight,
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  const SizedBox(height: 180),
                  SvgPicture.asset(
                    AppTheme.isDark(context)
                        ? 'lib/assets/images/Knitted-white-logo.svg'
                        : 'lib/assets/images/Knitted-logo.svg',
                    semanticsLabel: 'App Logo',
                    height: 28,
                  ),
                  const SizedBox(height: 100),
      
                  Form(
                    key: _formKey,
                    child: Column(
                      children: [
                        CustomBorderedInput(
                          controller: _emailController,
                          hintText: "",
                          label: "Email",
                          fontSize: 18,
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
                        const SizedBox(height: 10),
                        CustomBorderedInput(
                          controller: _passwordController,
                          hintText: "",
                          isPassword: true,
                          label: "Password",
      
                          fontSize: 18,
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Please enter your password';
                            }
                            if (value.isEmpty) {
                              return 'Password must be at least 6 characters';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 8),
                        TextButton(
                          onPressed: () {
                            // Add forgot password functionality
                          },
                          child: Text(
                            "Forgot password?",
                            style: theme.textTheme.bodyMedium?.copyWith(
                              color: AppTheme.foregroundColor(context),
                            ),
                          ),
                        ),
                        const SizedBox(height: 24),
                        CustomButton(
                          onPressed: _login,
                          text: 'Log In',
                          isFullWidth: true,
                          bgColor: AppTheme.primaryColor,
                          isLoading: userAsync.isLoading,
                          borderRadius: 12,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              Padding(
                padding: const EdgeInsets.only(bottom: 40, top: 24),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Expanded(
                          child: Divider(
                            color: theme.dividerColor.withOpacity(0.3),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          child: Text(
                            "or continue with",
                            style: theme.textTheme.bodyMedium?.copyWith(
                              color: theme.colorScheme.onSurface.withOpacity(
                                0.5,
                              ),
                            ),
                          ),
                        ),
                        Expanded(
                          child: Divider(
                            color: theme.dividerColor.withOpacity(0.3),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        _buildSocialButton(
                          icon: TablerIcons.brand_google,
                          onPressed: () {},
                        ),
                        const SizedBox(width: 16),
                        _buildSocialButton(
                          icon: TablerIcons.brand_facebook,
                          onPressed: () {},
                        ),
                        const SizedBox(width: 16),
                        _buildSocialButton(
                          icon: TablerIcons.brand_apple,
                          onPressed: () {},
                        ),
                      ],
                    ),
                    const SizedBox(height: 32),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          "Don't have an account? ",
                          style: theme.textTheme.bodyMedium,
                        ),
                        GestureDetector(
                          onTap:
                              () => Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => const RegisterScreen(),
                                ),
                              ),
                          child: Text(
                            "Sign up",
                            style: theme.textTheme.bodyMedium?.copyWith(
                              color: AppTheme.primaryColor,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    CustomButton(
                      onPressed:
                          () => Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => const JoinRoomScreen(),
                            ),
                          ),
                      text: "Join a room",
                      isFullWidth: true,
                      type: ButtonType.bordered,
      
                      borderRadius: 12,
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

  Widget _buildSocialButton({
    required IconData icon,
    required VoidCallback onPressed,
  }) {
    return InkWell(
      onTap: onPressed,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        width: 56,
        height: 56,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: Theme.of(context).dividerColor.withOpacity(0.2),
            width: 1,
          ),
        ),
        child: Icon(icon),
      ),
    );
  }
}
