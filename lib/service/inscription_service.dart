import 'dart:convert';
import 'package:http/http.dart' as http;

import 'package:mussomobile/models/inscription.dart';

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

// Récupérer la liste des inscriptions de l'utilisateur authentifié
  Future<List<Inscription>> fetchUserInscriptions() async {
    final response = await http.get(
      Uri.parse('$baseUrl/api/inscriptions'),
      headers: {
        'Authorization': 'Bearer $jwtToken',
        'Content-Type': 'application/json',
      },
    );

    if (response.statusCode == 200) {
      List<dynamic> inscriptionsJson = json.decode(response.body);
      return inscriptionsJson.map((json) => Inscription.fromJson(json)).toList();
    } else {
      print('Erreur lors de la récupération des inscriptions : ${response.statusCode} - ${response.body}');
      throw Exception('Erreur lors de la récupération des inscriptions');
    }
  }

}
