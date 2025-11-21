import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../services/database_helper.dart';

// Écran d'inscription pour créer un nouveau compte
class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();           // clé pour valider le formulaire
  final nameController = TextEditingController();    // controller pour le nom
  final emailController = TextEditingController();   // controller pour l'email
  final passwordController = TextEditingController();// controller pour le mot de passe
  bool _isLoading = false;                            // pour afficher le loader pendant l'inscription

  @override
  void dispose() {
    // libération des controllers pour éviter fuite mémoire
    nameController.dispose();
    emailController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  // Fonction pour enregistrer l'utilisateur
  void _register() async {
    if (!_formKey.currentState!.validate()) return; // si formulaire non valide, on arrête

    setState(() => _isLoading = true); // afficher loader

    try {
      // insertion dans la base de données SQLite
      await DatabaseHelper().insertUser(
          nameController.text, emailController.text, passwordController.text);

      if (!mounted) return;

      // affichage message succès
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Compte créé avec succès ! Bienvenue"),
          backgroundColor: Colors.green,
        ),
      );

      // Retour directement à la page Login après inscription
      context.go('/');
    } catch (e) {
      // affichage message erreur si email déjà utilisé
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Erreur: Email déjà utilisé"),
          backgroundColor: Colors.red,
        ),
      );
    }

    setState(() => _isLoading = false); // cacher loader
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Créer un compte'),
        backgroundColor: Colors.pink,
        foregroundColor: Colors.white,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.go('/'), // bouton retour vers Login
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20), // marge autour du contenu
        child: SingleChildScrollView(
          child: Form(
            key: _formKey, // clé du formulaire
            child: Column(
              children: [
                const SizedBox(height: 20),
                // Champ Nom complet
                TextFormField(
                  controller: nameController,
                  decoration: InputDecoration(
                    prefixIcon: const Icon(Icons.person, color: Colors.pink),
                    hintText: 'Nom complet',
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(20)),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(20),
                      borderSide: const BorderSide(color: Colors.pink, width: 2),
                    ),
                  ),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Le nom est obligatoire';
                    }
                    return null; // valide
                  },
                ),
                const SizedBox(height: 15),
                // Champ Email
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
                      borderSide: const BorderSide(color: Colors.pink, width: 2),
                    ),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'L\'email est obligatoire';
                    }
                    if (!value.contains('@')) {
                      return 'Email non valide';
                    }
                    return null; // valide
                  },
                ),
                const SizedBox(height: 15),
                // Champ Mot de passe
                TextFormField(
                  controller: passwordController,
                  obscureText: true, // cacher le mot de passe
                  decoration: InputDecoration(
                    prefixIcon: const Icon(Icons.lock, color: Colors.pink),
                    hintText: 'Mot de passe (6 caractères min)',
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(20)),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(20),
                      borderSide: const BorderSide(color: Colors.pink, width: 2),
                    ),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Le mot de passe est obligatoire';
                    }
                    if (value.length < 6) {
                      return 'Minimum 6 caractères';
                    }
                    return null; // valide
                  },
                ),
                const SizedBox(height: 30),
                // Bouton S'inscrire
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _isLoading ? null : _register, // désactivé si loading
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.pink,
                      padding: const EdgeInsets.symmetric(vertical: 18),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20)),
                    ),
                    child: _isLoading
                        ? const CircularProgressIndicator(color: Colors.white) // loader
                        : const Text('S\'inscrire',
                        style: TextStyle(fontSize: 18, color: Colors.white)),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
