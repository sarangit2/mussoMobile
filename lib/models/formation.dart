class Formation {
  final int id;
  final String titre;
  final String description;
  final String dateDebut;
  final String dateFin;
  final String organisateur;
  final String dateAjout;
  final String categorie;
  final String videoPath;
  final String imageUrl;
  final String pdfPath; // Nouveau champ pour le PDF

  Formation({
    required this.id,
    required this.titre,
    required this.description,
    required this.dateDebut,
    required this.dateFin,
    required this.organisateur,
    required this.dateAjout,
    required this.categorie,
    required this.videoPath,
    required this.imageUrl,
    required this.pdfPath, // Inclure pdfPath dans le constructeur
  });

  factory Formation.fromJson(Map<String, dynamic> json) {
    return Formation(
      id: json['id'],
      titre: json['titre'],
      description: json['description'],
      dateDebut: json['dateDebut'],
      dateFin: json['dateFin'],
      organisateur: json['organisateur'],
      dateAjout: json['dateAjout'],
      categorie: json['categorie'] ?? '',
      videoPath: json['videoPath'] ?? '',
      imageUrl: json['imageUrl'] ?? '',
      pdfPath: json['pdfPath'] ?? '', // Ajouter pdfPath dans la conversion JSON
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'titre': titre,
      'description': description,
      'dateDebut': dateDebut,
      'dateFin': dateFin,
      'organisateur': organisateur,
      'dateAjout': dateAjout,
      'categorie': categorie,
      'videoPath': videoPath,
      'imageUrl': imageUrl,
      'pdfPath': pdfPath, // Inclure pdfPath dans la conversion JSON
    };
  }
}
