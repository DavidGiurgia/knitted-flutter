import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/svg.dart';
import 'package:zic_flutter/auth/register_screen.dart';
import 'package:zic_flutter/core/api/room_service.dart';
import 'package:zic_flutter/core/app_theme.dart';
import 'package:zic_flutter/core/providers/user_provider.dart';
import 'package:zic_flutter/screens/chats/temporary_chat_room.dart';
import 'package:zic_flutter/screens/shared/custom_toast.dart';
import 'package:zic_flutter/tabs/tabs_layout.dart';
import 'package:zic_flutter/widgets/button.dart';
import 'package:zic_flutter/widgets/input.dart';
import 'package:zic_flutter/widgets/join_room_input.dart';

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _codeController = TextEditingController();

  void _login() async {
    final email = _emailController.text.trim();
    final password = _passwordController.text.trim();
    if (email.isEmpty || password.isEmpty) {
      CustomToast.show(context, "Please fill in all fields");
      return;
    }
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

  void _joinGroup() async {
    String code = _codeController.text.trim();
    if (code.length != 7) {
      CustomToast.show(
        context,
        "Invalid code format. Code must be 7 characters.",
        color: Colors.red,
      );
      return;
    }
    final room = await RoomService.getRoomByCode(code);
    if (room == null) {
      CustomToast.show(
        context,
        'Sorry, there is no such room active right now!',
      );
      return;
    }
    // Curățăm input-ul după join.
    _codeController.clear();

    // Navighează către camera respectivă.
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => TemporaryChatRoomSection(room: room), // aici adauga un pas intermediar de setare a numelui
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final userAsync = ref.watch(userProvider);
    if (userAsync.isLoading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }
    if (userAsync.hasError) {
      // Afiseaza un mesaj de eroare daca autentificarea a esuat
      WidgetsBinding.instance.addPostFrameCallback((_) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text("Error: ${userAsync.error}")));
      });
    }
    // Check if the user is logged in and navigate to the TabsLayout
    if (userAsync.hasValue && userAsync.value != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const TabsLayout()),
        );
      });
    }
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
                        'lib/assets/images/ZIC-logo.svg',
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
                    CustomButton(
                      onPressed: _login,
                      text: 'Login',
                      isFullWidth: true,
                      bgColor: AppTheme.primaryColor,
                      isLoading: userAsync.isLoading,
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
