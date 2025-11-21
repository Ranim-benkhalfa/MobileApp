import 'package:flutter/material.dart';
import '../models/contact.dart';

// Formulaire pour ajouter ou modifier un contact
class ContactForm extends StatefulWidget {
  final Contact? contact; // peut être null si on ajoute un nouveau contact

  const ContactForm({super.key, this.contact});

  @override
  State<ContactForm> createState() => _ContactFormState();
}

class _ContactFormState extends State<ContactForm> {
  late TextEditingController nameController;  // controller pour le champ nom
  late TextEditingController emailController; // controller pour le champ email
  late TextEditingController phoneController; // controller pour le champ téléphone

  @override
  void initState() {
    super.initState();
    // On initialise les controllers avec les valeurs existantes si on modifie un contact
    nameController = TextEditingController(text: widget.contact?.name ?? '');
    emailController = TextEditingController(text: widget.contact?.email ?? '');
    phoneController = TextEditingController(text: widget.contact?.phone ?? '');
  }

  @override
  void dispose() {
    // On libère les ressources des controllers quand le widget est détruit
    nameController.dispose();
    emailController.dispose();
    phoneController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.contact == null ? "Ajouter Contact" : "Modifier Contact"),
        backgroundColor: Colors.pink,    // couleur de l'appbar
        foregroundColor: Colors.white,   // couleur du texte et des icônes
      ),
      body: Padding(
        padding: const EdgeInsets.all(20), // marge autour du formulaire
        child: Column(
          children: [
            // Champ pour le nom
            TextField(
              controller: nameController,
              decoration: InputDecoration(
                prefixIcon: const Icon(Icons.person, color: Colors.pink), // icône à gauche
                labelText: 'Nom complet',
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(20)), // bord arrondi
              ),
            ),
            const SizedBox(height: 15), // espace entre les champs
            // Champ pour l'email
            TextField(
              controller: emailController,
              keyboardType: TextInputType.emailAddress, // clavier adapté pour email
              decoration: InputDecoration(
                prefixIcon: const Icon(Icons.email, color: Colors.pink),
                labelText: 'Email (facultatif)',
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(20)),
              ),
            ),
            const SizedBox(height: 15),
            // Champ pour le téléphone
            TextField(
              controller: phoneController,
              keyboardType: TextInputType.phone, // clavier adapté pour téléphone
              decoration: InputDecoration(
                prefixIcon: const Icon(Icons.phone, color: Colors.pink),
                labelText: 'Téléphone',
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(20)),
              ),
            ),
            const SizedBox(height: 30),
            // Bouton Ajouter / Modifier
            ElevatedButton(
              onPressed: () {
                // Vérification simple : nom et téléphone ne doivent pas être vides
                if (nameController.text.trim().isEmpty || phoneController.text.trim().isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text("Le nom et le téléphone sont obligatoires !")),
                  );
                  return; // on arrête ici si champs vides
                }

                // Création ou mise à jour du contact
                final updatedContact = Contact(
                  id: widget.contact?.id,               // on garde l'id si modification
                  name: nameController.text.trim(),
                  phone: phoneController.text.trim(),
                  email: emailController.text.trim().isEmpty ? null : emailController.text.trim(),
                );

                // Retourne le contact à la page précédente
                Navigator.pop(context, updatedContact);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.pink,
                padding: const EdgeInsets.symmetric(horizontal: 90, vertical: 18),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
              ),
              child: Text(
                widget.contact == null ? 'Ajouter' : 'Modifier',
                style: const TextStyle(color: Colors.white, fontSize: 18),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
