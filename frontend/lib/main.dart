import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:provider/provider.dart';
import 'core/constants/app_constants.dart';
import 'core/theme/optimized_theme.dart';
import 'core/providers/theme_provider.dart';
import 'data/api/api_client.dart';
import 'data/services/supabase_auth_service.dart';
import 'presentation/screens/auth/login_screen.dart';
import 'presentation/screens/auth/reset_password_screen.dart';
import 'presentation/screens/user/user_home.dart';
import 'presentation/screens/splash/splash_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Cargar el token guardado (si lo hay) antes de mostrar la app.
  try {
    await ApiClient.instance.init();
  } catch (e) {
    print('Error initializing API client: $e');
  }

  runApp(const AppState());
}

class AppState extends StatelessWidget {
  const AppState({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => ThemeProvider()),
      ],
      child: const BibliotecaDigitalApp(),
    );
  }
}

class BibliotecaDigitalApp extends StatefulWidget {
  const BibliotecaDigitalApp({super.key});

  @override
  State<BibliotecaDigitalApp> createState() => _BibliotecaDigitalAppState();
}

class _BibliotecaDigitalAppState extends State<BibliotecaDigitalApp> {
  final _navigatorKey = GlobalKey<NavigatorState>();
  bool _isCheckingSession = true;
  bool _showSplash = !kIsWeb; // Solo mostrar splash en móvil
  Widget _initialScreen = const LoginScreen();

  @override
  void initState() {
    super.initState();
    _checkSession();
  }

  Future<void> _checkSession() async {
    try {
      final auth = SupabaseAuthService();
      final ok = await auth.restoreSession();
      if (ok) {
        setState(() {
          _initialScreen = UserHome(authService: auth);
          _isCheckingSession = false;
        });
        return;
      }
    } catch (e) {
      print('Error checking session: $e');
      // Continuar con login screen si hay error
    }

    setState(() {
      _isCheckingSession = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final browserUri = Uri.base.fragment.startsWith('/')
        ? Uri.tryParse(Uri.base.fragment) ?? Uri.base
        : Uri.base;
    final isResetPasswordLink = kIsWeb &&
        browserUri.pathSegments.isNotEmpty &&
        browserUri.pathSegments.last == 'reset-password';
    final resetToken = isResetPasswordLink
        ? browserUri.queryParameters['token']
        : null;

    return MaterialApp(
      navigatorKey: _navigatorKey,
      title: AppConstants.appName,
      debugShowCheckedModeBanner: false,
      theme: OptimizedTheme.lightTheme,
      darkTheme: OptimizedTheme.darkTheme,
      themeMode: themeProvider.themeMode,
      // Conserva la ruta del enlace enviado por correo en Flutter web.
      initialRoute: isResetPasswordLink ? '/reset-password' : '/',
      routes: {
        '/': (context) => _showSplash
            ? SplashScreen(
                onComplete: () {
                  setState(() {
                    _showSplash = false;
                  });
                },
              )
            : _isCheckingSession
                ? Scaffold(
                    backgroundColor: themeProvider.isDarkMode ? const Color(0xFF0F172A) : const Color(0xFFF1F5F9),
                    body: Center(
                      child: CircularProgressIndicator(
                        color: themeProvider.isDarkMode ? Colors.white : OptimizedTheme.primaryColor,
                      ),
                    ),
                  )
                : _initialScreen,
        '/login': (context) => const LoginScreen(),
        '/reset-password': (context) => ResetPasswordScreen(token: resetToken),
      },
      onGenerateRoute: (settings) {
        // Manejar rutas con parámetros
        if (settings.name?.startsWith('/reset-password') == true) {
          final routeUri = Uri.tryParse(settings.name!);
          return MaterialPageRoute(
            builder: (context) => ResetPasswordScreen(
              token: routeUri?.queryParameters['token'] ?? resetToken,
            ),
          );
        }
        return null;
      },
      builder: (context, child) {
        return MediaQuery(
          data: MediaQuery.of(context).copyWith(textScaler: TextScaler.noScaling),
          child: child!,
        );
      },
    );
  }
}
