class RegisterUserDto {
  int? id; // Champ ID, facultatif lors de l'enregistrement
  String nom;
  String prenom;
  String email;
  String phone;
  String password;
  Role role; // Le rôle est maintenant un objet Role

  // Constructeur
  RegisterUserDto({
    this.id, // L'ID peut être nul lors de l'enregistrement
    required this.nom,
    required this.prenom,
    required this.email,
    required this.phone,
    required this.password,
    required this.role, // Le rôle est passé en tant qu'objet Role
  });

  // Méthode pour convertir l'objet en JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id, // Inclure l'ID dans le JSON, s'il existe
      'nom': nom,
      'prenom': prenom,
      'email': email,
      'phone': phone,
      'password': password,
      'role': role.toJson(), // Appel de la méthode toJson() de Role
    };
  }

  // Méthode pour créer un objet à partir de JSON
  factory RegisterUserDto.fromJson(Map<String, dynamic> json) {
    return RegisterUserDto(
      id: json['id'], // Récupérer l'ID à partir du JSON
      nom: json['nom'],
      prenom: json['prenom'],
      email: json['email'],
      phone: json['phone'],
      password: json['password'],
      role: Role.fromJson(json['role']), // Appel de la méthode fromJson() de Role
    );
  }
}

class Role {
  int id;
  String nom;

  // Constructeur
  Role({required this.id, required this.nom});

  // Méthode pour convertir un objet JSON en une instance de Role
  factory Role.fromJson(Map<String, dynamic> json) {
    return Role(
      id: json['id'],
      nom: json['nom'],
    );
  }

  // Méthode pour convertir une instance de Role en JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'nom': nom,
    };
  }
}
