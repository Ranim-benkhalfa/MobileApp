import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../app_router.dart';
import '../services/database_helper.dart';

// Écran de connexion
class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final emailController = TextEditingController();     // controller pour l'email
  final passwordController = TextEditingController();  // controller pour le mot de passe
  final _formKey = GlobalKey<FormState>();             // clé pour valider le formulaire
  bool _isLoading = false;                             // pour afficher le loader

  @override
  void dispose() {
    // libération des controllers pour éviter fuite mémoire
    emailController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  // Fonction de connexion
  void _login() async {
    if (!_formKey.currentState!.validate()) return; // si formulaire non valide, on arrête

    setState(() => _isLoading = true); // afficher loader

    await Future.delayed(const Duration(seconds: 1)); // petit délai pour montrer loader

    // 🔥 Vérification dans SQLite
    final success = await DatabaseHelper()
        .loginUser(emailController.text, passwordController.text);

    if (!success) {
      // affichage message erreur si email ou mot de passe incorrect
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Email ou mot de passe incorrect'),
          backgroundColor: Colors.red,
        ),
      );
      setState(() => _isLoading = false); // cacher loader
      return;
    }

    // Connexion réussie
    await AppRouter.authNotifier.login();
    if (mounted) context.go('/dashboard'); // aller à l'écran dashboard

    setState(() => _isLoading = false); // cacher loader
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Padding(
        padding: const EdgeInsets.all(20.0), // marge autour du contenu
        child: Center(
          child: SingleChildScrollView(
            child: Form(
              key: _formKey, // clé du formulaire
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Titre
                  const Text(
                    'Hello Jasmin\'s',
                    style: TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                      color: Colors.pink,
                    ),
                  ),
                  const SizedBox(height: 40),
                  // Champ email
                  TextFormField(
                    controller: emailController,
                    keyboardType: TextInputType.emailAddress, // clavier adapté
                    decoration: InputDecoration(
                      prefixIcon: const Icon(Icons.email, color: Colors.pink),
                      hintText: 'Email',
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(20)),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(20),
                        borderSide:
                        const BorderSide(color: Colors.pink, width: 2),
                      ),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Veuillez entrer votre email';
                      }
                      if (!value.contains('@')) {
                        return 'Email non valide';
                      }
                      return null; // valide
                    },
                  ),
                  const SizedBox(height: 15),
                  // Champ mot de passe
                  TextFormField(
                    controller: passwordController,
                    obscureText: true, // cacher le mot de passe
                    decoration: InputDecoration(
                      prefixIcon: const Icon(Icons.lock, color: Colors.pink),
                      hintText: 'Mot de passe',
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(20)),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(20),
                        borderSide:
                        const BorderSide(color: Colors.pink, width: 2),
                      ),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Veuillez entrer votre mot de passe';
                      }
                      if (value.length < 6) {
                        return 'Mot de passe trop court';
                      }
                      return null; // valide
                    },
                  ),
                  const SizedBox(height: 30),
                  // Bouton se connecter
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: _isLoading ? null : _login, // désactivé si loading
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.pink,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20)),
                      ),
                      child: _isLoading
                          ? const CircularProgressIndicator(color: Colors.white) // loader
                          : const Text('Se connecter',
                          style:
                          TextStyle(fontSize: 18, color: Colors.white)),
                    ),
                  ),
                  const SizedBox(height: 20),
                  // Bouton pour aller à l'écran inscription
                  TextButton(
                    onPressed: () => context.go('/register'),
                    child: const Text(
                      "Pas de compte ? Créer un compte",
                      style: TextStyle(color: Colors.pink, fontSize: 16),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
