import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:mussomobile/models/mentor.dart';

import 'package:mussomobile/service/auth_service.dart';

class MentorService {
  final String baseUrl = "http://localhost:8080/api/superadmin"; // Assurez-vous que l'URL est correcte
  final AuthService authService = AuthService();

  // Récupérer la liste des mentors
  Future<List<Mentor>> getMentors() async {
    final token = await authService.getToken(); // Récupérer le token JWT depuis AuthService
    print('Token récupéré : $token');

    final response = await http.get(
      Uri.parse('$baseUrl/mentors'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token', // Ajouter le token dans les headers
      },
    );

    print('Statut de la réponse : ${response.statusCode}');
    print('Corps de la réponse : ${response.body}');

    if (response.statusCode == 200) {
      List<dynamic> mentorsJson = jsonDecode(response.body);
      return mentorsJson.map((json) => Mentor.fromJson(json)).toList();
    } else {
      print('Erreur lors de la récupération des mentors: ${response.body}');
      throw Exception('Échec de la récupération des mentors');
    }
  }


}
