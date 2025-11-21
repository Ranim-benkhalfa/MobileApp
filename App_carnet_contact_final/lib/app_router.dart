import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'screens/login_screen.dart';
import 'screens/register_screen.dart';
import 'screens/dashboard_screen.dart';

// 🔐 Service simple pour gérer l'état de connexion
class AuthService {
  static const String _key = 'is_logged_in'; // clé pour SharedPreferences

  // Vérifier si l'utilisateur est connecté
  static Future<bool> isLoggedIn() async {
    final prefs = await SharedPreferences.getInstance();
    final loggedIn = prefs.getBool(_key) ?? false; // false si jamais défini
    print('🔐 Auth check: $loggedIn');
    return loggedIn;
  }

  // Marquer l'utilisateur comme connecté
  static Future<void> login() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_key, true);
    print('✅ User logged in');
  }

  // Déconnecter l'utilisateur
  static Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_key);
    print('🚪 User logged out');
  }
}

// 🔥 AuthNotifier pour GoRouter (notifie l'UI quand état change)
class AuthNotifier extends ChangeNotifier {
  bool _isLoggedIn = false; // état de connexion
  bool get isLoggedIn => _isLoggedIn;

  AuthNotifier() {
    _checkAuth(); // vérifier état au démarrage
  }

  // Vérifier état au démarrage (ici toujours false au lancement)
  Future<void> _checkAuth() async {
    _isLoggedIn = false;   // commence toujours déconnecté
    notifyListeners();     // notifier l'UI
  }

  // Connecter l'utilisateur
  Future<void> login() async {
    await AuthService.login();
    _isLoggedIn = true;
    notifyListeners(); // notifier l'UI
  }

  // Déconnecter l'utilisateur
  Future<void> logout() async {
    await AuthService.logout();
    _isLoggedIn = false;
    notifyListeners(); // notifier l'UI
  }
}

// 🛣️ Configuration du router de l'app
class AppRouter {
  static final AuthNotifier _authNotifier = AuthNotifier();

  static GoRouter get router => GoRouter(
    initialLocation: '/',             // route initiale
    refreshListenable: _authNotifier, // écoute les changements d'état

    // 🔄 Redirections automatiques selon login
    redirect: (BuildContext context, GoRouterState state) {
      final bool loggedIn = _authNotifier.isLoggedIn; // état actuel
      final String currentPath = state.uri.path;

      print('🧭 Navigation: $currentPath | Logged in: $loggedIn');

      // 1️⃣ Si connecté et sur login/register → aller au dashboard
      if (loggedIn &&
          (currentPath == '/' || currentPath == '/register')) {
        print('➡️ Redirecting to dashboard');
        return '/dashboard';
      }

      // 2️⃣ Si pas connecté et tente d'aller au dashboard → login
      if (!loggedIn && currentPath == '/dashboard') {
        print('➡️ Redirecting to login');
        return '/';
      }

      return null; // pas de redirection
    },

    // 🌐 Définition des routes
    routes: [
      GoRoute(
        path: '/',
        name: 'login',
        builder: (context, state) => const LoginScreen(),
      ),
      GoRoute(
        path: '/register',
        name: 'register',
        builder: (context, state) => const RegisterScreen(),
      ),
      GoRoute(
        path: '/dashboard',
        name: 'dashboard',
        builder: (context, state) => const DashboardScreen(),
      ),
    ],
  );

  // Getter pour notifier depuis d'autres pages
  static AuthNotifier get authNotifier => _authNotifier;
}
