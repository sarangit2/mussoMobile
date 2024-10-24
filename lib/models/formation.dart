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
  final String imageUrl; // Ajouter un champ pour l'image

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
    required this.imageUrl, // Inclure imagePath dans le constructeur
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
      imageUrl: json['imageUrl'] ?? '', // Ajouter imagePath dans la conversion JSON
    );
  }
}
