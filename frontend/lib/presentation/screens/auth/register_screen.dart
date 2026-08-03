import 'package:flutter/material.dart';
import 'package:glassmorphism/glassmorphism.dart';
import 'package:animate_do/animate_do.dart';
import '../../../data/services/supabase_auth_service.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/optimized_theme.dart';
import '../../theme/glass_theme.dart';
import 'login_screen.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final _authService = SupabaseAuthService();
  bool _isLoading = false;

  Future<void> _register() async {
    if (_passwordController.text != _confirmPasswordController.text) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Las contraseñas no coinciden',
              style: OptimizedTheme.bodyText),
          backgroundColor: Colors.redAccent,
        ),
      );
      return;
    }

    if (_passwordController.text.length < 6) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('La contraseña debe tener al menos 6 caracteres',
              style: OptimizedTheme.bodyText),
          backgroundColor: Colors.redAccent,
        ),
      );
      return;
    }

    if (_nameController.text.trim().isEmpty ||
        _emailController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Todos los campos son obligatorios',
              style: OptimizedTheme.bodyText),
          backgroundColor: Colors.redAccent,
        ),
      );
      return;
    }

    setState(() => _isLoading = true);

    final success = await _authService.register(
      _emailController.text.trim(),
      _passwordController.text,
      _nameController.text.trim(),
    );

    setState(() => _isLoading = false);

    if (success && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Registro exitoso', style: OptimizedTheme.bodyText),
          backgroundColor: GlassTheme.successColor,
        ),
      );
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const LoginScreen()),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
              'Error en el registro. Verifica tu conexión y configuración de Supabase',
              style: OptimizedTheme.bodyText),
          backgroundColor: Colors.redAccent,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          image: DecorationImage(
            image: AssetImage('assets/images/vision.jpg'),
            fit: BoxFit.cover,
          ),
        ),
        child: Container(
          // Sin overlay azul, solo la imagen de fondo
          child: SafeArea(
            child: LayoutBuilder(
              builder: (context, constraints) {
                if (constraints.maxWidth > 900) {
                  return _buildWebLayout();
                } else {
                  return _buildMobileLayout();
                }
              },
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildWebLayout() {
    return Row(
      children: [
        // Left Side - Mission/Vision
        Expanded(
          flex: 3,
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(60),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _buildLogo(),
                  const SizedBox(height: 60),
                  _buildMissionVision(),
                ],
              ),
            ),
          ),
        ),
        // Right Side - Register Form
        Expanded(
          flex: 2,
          child: Center(
            child: SingleChildScrollView(
              child: Container(
                width: 450,
                padding: const EdgeInsets.all(40),
                margin: const EdgeInsets.all(40),
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.3),
                  borderRadius: BorderRadius.circular(30),
                  border: Border.all(color: Colors.white.withOpacity(0.1)),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.3),
                      blurRadius: 30,
                      spreadRadius: 10,
                    ),
                  ],
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    _buildHeader(),
                    const SizedBox(height: 30),
                    _buildFormFields(),
                  ],
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildMobileLayout() {
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            _buildMissionVision(),
            const SizedBox(height: 40),
            _buildForm(),
          ],
        ),
      ),
    );
  }

  Widget _buildLogo() {
    return FadeInDown(
      child: Container(
        width: 160,
        height: 160,
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.1),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: Colors.white.withOpacity(0.2)),
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(12),
          child: Image.asset(
            'assets/images/logo.jpeg',
            fit: BoxFit.contain,
            errorBuilder: (_, __, ___) =>
                const Icon(Icons.school, size: 80, color: Colors.white),
          ),
        ),
      ),
    );
  }

  Widget _buildMissionVision() {
    return FadeInLeft(
      child: GlassmorphicContainer(
        width: 600,
        height: 350,
        borderRadius: 20,
        blur: 20,
        alignment: Alignment.center,
        border: 2,
        linearGradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Colors.white.withOpacity(0.1),
            Colors.white.withOpacity(0.05),
          ],
        ),
        borderGradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            GlassTheme.neonCyan.withOpacity(0.5),
            GlassTheme.neonPurple.withOpacity(0.5),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.all(40),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                'NUESTRA MISIÓN',
                style: OptimizedTheme.heading3.copyWith(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: GlassTheme.neonCyan,
                  letterSpacing: 1.2,
                ),
              ),
              const SizedBox(height: 16),
              Text(
                'Formar profesionales de excelencia enfocados en Ciencia, Tecnología y Sociedad.',
                textAlign: TextAlign.center,
                style: OptimizedTheme.bodyText.copyWith(
                  fontSize: 15,
                  color: Colors.white.withOpacity(0.9),
                  height: 1.5,
                ),
              ),
              const SizedBox(height: 32),
              Text(
                'NUESTRA VISIÓN',
                style: OptimizedTheme.heading3.copyWith(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: GlassTheme.neonPurple,
                  letterSpacing: 1.2,
                ),
              ),
              const SizedBox(height: 16),
              Text(
                'Al 2027 el Instituto Superior Tecnológico de Turismo y Patrimonio Yavirac será una institución de vanguardia en la formación tecnológica y conservación del patrimonio.',
                textAlign: TextAlign.center,
                style: OptimizedTheme.bodyText.copyWith(
                  fontSize: 15,
                  color: Colors.white.withOpacity(0.9),
                  height: 1.5,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return FadeInDown(
      child: Column(
        children: [
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              gradient: AppColors.avatarGradient,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: AppColors.yaviracOrange.withOpacity(0.3),
                  blurRadius: 20,
                  spreadRadius: 3,
                ),
              ],
            ),
            child: const Icon(Icons.person_add, size: 40, color: Colors.white),
          ),
          const SizedBox(height: 16),
          Text(
            'CREAR CUENTA',
            style: OptimizedTheme.heading2.copyWith(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              letterSpacing: 2,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Únete a la biblioteca del futuro',
            style: OptimizedTheme.bodyTextSmall,
          ),
        ],
      ),
    );
  }

  Widget _buildForm() {
    return FadeInUp(
      child: Container(
        padding: const EdgeInsets.all(30),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Colors.white.withOpacity(0.1),
              Colors.white.withOpacity(0.05),
            ],
          ),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: AppColors.yaviracOrange.withOpacity(0.3),
            width: 1,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.3),
              blurRadius: 20,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: Column(
          children: [
            _buildHeader(),
            const SizedBox(height: 30),
            _buildFormFields(),
          ],
        ),
      ),
    );
  }

  Widget _buildFormFields() {
    return Column(
      children: [
        _buildInput(
            _nameController, 'Nombre completo', Icons.person_outline, 0),
        const SizedBox(height: 16),
        _buildInput(_emailController, 'Email', Icons.alternate_email, 100),
        const SizedBox(height: 16),
        _buildInput(_passwordController, 'Contraseña', Icons.lock_outline, 200,
            obscure: true),
        const SizedBox(height: 16),
        _buildInput(_confirmPasswordController, 'Confirmar contraseña',
            Icons.lock_outline, 300,
            obscure: true),
        const SizedBox(height: 30),
        _buildRegisterButton(),
        const SizedBox(height: 20),
        _buildLoginLink(),
      ],
    );
  }

  Widget _buildInput(
      TextEditingController controller, String label, IconData icon, int delay,
      {bool obscure = false}) {
    return FadeInLeft(
      delay: Duration(milliseconds: delay),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: AppColors.yaviracOrange.withOpacity(0.3),
          ),
          boxShadow: [
            BoxShadow(
              color: AppColors.yaviracOrange.withOpacity(0.1),
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: TextField(
          controller: controller,
          obscureText: obscure,
          style: OptimizedTheme.bodyText.copyWith(fontSize: 14),
          decoration: InputDecoration(
            labelText: label,
            labelStyle: OptimizedTheme.bodyTextSmall.copyWith(fontSize: 12),
            prefixIcon: Icon(icon, color: AppColors.yaviracOrange, size: 20),
            filled: true,
            fillColor: Colors.black.withOpacity(0.3),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide.none,
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide:
                  const BorderSide(color: AppColors.yaviracOrange, width: 2),
            ),
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          ),
        ),
      ),
    );
  }

  Widget _buildRegisterButton() {
    return FadeInUp(
      delay: const Duration(milliseconds: 400),
      child: Container(
        width: double.infinity,
        height: 50,
        decoration: BoxDecoration(
          gradient: AppColors.sidebarGradient,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: AppColors.yaviracOrange.withOpacity(0.4),
              blurRadius: 12,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: _isLoading ? null : _register,
            borderRadius: BorderRadius.circular(12),
            child: Center(
              child: _isLoading
                  ? const CircularProgressIndicator(
                      color: Colors.white, strokeWidth: 2)
                  : Text(
                      'REGISTRARSE',
                      style: OptimizedTheme.bodyText.copyWith(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 1,
                      ),
                    ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildLoginLink() {
    return FadeInUp(
      delay: const Duration(milliseconds: 500),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Text(
            '¿Ya tienes cuenta? ',
            style: OptimizedTheme.bodyTextSmall,
          ),
          TextButton(
            onPressed: () => Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => const LoginScreen()),
            ),
            child: Text(
              'Inicia sesión',
              style: OptimizedTheme.bodyText.copyWith(
                color: AppColors.yaviracOrange,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
