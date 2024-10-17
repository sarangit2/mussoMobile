class Article {
  final int id;
  final String titre;
  final String description;
  final String type;
  final String datePublication;
  final String dateAjout;
  final String audioUrl;

  Article({required this.id, required this.titre, required this.description, required this.type, required this.datePublication, required this.dateAjout, required this.audioUrl});

  factory Article.fromJson(Map<String, dynamic> json) {
    return Article(
      id: json['id'],
      titre: json['titre'],
      description: json['description'],
      type: json['type'],
      datePublication: json['datePublication'],
      dateAjout: json['dateAjout'],
       audioUrl: json['audioUrl'], // Récupération de audioUrl
    );
  }
}
