class Mentor {
  int id; // Changed to non-nullable
  String nom;
  String prenom;
  String email;
  String phone;
  String password;
  List<Role> authorities; // Liste des rôles

  Mentor({
    required this.id, // Make sure to require it
    required this.nom,
    required this.prenom,
    required this.email,
    required this.phone,
    required this.password,
    required this.authorities,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'nom': nom,
      'prenom': prenom,
      'email': email,
      'phone': phone,
      'password': password,
      'authorities': authorities.map((role) => role.toJson()).toList(),
    };
  }

  factory Mentor.fromJson(Map<String, dynamic> json) {
    return Mentor(
      id: json['id'] ?? 0, // Provide a default value if null
      nom: json['nom'],
      prenom: json['prenom'],
      email: json['email'],
      phone: json['phone'] ?? '', // Valeur par défaut si nul
      password: json['password'] ?? '',
      authorities: (json['authorities'] as List<dynamic>)
          .map((roleJson) => Role.fromJson(roleJson))
          .toList(),
    );
  }
}

class Role {
  String authority;

  Role({required this.authority});

  factory Role.fromJson(Map<String, dynamic> json) {
    return Role(
      authority: json['authority'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'authority': authority,
    };
  }
}
