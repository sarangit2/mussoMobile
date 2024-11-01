// Model to represent a Message
class Message {
  final int? id; // Can be null for a new message
  final String? email; // Can be null
  final String content; // Must not be null
  final Utilisateur utilisateur; // Represents the sender of the message
  bool accepted; // Indicates if the discussion is accepted

  // Constructor
  Message({
    this.id,
    this.email,
    required this.content,
    required this.utilisateur,
    this.accepted = false, // Default value is false
  });

  // Create a Message from a Map
  factory Message.fromJson(Map<String, dynamic> json) {
    return Message(
      id: json['id'] as int?,
      email: json['email'] as String?,
      content: json['content'] as String,
      utilisateur: Utilisateur.fromJson(json['utilisateur'] as Map<String, dynamic>),
      accepted: json['accepted'] as bool? ?? false, // Default to false if null
    );
  }

  // Convert a Message to a Map
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'email': email,
      'content': content,
      'utilisateur': utilisateur.toJson(),
      'accepted': accepted, // Include accepted status
    };
  }
}

// User class representing the user entity in Flutter
class Utilisateur {
  final int id;
  final String nom; // User's name

  // Constructor
  Utilisateur({
    required this.id,
    required this.nom,
  });

  // Create a User from a Map
  factory Utilisateur.fromJson(Map<String, dynamic> json) {
    return Utilisateur(
      id: json['id'] as int,
      nom: json['nom'] as String,
    );
  }

  // Convert a User to a Map
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'nom': nom,
    };
  }
}
