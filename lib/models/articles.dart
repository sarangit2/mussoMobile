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
    required this.type,
    required this.datePublication,
    required this.dateAjout,
    required this.audioUrl,
  });

  factory Article.fromJson(Map<String, dynamic> json) {
    return Article(
      id: json['id'],
      titre: json['titre'],
      description: json['description'],
      type: _getArticleTypeFromJson(json['type']), // Gestion de la conversion de type
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

  // Méthode pour gérer la conversion de String à ArticleType
  static ArticleType _getArticleTypeFromJson(dynamic type) {
    if (type == null) {
      // Gérer le cas où le type est null
      return ArticleType.Article; // Valeur par défaut, ou vous pouvez lever une exception
    }
    
    // Vérifier si c'est une chaîne avant de faire la conversion
    if (type is String) {
      return ArticleType.values.firstWhere(
        (e) => e.toString().split('.').last == type,
        orElse: () => ArticleType.Article, // Valeur par défaut si aucune correspondance
      );
    } else {
      throw Exception('Type d\'article doit être une chaîne'); // Gestion d'erreur si ce n'est pas une chaîne
    }
  }
}
