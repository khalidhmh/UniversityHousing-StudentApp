import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'home_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> with SingleTickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final _studentIdController = TextEditingController();
  final _passwordController = TextEditingController();
  
  bool _isLoading = false;
  bool _isPasswordVisible = false;
  
  // التعديل هنا: خليناهم يقبلوا null (?) عشان لو الـ initState متعملش
  AnimationController? _animationController;
  Animation<double>? _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    );
    _fadeAnimation = CurvedAnimation(parent: _animationController!, curve: Curves.easeOut);
    _animationController?.forward();
  }

  @override
  void dispose() {
    _animationController?.dispose();
    _studentIdController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _handleLogin() async {
    if (_formKey.currentState!.validate()) {
      setState(() => _isLoading = true);

      // محاكاة الاتصال
      await Future.delayed(const Duration(seconds: 2));

      if (mounted) {
        setState(() => _isLoading = false);
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (context) => const HomeScreen()),
          (route) => false,
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF001F3F),
      body: Stack(
        children: [
          Positioned.fill(
            child: Image.network(
              'https://images.unsplash.com/photo-1568831550712-30cf1c5e49e6?q=80&w=1080&auto=format&fit=crop',
              fit: BoxFit.cover,
              color: const Color(0xFF001F3F).withOpacity(0.85),
              colorBlendMode: BlendMode.darken,
            ),
          ),
          Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24.0),
              child: Opacity(
                opacity: _animationController != null ? 1.0 : 1.0,
                child: AnimatedBuilder(
                  animation: _animationController ?? const AlwaysStoppedAnimation(1.0),
                  builder: (context, child) {
                    return Opacity(
                      opacity: _fadeAnimation?.value ?? 0.0,
                      child: child,
                    );
                  },
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 400),
                    child: Form(
                      key: _formKey,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Container(
                            padding: const EdgeInsets.all(20),
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              border: Border.all(color: Colors.white24, width: 2),
                              boxShadow: [
                                BoxShadow(color: Colors.black.withOpacity(0.2), blurRadius: 20, spreadRadius: 5)
                              ],
                            ),
                            child: const Icon(Icons.school, size: 60, color: Colors.white),
                          ),
                          const SizedBox(height: 20),
                          Text(
                            "CAPITAL UNIVERSITY",
                            style: GoogleFonts.cairo(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                              letterSpacing: 1.5,
                            ),
                          ),
                          Text(
                            "جامعة العاصمة",
                            style: GoogleFonts.cairo(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: const Color(0xFFF2C94C),
                            ),
                          ),
                          const SizedBox(height: 5),
                          Text(
                            "University Housing App",
                            style: GoogleFonts.cairo(
                              fontSize: 12,
                              color: Colors.white70,
                            ),
                          ),
                          const SizedBox(height: 50),
                          _buildGlassTextField(
                            controller: _studentIdController,
                            label: "رقم الطالب / Student ID",
                            icon: Icons.person_outline,
                            keyboardType: TextInputType.number,
                            validator: (value) {
                              if (value == null || value.length < 6) return 'يجب أن يكون الرقم 6 خانات على الأقل';
                              return null;
                            },
                          ),
                          const SizedBox(height: 20),
                          _buildGlassTextField(
                            controller: _passwordController,
                            label: "كلمة المرور / Password",
                            icon: Icons.lock_outline,
                            isPassword: true,
                            isPasswordVisible: _isPasswordVisible,
                            onVisibilityToggle: () {
                              setState(() {
                                _isPasswordVisible = !_isPasswordVisible;
                              });
                            },
                            validator: (value) {
                              if (value == null || value.isEmpty) return 'يرجى إدخال كلمة المرور';
                              return null;
                            },
                          ),
                          const SizedBox(height: 15),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Row(
                                children: [
                                  SizedBox(
                                    height: 24,
                                    width: 24,
                                    child: Checkbox(
                                      value: true,
                                      onChanged: (v) {},
                                      activeColor: const Color(0xFFF2C94C),
                                      checkColor: const Color(0xFF001F3F),
                                      side: const BorderSide(color: Colors.white54),
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  Text("تذكرني", style: GoogleFonts.cairo(color: Colors.white70, fontSize: 12)),
                                ],
                              ),
                              TextButton(
                                onPressed: () {},
                                child: Text(
                                  "نسيت كلمة المرور؟",
                                  style: GoogleFonts.cairo(color: const Color(0xFFF2C94C), fontSize: 12),
                                ),
                              )
                            ],
                          ),
                          const SizedBox(height: 30),
                          SizedBox(
                            width: double.infinity,
                            height: 55,
                            child: ElevatedButton(
                              onPressed: _isLoading ? null : _handleLogin,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFFF2C94C),
                                foregroundColor: const Color(0xFF001F3F),
                                elevation: 5,
                                shadowColor: const Color(0xFFF2C94C).withOpacity(0.4),
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                              ),
                              child: _isLoading
                                  ? const SizedBox(height: 24, width: 24, child: CircularProgressIndicator(strokeWidth: 2, color: Color(0xFF001F3F)))
                                  : Row(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: [
                                        Text("تسجيل الدخول", style: GoogleFonts.cairo(fontSize: 16, fontWeight: FontWeight.bold)),
                                        const SizedBox(width: 10),
                                        const Icon(Icons.arrow_forward_rounded, size: 20),
                                      ],
                                    ),
                            ),
                          ),
                          const SizedBox(height: 40),
                          Text(
                            "© 2026 Capital University. All rights reserved.",
                            style: GoogleFonts.cairo(color: Colors.white30, fontSize: 10),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGlassTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    bool isPassword = false,
    bool isPasswordVisible = false,
    VoidCallback? onVisibilityToggle,
    TextInputType keyboardType = TextInputType.text,
    String? Function(String?)? validator,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.1),
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: Colors.white.withOpacity(0.2)),
      ),
      child: TextFormField(
        controller: controller,
        obscureText: isPassword && !isPasswordVisible,
        keyboardType: keyboardType,
        style: GoogleFonts.cairo(color: Colors.white),
        cursorColor: const Color(0xFFF2C94C),
        validator: validator,
        decoration: InputDecoration(
          labelText: label,
          labelStyle: GoogleFonts.cairo(color: Colors.white60),
          prefixIcon: Icon(icon, color: Colors.white70),
          suffixIcon: isPassword
              ? IconButton(
                  icon: Icon(
                    isPasswordVisible ? Icons.visibility_outlined : Icons.visibility_off_outlined,
                    color: Colors.white54,
                  ),
                  onPressed: onVisibilityToggle,
                )
              : null,
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          errorStyle: GoogleFonts.cairo(color: const Color(0xFFFF6B6B)),
        ),
      ),
    );
  }
}