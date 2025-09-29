import 'package:flutter/material.dart';
import '../services/api_service.dart';
import '../model/user.dart';
import 'home_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen>
    with SingleTickerProviderStateMixin {
  final TextEditingController nikController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final ApiService api = ApiService();

  bool isLoading = false;
  bool _obscurePassword = true;

  late AnimationController _controller;
  late Animation<Offset> _logoSlide;
  late Animation<double> _formFade;

  @override
  void initState() {
    super.initState();

    // Animation controller untuk mengatur durasi animasi
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );

    // Animasi slide untuk logo
    _logoSlide = Tween<Offset>(
      begin: const Offset(0, -0.2), // mulai agak ke atas
      end: Offset.zero,             // posisi normal
    ).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOut),
    );

    // Animasi fade untuk form
    _formFade = CurvedAnimation(
      parent: _controller,
      curve: const Interval(0.3, 1.0, curve: Curves.easeIn),
    );

    // Jalankan animasi setelah widget ter-build
    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    nikController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  Future<void> _login() async {
    setState(() => isLoading = true);

    try {
      final response = await api.post('/login', {
        "nik": nikController.text,
        "password": passwordController.text,
      });

      final user = User.fromJson(response['user']);

      if (!mounted) return;
      Navigator.pushReplacement(
        context,
        PageRouteBuilder(
          transitionDuration: const Duration(milliseconds: 500),
          pageBuilder: (_, __, ___) => AbsensiHomeScreen(user: user),
          transitionsBuilder: (_, animation, __, child) {
            // Transisi fade saat berpindah halaman
            return FadeTransition(opacity: animation, child: child);
          },
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text("Login gagal: $e")));
    } finally {
      setState(() => isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            children: [
              const Expanded(flex: 1, child: SizedBox()),

              // Logo dengan animasi slide + fade
              SlideTransition(
                position: _logoSlide,
                child: FadeTransition(
                  opacity: _formFade,
                  child: Container(
                    height: MediaQuery.of(context).size.height * 0.25,
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: Colors.blue.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: const Icon(
                      Icons.business,
                      size: 80,
                      color: Color(0xFF1565C0),
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 24),

              // Welcome text
              FadeTransition(
                opacity: _formFade,
                child: const Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Welcome to",
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w400,
                        color: Colors.black87,
                      ),
                    ),
                    Text(
                      "Attendance App",
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 32),

              // Login form
              FadeTransition(
                opacity: _formFade,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      "Login",
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                      ),
                    ),
                    const SizedBox(height: 24),

                    // NIK TextField
                    _buildTextField(
                      controller: nikController,
                      label: "NIK",
                      obscure: false,
                    ),
                    const SizedBox(height: 16),

                    // Password TextField
                    _buildTextField(
                      controller: passwordController,
                      label: "Password",
                      obscure: _obscurePassword,
                      suffixIcon: IconButton(
                        icon: Icon(
                          _obscurePassword
                              ? Icons.visibility_off
                              : Icons.visibility,
                          color: Colors.grey,
                        ),
                        onPressed: () {
                          setState(() => _obscurePassword = !_obscurePassword);
                        },
                      ),
                    ),

                    const SizedBox(height: 24),

                    // Login Button dengan animasi switcher loading
                    SizedBox(
                      width: double.infinity,
                      height: 48,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF1565C0),
                          foregroundColor: Colors.white,
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        onPressed: isLoading ? null : _login,
                        child: AnimatedSwitcher(
                          duration: const Duration(milliseconds: 300),
                          transitionBuilder: (child, anim) =>
                              FadeTransition(opacity: anim, child: child),
                          child: isLoading
                              ? const SizedBox(
                                  key: ValueKey("loading"),
                                  width: 20,
                                  height: 20,
                                  child: CircularProgressIndicator(
                                    color: Colors.white,
                                    strokeWidth: 2,
                                  ),
                                )
                              : const Text(
                                  key: ValueKey("text"),
                                  "Login",
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 16),

              // Forgot Password
              FadeTransition(
                opacity: _formFade,
                child: TextButton(
                  onPressed: () {
                    // TODO: Forgot password functionality
                  },
                  child: Text(
                    "Forgot password?",
                    style: TextStyle(
                      color: Colors.grey[600],
                      fontSize: 14,
                      decoration: TextDecoration.underline,
                    ),
                  ),
                ),
              ),

              const Expanded(flex: 1, child: SizedBox()),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required bool obscure,
    Widget? suffixIcon,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: TextField(
        controller: controller,
        obscureText: obscure,
        decoration: InputDecoration(
          labelText: label,
          labelStyle: const TextStyle(color: Colors.grey),
          border: InputBorder.none,
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
          suffixIcon: suffixIcon,
        ),
        style: const TextStyle(fontSize: 16),
      ),
    );
  }
}
