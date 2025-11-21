import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../models/contact.dart';
import '../services/database_helper.dart';
import '../app_router.dart';
import 'contact_form.dart';

// Écran principal du carnet de contacts
class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  List<Contact> contacts = []; // liste des contacts à afficher
  final DatabaseHelper _databaseHelper = DatabaseHelper(); // instance pour accéder à la base de données
  bool _isLoading = true; // pour afficher le loader pendant le chargement

  // Fonction pour charger les contacts depuis la base de données
  Future<void> _loadContacts() async {
    setState(() => _isLoading = true); // on montre le loader

    try {
      final List<Contact> loadedContacts = await _databaseHelper.getContacts(); // récupération contacts
      print('📱 Dashboard: Loaded ${loadedContacts.length} contacts');
      setState(() {
        contacts = loadedContacts; // on met à jour la liste
        _isLoading = false;       // on cache le loader
      });
    } catch (e) {
      print('❌ ERREUR chargement contacts: $e');
      setState(() => _isLoading = false); // en cas d'erreur on cache le loader
    }
  }

  // Fonction pour déconnexion
  void _logout() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Déconnexion"),
        content: const Text("Voulez-vous vous déconnecter ?"),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false), // retourne false si non
            child: const Text("Non"),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true), // retourne true si oui
            child: const Text("Oui", style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );

    if (confirm == true && mounted) { // si confirmé et widget monté
      await AppRouter.authNotifier.logout(); // déconnexion réelle
      context.go('/'); // retourne à la page de login
    }
  }

  @override
  void initState() {
    super.initState();
    print('🚀 Dashboard initState');
    _loadContacts(); // on charge les contacts au démarrage
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Carnet de Contact"),
        backgroundColor: Colors.pink,
        foregroundColor: Colors.white,
        actions: [
          // Bouton pour se déconnecter
          IconButton(
            icon: const Icon(Icons.logout),
            tooltip: 'Déconnexion',
            onPressed: _logout,
          ),
        ],
      ),
      body: _isLoading
          ? const Center(
        // affichage loader pendant chargement
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(color: Colors.pink),
            SizedBox(height: 20),
            Text("Chargement des contacts..."),
          ],
        ),
      )
          : contacts.isEmpty
          ? Center(
        // affichage si aucun contact
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.people, size: 100, color: Colors.pink[300]),
            const SizedBox(height: 20),
            const Text(
              "Aucun contact",
              style: TextStyle(fontSize: 24, color: Colors.grey),
            ),
            const SizedBox(height: 10),
            const Text(
              "Appuie sur le bouton + pour ajouter ton premier contact !",
              style: TextStyle(fontSize: 16, color: Colors.grey),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      )
          : ListView.builder(
        // liste des contacts
        itemCount: contacts.length,
        itemBuilder: (context, index) {
          final contact = contacts[index];
          return Card(
            margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            elevation: 3,
            child: ListTile(
              leading: CircleAvatar(
                backgroundColor: Colors.pink,
                child: Text(
                  contact.name.isNotEmpty ? contact.name[0].toUpperCase() : '?', // initiale
                  style: const TextStyle(color: Colors.white),
                ),
              ),
              title: Text(
                contact.name,
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              subtitle: Text(contact.phone),
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // bouton modifier
                  IconButton(
                    icon: const Icon(Icons.edit, color: Colors.orange),
                    onPressed: () async {
                      print('✏️ Editing contact: ${contact.name}');
                      final updatedContact = await Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => ContactForm(contact: contact),
                        ),
                      );
                      if (updatedContact is Contact) {
                        await _databaseHelper.updateContact(updatedContact); // mise à jour
                        _loadContacts(); // recharger la liste
                      }
                    },
                  ),
                  // bouton supprimer
                  IconButton(
                    icon: const Icon(Icons.delete, color: Colors.red),
                    onPressed: () async {
                      final confirm = await showDialog<bool>(
                        context: context,
                        builder: (context) => AlertDialog(
                          title: const Text("Supprimer ?"),
                          content: Text("Supprimer ${contact.name} ?"),
                          actions: [
                            TextButton(
                                onPressed: () => Navigator.pop(context, false),
                                child: const Text("Non")),
                            TextButton(
                                onPressed: () => Navigator.pop(context, true),
                                child: const Text("Oui")),
                          ],
                        ),
                      );
                      if (confirm == true) {
                        await _databaseHelper.deleteContact(contact.id!); // suppression
                        _loadContacts(); // recharger liste
                        if (mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text("${contact.name} supprimé")),
                          );
                        }
                      }
                    },
                  ),
                ],
              ),
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          print('➕ Adding new contact');
          // ouvrir le formulaire pour ajouter un contact
          final newContact = await Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const ContactForm()),
          );
          if (newContact is Contact) {
            print('💾 Saving new contact: ${newContact.name}');
            await _databaseHelper.insertContact(newContact); // insertion
            _loadContacts(); // recharger la liste
          } else {
            print('❌ No contact returned from form'); // si rien retourné
          }
        },
        backgroundColor: Colors.pink,
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }
}
