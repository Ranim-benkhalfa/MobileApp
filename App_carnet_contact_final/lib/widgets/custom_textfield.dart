import 'package:flutter/material.dart';

// Widget personnalisé pour les champs de texte
class CustomTextField extends StatelessWidget {
  // Controller pour récupérer la valeur du champ
  final TextEditingController controller;

  // Texte qui apparaît comme hint (exemple : "Email")
  final String hint;

  // Icône affichée à gauche du champ
  final IconData icon;

  // Si le texte doit être caché (pour mot de passe)
  final bool obscure;

  // Type du clavier (texte, email, numéro...)
  final TextInputType? keyboardType;

  // Fonction de validation (pour Form)
  final String? Function(String?)? validator;

  // Constructeur du widget
  const CustomTextField({
    super.key,
    required this.controller,
    required this.hint,
    required this.icon,
    this.obscure = false,
    this.keyboardType,
    this.validator,
  });

  @override
  Widget build(BuildContext context) {
    return TextFormField( // Champ de texte avec validation possible
      controller: controller, // relie le champ au controller
      obscureText: obscure,   // cacher texte si mot de passe
      keyboardType: keyboardType, // type clavier
      decoration: InputDecoration( // style du champ
        prefixIcon: Icon(icon, color: Colors.pink), // icône à gauche
        hintText: hint, // texte d'exemple
        filled: true, // fond coloré
        fillColor: Colors.pink.withOpacity(0.05), // couleur du fond
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(20), // coins arrondis
          borderSide: BorderSide.none, // pas de bordure par défaut
        ),
        enabledBorder: OutlineInputBorder( // bordure quand pas focus
          borderRadius: BorderRadius.circular(20),
          borderSide: BorderSide(color: Colors.pink.shade200, width: 1.5),
        ),
        focusedBorder: OutlineInputBorder( // bordure quand focus
          borderRadius: BorderRadius.circular(20),
          borderSide: const BorderSide(color: Colors.pink, width: 2),
        ),
      ),
      validator: validator, // fonction de validation
    );
  }
}
