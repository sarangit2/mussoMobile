import 'dart:convert';
import 'package:http/http.dart' as http;

class FormationService {
  final String baseUrl = 'http://localhost:8080/api/formations/liste';
  final String jwtToken; // Le token JWT à envoyer avec la requête

  FormationService(this.jwtToken);

  Future<List<dynamic>> getFormations() async {
    final response = await http.get(
      Uri.parse(baseUrl),
      headers: {
        'Authorization': 'Bearer $jwtToken', // Ajoutez le token JWT ici
        'Content-Type': 'application/json',
      },
    );

    if (response.statusCode == 200) {
      return json.decode(response.body); // Décodez la réponse JSON
    } else {
      throw Exception('Échec de la récupération des formations');
    }
  }
}
