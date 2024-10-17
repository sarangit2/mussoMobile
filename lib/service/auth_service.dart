import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:mussomobile/models/register_user_dto.dart';

import 'package:shared_preferences/shared_preferences.dart';

class AuthService {
  final String baseUrl = "http://localhost:8080/api"; // Remplacez par l'URL de votre API

  // Méthode pour s'inscrire (ajouter un utilisateur)
  Future<void> signup(RegisterUserDto input, int roleId) async {
    final response = await http.post(
      Uri.parse('$baseUrl/superadmin/ajout/$roleId'), // Utilisation du rôle ID
      headers: <String, String>{
        'Content-Type': 'application/json',
      },
      body: jsonEncode(input.toJson()), // Transformation en JSON
    );

    if (response.statusCode != 201) {
      throw Exception('Échec de l\'inscription: ${response.body}');
    }
  }

  // Méthode pour se connecter
  Future<Map<String, dynamic>> login(String email, String password) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/auth/login'),
        headers: {
          'Content-Type': 'application/json',
        },
        body: json.encode({
          'email': email,
          'password': password,
        }),
      );

      if (response.statusCode == 200) {
        print("Response body: ${response.body}"); // Imprimez la réponse
        Map<String, dynamic> authData = json.decode(response.body);

        // Assurez-vous que le rôle est bien un objet avec un ID et un nom
        if (authData.containsKey('role') && authData['role'] is Map) {
          Role userRole = Role.fromJson(authData['role']); // Rôle transformé en objet Role
          await _saveUserRole(userRole); // Sauvegarder le rôle en tant qu'objet
        } else {
          throw Exception('Rôle non trouvé ou de type incorrect');
        }

        await _saveToken(authData['token']); // Sauvegarde du token
        return authData; // Retourner les données d'authentification
      } else {
        throw Exception('Échec de la connexion: ${response.body}');
      }
    } catch (e) {
      throw Exception('Erreur: $e');
    }
  }

  // Sauvegarder le token JWT dans le stockage local
  Future<void> _saveToken(String token) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('jwt', token);
  }

  // Récupérer le token depuis le stockage local
  Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('jwt');
  }

  // Méthode pour se déconnecter
  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('jwt');
    await prefs.remove('userRole'); // Supprimer le rôle à la déconnexion
  }

  // Sauvegarder le rôle de l'utilisateur dans le stockage local (en JSON)
  Future<void> _saveUserRole(Role role) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('userRole', jsonEncode(role.toJson())); // Sauvegarde du rôle en JSON
  }

  // Méthode pour récupérer le rôle de l'utilisateur depuis le stockage local
  Future<Role?> getUserRole() async {
    final prefs = await SharedPreferences.getInstance();
    String? roleJson = prefs.getString('userRole');
    if (roleJson != null) {
      return Role.fromJson(jsonDecode(roleJson)); // Conversion du JSON en Role
    }
    return null; // Retourne null si aucun rôle n'est trouvé
  }
}
