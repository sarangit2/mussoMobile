import 'dart:convert';
import 'package:http/http.dart' as http;

class InscriptionService {
  final String baseUrl; // URL de base pour les requêtes
  final String jwtToken; // Le token JWT à envoyer avec la requête

  InscriptionService(this.baseUrl, this.jwtToken);

  Future<bool> registerForFormation(int formationId) async {
    final response = await http.post(
      Uri.parse('$baseUrl/api/inscription/$formationId'),
      headers: {
        'Authorization': 'Bearer $jwtToken', // Ajoutez le token JWT ici
        'Content-Type': 'application/json',
      },
    );

    if (response.statusCode == 201) {
      // Inscription réussie
      return true;
    } else {
      // Échec de l'inscription
      print('Échec de l\'inscription : ${response.statusCode} - ${response.body}');
      return false;
    }
  }

  // Nouvelle méthode pour récupérer la liste des utilisateurs inscrits
  Future<List<dynamic>> fetchInscrits() async {
    final response = await http.get(
      Uri.parse('$baseUrl/api/inscription/list'),
      headers: {
        'Authorization': 'Bearer $jwtToken',
      },
    );

    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      throw Exception('Erreur de récupération des inscrits : ${response.statusCode}');
    }
  }
}
