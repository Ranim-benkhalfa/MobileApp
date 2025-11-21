// Définition du modèle Contact pour représenter un contact
class Contact {
  final int? id;      // id du contact (nullable, c'est-à-dire qu'il peut être null)
  final String name;  // nom du contact (obligatoire)
  final String phone; // numéro de téléphone du contact (obligatoire)
  final String? email;// email du contact (optionnel, peut être null)

  // Constructeur de la classe Contact
  Contact({
    this.id,          // id peut être fourni ou non
    required this.name, // nom est obligatoire
    required this.phone,// téléphone est obligatoire
    this.email,         // email est optionnel
  });

  // Méthode pour transformer un Contact en Map (utile pour la base de données)
  Map<String, dynamic> toMap() {
    return {
      'id': id,       // clé 'id' = valeur id
      'name': name,   // clé 'name' = valeur name
      'phone': phone, // clé 'phone' = valeur phone
      'email': email, // clé 'email' = valeur email
    };
  }

  // Factory pour créer un Contact à partir d'une Map (lecture depuis la base de données)
  factory Contact.fromMap(Map<String, dynamic> map) {
    return Contact(
      id: map['id'] as int?,       // récupère l'id et le convertit en int? (nullable)
      name: map['name'] as String, // récupère le nom et le convertit en String
      phone: map['phone'] as String, // récupère le téléphone
      email: map['email'] as String?, // récupère l'email, nullable
    );
  }

  // Méthode pour afficher le contact sous forme de chaîne (utile pour debug)
  @override
  String toString() {
    return 'Contact{id: $id, name: $name, phone: $phone, email: $email}';
  }
}
