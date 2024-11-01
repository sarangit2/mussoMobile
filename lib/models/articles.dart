// article_type.dart
enum ArticleType {
  Article,
  Droit,
}


class Article {
  final int id;
  final String titre;
  final String description;
  final ArticleType type; // Utilisation de l'énumération
  final String datePublication;
  final String dateAjout;
  final String audioUrl;

  Article({
    required this.id,
    required this.titre,
    required this.description,
    required this.type, // Changement ici
    required this.datePublication,
    required this.dateAjout,
    required this.audioUrl,
  });

  factory Article.fromJson(Map<String, dynamic> json) {
    return Article(
      id: json['id'],
      titre: json['titre'],
      description: json['description'],
      type: ArticleType.values.firstWhere((e) => e.toString().split('.').last == json['type']), // Conversion de String à enum
      datePublication: json['datePublication'],
      dateAjout: json['dateAjout'],
      audioUrl: json['audioUrl'], // Récupération de audioUrl
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'titre': titre,
      'description': description,
      'type': type.toString().split('.').last, // Conversion de enum à String
      'datePublication': datePublication,
      'dateAjout': dateAjout,
      'audioUrl': audioUrl,
    };
  }
}
