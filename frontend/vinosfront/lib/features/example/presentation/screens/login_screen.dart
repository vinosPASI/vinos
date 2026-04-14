import 'package:flutter/material.dart';
import 'register_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final emailController = TextEditingController();
  final passwordController = TextEditingController();

  final String defaultEmail = "admin@gmail.com";
  final String defaultPassword = "12345";

  bool _obscurePassword = true;
  bool _isLoading = false;

  static const Color vinoOscuro = Color(0xFF6E3B47);
  static const Color vinoPastel = Color(0xFF8C4A5A);
  static const Color amarilloVainilla = Color(0xFFF3E5AB);
  static const Color doradoPastel = Color(0xFFE6D3A3);
  static const Color cremaClaro = Color(0xFFF8F5F0);

  void login() async {
    setState(() => _isLoading = true);
    await Future.delayed(const Duration(milliseconds: 600));
    setState(() => _isLoading = false);

    if (emailController.text == defaultEmail &&
        passwordController.text == defaultPassword) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Row(
            children: [
              Icon(Icons.check_circle_outline, color: Colors.white, size: 20),
              SizedBox(width: 10),
              Text("Bienvenido a Vinoteca"),
            ],
          ),
          backgroundColor: vinoPastel,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          margin: const EdgeInsets.all(16),
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Row(
            children: [
              Icon(Icons.error_outline, color: Colors.white, size: 20),
              SizedBox(width: 10),
              Text("Correo o contraseña incorrectos"),
            ],
          ),
          backgroundColor: const Color(0xFFB85C6E),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          margin: const EdgeInsets.all(16),
        ),
      );
    }
  }

  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: cremaClaro,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 28.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const SizedBox(height: 60),
                Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    color: amarilloVainilla,
                    borderRadius: BorderRadius.circular(24),
                    border: Border.all(color: doradoPastel, width: 1.5),
                  ),
                  child: const Icon(
                    Icons.wine_bar_rounded,
                    size: 40,
                    color: vinoPastel,
                  ),
                ),
                const SizedBox(height: 24),
                const Text(
                  "Vinoteca",
                  style: TextStyle(
                    fontSize: 34,
                    fontWeight: FontWeight.w700,
                    color: vinoOscuro,
                    letterSpacing: 1.2,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  "Inicia sesión para continuar",
                  style: TextStyle(
                    fontSize: 14,
                    color: vinoOscuro.withOpacity(0.55),
                    letterSpacing: 0.3,
                  ),
                ),
                const SizedBox(height: 48),
                Container(
                  padding: const EdgeInsets.all(28),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(24),
                    border: Border.all(color: doradoPastel, width: 1),
                    boxShadow: [
                      BoxShadow(
                        color: vinoOscuro.withOpacity(0.06),
                        blurRadius: 20,
                        offset: const Offset(0, 6),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        "Correo electrónico",
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: vinoOscuro,
                          letterSpacing: 0.4,
                        ),
                      ),
                      const SizedBox(height: 8),
                      TextField(
                        controller: emailController,
                        keyboardType: TextInputType.emailAddress,
                        style: const TextStyle(fontSize: 15, color: vinoOscuro),
                        decoration: InputDecoration(
                          hintText: "ejemplo@correo.com",
                          hintStyle: TextStyle(
                            color: vinoOscuro.withOpacity(0.35),
                            fontSize: 14,
                          ),
                          prefixIcon: Icon(
                            Icons.mail_outline_rounded,
                            color: vinoPastel.withOpacity(0.7),
                            size: 20,
                          ),
                          filled: true,
                          fillColor: cremaClaro,
                          contentPadding: const EdgeInsets.symmetric(
                              horizontal: 16, vertical: 14),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(14),
                            borderSide: BorderSide(color: doradoPastel, width: 1),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(14),
                            borderSide: BorderSide(color: doradoPastel, width: 1),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(14),
                            borderSide: const BorderSide(color: vinoPastel, width: 1.8),
                          ),
                        ),
                      ),
                      const SizedBox(height: 22),
                      const Text(
                        "Contraseña",
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: vinoOscuro,
                          letterSpacing: 0.4,
                        ),
                      ),
                      const SizedBox(height: 8),
                      TextField(
                        controller: passwordController,
                        obscureText: _obscurePassword,
                        style: const TextStyle(fontSize: 15, color: vinoOscuro),
                        decoration: InputDecoration(
                          hintText: "••••••••",
                          hintStyle: TextStyle(
                            color: vinoOscuro.withOpacity(0.35),
                            fontSize: 14,
                          ),
                          prefixIcon: Icon(
                            Icons.lock_outline_rounded,
                            color: vinoPastel.withOpacity(0.7),
                            size: 20,
                          ),
                          suffixIcon: IconButton(
                            icon: Icon(
                              _obscurePassword
                                  ? Icons.visibility_off_outlined
                                  : Icons.visibility_outlined,
                              color: vinoPastel.withOpacity(0.6),
                              size: 20,
                            ),
                            onPressed: () =>
                                setState(() => _obscurePassword = !_obscurePassword),
                          ),
                          filled: true,
                          fillColor: cremaClaro,
                          contentPadding: const EdgeInsets.symmetric(
                              horizontal: 16, vertical: 14),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(14),
                            borderSide: BorderSide(color: doradoPastel, width: 1),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(14),
                            borderSide: BorderSide(color: doradoPastel, width: 1),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(14),
                            borderSide: const BorderSide(color: vinoPastel, width: 1.8),
                          ),
                        ),
                      ),
                      const SizedBox(height: 10),
                      Align(
                        alignment: Alignment.centerRight,
                        child: TextButton(
                          onPressed: () {},
                          style: TextButton.styleFrom(
                            padding: EdgeInsets.zero,
                            minimumSize: Size.zero,
                            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                          ),
                          child: Text(
                            "¿Olvidaste tu contraseña?",
                            style: TextStyle(
                              fontSize: 12,
                              color: vinoPastel.withOpacity(0.8),
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 28),
                      SizedBox(
                        width: double.infinity,
                        height: 52,
                        child: ElevatedButton(
                          onPressed: _isLoading ? null : login,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: vinoPastel,
                            foregroundColor: Colors.white,
                            disabledBackgroundColor: vinoPastel.withOpacity(0.6),
                            elevation: 0,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(14),
                            ),
                          ),
                          child: _isLoading
                              ? const SizedBox(
                                  width: 20,
                                  height: 20,
                                  child: CircularProgressIndicator(
                                    color: Colors.white,
                                    strokeWidth: 2.2,
                                  ),
                                )
                              : const Text(
                                  "Iniciar sesión",
                                  style: TextStyle(
                                    fontSize: 15,
                                    fontWeight: FontWeight.w600,
                                    letterSpacing: 0.5,
                                  ),
                                ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 32),
                Row(
                  children: [
                    Expanded(child: Divider(color: doradoPastel, thickness: 1)),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      child: Text(
                        "¿Nuevo en Vinoteca?",
                        style: TextStyle(
                          fontSize: 12,
                          color: vinoOscuro.withOpacity(0.45),
                        ),
                      ),
                    ),
                    Expanded(child: Divider(color: doradoPastel, thickness: 1)),
                  ],
                ),
                const SizedBox(height: 16),
                SizedBox(
                  width: double.infinity,
                  height: 52,
                  child: OutlinedButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => const RegisterScreen()),
                      );
                    },
                    style: OutlinedButton.styleFrom(
                      foregroundColor: vinoPastel,
                      side: const BorderSide(color: vinoPastel, width: 1.5),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                    child: const Text(
                      "Crear cuenta",
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 40),
              ],
            ),
          ),
        ),
      ),
    );
  }
}