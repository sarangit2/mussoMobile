// Modèle pour représenter un Message
class Message {
  final int? id; // Peut être nul pour un nouveau message
  final String? email; // Peut être nul
  final String content; // Doit être non nul
  final Utilisateur utilisateur; // Représente l'expéditeur du message

  // Constructeur
  Message({
    this.id,
    this.email,
    required this.content,
    required this.utilisateur,
  });

  // Créer un Message à partir d'un Map
  factory Message.fromJson(Map<String, dynamic> json) {
    return Message(
      id: json['id'] as int?,
      email: json['email'] as String?,
      content: json['content'] as String,
      utilisateur: Utilisateur.fromJson(json['utilisateur'] as Map<String, dynamic>),
    );
  }

  // Convertir un Message en Map
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'email': email,
      'content': content,
      'utilisateur': utilisateur.toJson(),
    };
  }
}

// Classe Utilisateur, représentant l'entité utilisateur en Flutter
class Utilisateur {
  final int id;
  final String name; // Nom de l'utilisateur
  final String? role; // Peut être nul, représente le rôle de l'utilisateur si nécessaire
  final String? phoneNumber; // Peut être nul, numéro de téléphone de l'utilisateur

  // Constructeur
  Utilisateur({
    required this.id,
    required this.name,
    this.role,
    this.phoneNumber,
  });

  // Créer un Utilisateur à partir d'un Map
  factory Utilisateur.fromJson(Map<String, dynamic> json) {
    return Utilisateur(
      id: json['id'] as int,
      name: json['name'] as String,
      role: json['role'] as String?,
      phoneNumber: json['phoneNumber'] as String?,
    );
  }

  // Convertir un Utilisateur en Map
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'role': role,
      'phoneNumber': phoneNumber,
    };
  }
}
