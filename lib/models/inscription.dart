import 'package:mussomobile/models/formation.dart'; // Assurez-vous d'importer Formation

class Inscription {
  Formation formation; // Assurez-vous que c'est bien de type Formation
  String status;
  DateTime dateInscription;

  Inscription({
    required this.formation,
    required this.status,
    required this.dateInscription,
  });

  // Méthode fromJson pour désérialiser l'objet
  factory Inscription.fromJson(Map<String, dynamic> json) {
    return Inscription(
      formation: Formation.fromJson(json['formation']), // Assurez-vous que Formation a une méthode fromJson
      status: json['status'],
      dateInscription: DateTime.parse(json['dateInscription']),
    );
  }

  // Méthode toJson pour sérialiser l'objet si nécessaire
  Map<String, dynamic> toJson() {
    return {
      'formation': formation.toJson(), // Assurez-vous que Formation a une méthode toJson
      'status': status,
      'dateInscription': dateInscription.toIso8601String(),
    };
  }
}
