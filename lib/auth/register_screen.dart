import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:zic_flutter/core/app_theme.dart';
import 'package:zic_flutter/core/providers/user_provider.dart';
import 'package:zic_flutter/tabs/tabs_layout.dart';
import 'package:zic_flutter/widgets/button.dart';

class RegisterScreen extends ConsumerStatefulWidget {
  const RegisterScreen({super.key});

  @override
  ConsumerState<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends ConsumerState<RegisterScreen> {
  final PageController _pageController = PageController();
  final TextEditingController _fullnameController = TextEditingController();
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  int _currentStep = 0;
  bool _usernameAvailable = false;

  void _checkUsernameAvailability() async {
    // Here you would typically call an API to check if username is available
    // For now, we'll just simulate a check
    setState(() {
      _usernameAvailable = _usernameController.text.trim().isNotEmpty;
    });

    if (_usernameAvailable) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
      setState(() => _currentStep++);
    }
  }

  void _register() async {
    if (_emailController.text.isEmpty || _passwordController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please fill in all fields")),
      );
      return;
    }

    ref
        .read(userProvider.notifier)
        .register(
          _fullnameController.text.trim(),
          _usernameController.text.trim(),
          _emailController.text.trim(),
          _passwordController.text.trim(),
        );
  }

  @override
  Widget build(BuildContext context) {
    final userAsync = ref.watch(userProvider);

    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: SvgPicture.asset(
          AppTheme.isDark(context)
              ? 'lib/assets/images/Knitted-white-logo.svg'
              : 'lib/assets/images/Knitted-logo.svg',
          semanticsLabel: 'App Logo',
          height: 24,
        ),
      ),
      body: SafeArea(
        child: Column(
          children: [
            

            // Page view for registration steps
            Expanded(
              child: PageView(
                controller: _pageController,
                physics: const NeverScrollableScrollPhysics(),
                children: [
                  // Step 1: Username selection
                  _buildUsernameStep(),

                  // Step 2: Email and password
                  _buildAccountStep(),

                  // Step 3: Full name and final registration
                  _buildProfileStep(userAsync),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildUsernameStep() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 32.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            'Choose your username',
            style: Theme.of(context).textTheme.headlineSmall,
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _usernameController,
            decoration: InputDecoration(
              border: const OutlineInputBorder(),
              labelText: "Username",
              suffixIcon:
                  _usernameController.text.isNotEmpty
                      ? IconButton(
                        icon: const Icon(Icons.check_circle),
                        onPressed: () {},
                      )
                      : null,
            ),
            onChanged: (value) => setState(() {}),
          ),
          const SizedBox(height: 8),
          if (_usernameController.text.isNotEmpty)
            Text(
              _usernameAvailable
                  ? 'Username available!'
                  : 'Checking availability...',
              style: TextStyle(
                color: _usernameAvailable ? Colors.green : Colors.grey,
              ),
            ),
          const SizedBox(height: 32),
          CustomButton(
            onPressed: _checkUsernameAvailability,
            text: 'Continue',
            isFullWidth: true,
            bgColor: AppTheme.primaryColor,
            isLoading: false,
            size: ButtonSize.small,
          ),
        ],
      ),
    );
  }

  Widget _buildAccountStep() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 32.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            'Create your account',
            style: Theme.of(context).textTheme.headlineSmall,
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _emailController,
            decoration: const InputDecoration(
              labelText: "Email",
              border: OutlineInputBorder(),
            ),
            keyboardType: TextInputType.emailAddress,
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _passwordController,
            decoration: const InputDecoration(
              labelText: "Password",
              border: OutlineInputBorder(),
            ),
            obscureText: true,
          ),
          const SizedBox(height: 32),
          Row(
            children: [
              IconButton(
                onPressed: () {
                  _pageController.previousPage(
                    duration: const Duration(milliseconds: 300),
                    curve: Curves.easeInOut,
                  );
                  setState(() => _currentStep--);
                },
                icon: const Icon(Icons.arrow_back),
              ),
              const SizedBox(width: 100),
              Expanded(
                child: CustomButton(
                  onPressed: () {
                    _pageController.nextPage(
                      duration: const Duration(milliseconds: 300),
                      curve: Curves.easeInOut,
                    );
                    setState(() => _currentStep++);
                  },
                  text: 'Continue',
                  isFullWidth: true,
                  bgColor: AppTheme.primaryColor,
                  size: ButtonSize.small,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildProfileStep(AsyncValue userAsync) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 32.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            'Complete your profile',
            style: Theme.of(context).textTheme.headlineSmall,
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _fullnameController,
            decoration: const InputDecoration(labelText: "Full Name"),
          ),
          const SizedBox(height: 32),
          Row(
            children: [
              IconButton(
                onPressed: () {
                  _pageController.previousPage(
                    duration: const Duration(milliseconds: 300),
                    curve: Curves.easeInOut,
                  );
                  setState(() => _currentStep--);
                },
                icon: const Icon(Icons.arrow_back),
              ),
              const SizedBox(width: 100),
              Expanded(
                child: CustomButton(
                  onPressed: _register,
                  text: 'Register',
                  isFullWidth: true,
                  bgColor: AppTheme.primaryColor,
                  isLoading: userAsync.isLoading,
                  size: ButtonSize.small,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  @override
  void didUpdateWidget(covariant RegisterScreen oldWidget) {
    final userAsync = ref.watch(userProvider);
    if (userAsync.hasValue) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const TabsLayout()),
      );
    }
    super.didUpdateWidget(oldWidget);
  }

  @override
  void dispose() {
    _pageController.dispose();
    _fullnameController.dispose();
    _usernameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }
}
