import 'package:flutter/material.dart';
import 'core/database/database_helper.dart';
import 'theme.dart';
import 'screens/login_screen.dart';
import 'screens/first_launch_screen.dart';
import 'layouts/main_layout.dart';
import 'models/user.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  try {
    await DatabaseHelper.instance.initDatabase();
  } catch (_) {
    // On continue même si la DB échoue (sécurité)
  }

  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  bool _isDarkMode = false;

  void _toggleTheme() {
    setState(() {
      _isDarkMode = !_isDarkMode;
    });
  }

  /// Vérifie simplement si une licence existe en SQLite
  Future<bool> _hasLicense() async {
    try {
      final settings = await DatabaseHelper.instance.getAppSettings();
      return settings != null &&
          settings.license != null &&
          settings.license!.isNotEmpty;
    } catch (_) {
      return false;
    }
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Guinnermagasin - Gestion de Magasin',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: _isDarkMode ? ThemeMode.dark : ThemeMode.light,

      /// ✅ LOGIQUE DÉFINITIVE ICI
      home: FutureBuilder<bool>(
        future: _hasLicense(),
        builder: (context, snapshot) {
          // Loader simple pendant la vérification SQLite
          if (snapshot.connectionState != ConnectionState.done) {
            return const Scaffold(
              body: Center(
                child: CircularProgressIndicator(),
              ),
            );
          }

          // Licence présente → Login
          if (snapshot.data == true) {
            return const LoginScreen();
          }

          // Sinon → 6 pages de lancement
          return const FirstLaunchScreen();
        },
      ),

      onGenerateRoute: _generateRoute,
    );
  }

  Route<dynamic> _generateRoute(RouteSettings settings) {
    final routeName = settings.name;

    switch (routeName) {
      case '/login':
        return MaterialPageRoute(
          builder: (_) => const LoginScreen(),
        );

      case '/dashboard':
      case '/products':
      case '/clients':
      case '/suppliers':
      case '/sales':
      case '/purchases':
      case '/inventory':
      case '/reports':
      case '/store':
      case '/users':
        return _buildSecureRoute(settings, routeName!);

      default:
        return MaterialPageRoute(
          builder: (_) => const LoginScreen(),
        );
    }
  }

  MaterialPageRoute _buildSecureRoute(
    RouteSettings settings,
    String routeName,
  ) {
    final args = settings.arguments;

    // Sécurité : pas d'utilisateur → login
    if (args == null || args is! User) {
      return MaterialPageRoute(
        builder: (_) => const LoginScreen(),
      );
    }

    final user = args as User;

    return MaterialPageRoute(
      builder: (_) => MainLayout(
        currentUser: user,
        isDarkMode: _isDarkMode,
        onThemeToggle: _toggleTheme,
        initialRoute: routeName,
      ),
    );
  }
}
