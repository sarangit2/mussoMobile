import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:mussomobile/models/register_user_dto.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AuthService {
  final String baseUrl = "http://localhost:8080/api"; // Remplacez par l'URL de votre API

  // Méthode pour s'inscrire (ajouter un utilisateur)
  Future<void> signup(RegisterUserDto input, int roleId) async {
    print('Tentative d\'inscription pour le rôle ID: $roleId avec les données: ${input.toJson()}');
    
    final response = await http.post(
      Uri.parse('$baseUrl/superadmin/ajout/$roleId'), // Utilisation du rôle ID
      headers: <String, String>{
        'Content-Type': 'application/json',
      },
      body: jsonEncode(input.toJson()), // Transformation en JSON
    );

    if (response.statusCode != 201) {
      print('Échec de l\'inscription: ${response.body}');
      throw Exception('Échec de l\'inscription: ${response.body}');
    }
    print('Inscription réussie: ${response.body}');
  }

  // Méthode pour se connecter
  Future<Map<String, dynamic>> login(String email, String password) async {
    print('Tentative de connexion avec email: $email');

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

      print('Réponse de connexion: ${response.statusCode} - ${response.body}');

      if (response.statusCode == 200) {
        Map<String, dynamic> authData = json.decode(response.body);

        if (authData.containsKey('role') && authData['role'] is Map) {
          Role userRole = Role.fromJson(authData['role']);
          await _saveUserRole(userRole);
          print('Rôle utilisateur sauvegardé: ${userRole.toJson()}');
        }

        await _saveToken(authData['token']);
        await _saveUserInfo(authData); // Sauvegarder les infos utilisateur
        return authData;
      } else {
        print('Échec de la connexion: ${response.body}');
        throw Exception('Échec de la connexion: ${response.body}');
      }
    } catch (e) {
      print('Erreur lors de la connexion: $e');
      throw Exception('Erreur: $e');
    }
  }

  // Sauvegarder les informations de l'utilisateur
  Future<void> _saveUserInfo(Map<String, dynamic> userInfo) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('userInfo', jsonEncode(userInfo)); // Stocker les infos en JSON
    print('Informations utilisateur sauvegardées: $userInfo');
  }

  // Sauvegarder le token JWT dans le stockage local
  Future<void> _saveToken(String token) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('jwt', token);
    print('Token sauvegardé: $token');
  }

  // Récupérer le token depuis le stockage local
  Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString('jwt');
    print('Récupération du token: $token');
    return token;
  }

  // Méthode pour se déconnecter
  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('jwt');
    await prefs.remove('userRole'); // Supprimer le rôle à la déconnexion
    print('Déconnexion réussie, token et rôle supprimés.');
  }

  // Sauvegarder le rôle de l'utilisateur dans le stockage local (en JSON)
  Future<void> _saveUserRole(Role role) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('userRole', jsonEncode(role.toJson())); // Sauvegarde du rôle en JSON
    print('Rôle sauvegardé: ${role.toJson()}');
  }

  // Méthode pour récupérer le rôle de l'utilisateur depuis le stockage local
  Future<Role?> getUserRole() async {
    final prefs = await SharedPreferences.getInstance();
    String? roleJson = prefs.getString('userRole');
    print('Récupération du rôle utilisateur: $roleJson');

    if (roleJson != null) {
      return Role.fromJson(jsonDecode(roleJson)); // Conversion du JSON en Role
    }
    return null; // Retourne null si aucun rôle n'est trouvé
  }



// AuthService.dart

Future<void> updateSuperAdmin(int id, RegisterUserDto input) async {
  final response = await http.put(
    Uri.parse('$baseUrl/superadmin/modifier/$id'), // Utilisation de l'ID
    headers: <String, String>{
      'Content-Type': 'application/json',
    },
    body: jsonEncode(input.toJson()), // Transformation en JSON
  );

  if (response.statusCode != 201) {
    print('Échec de la mise à jour: ${response.body}');
    throw Exception('Échec de la mise à jour: ${response.body}');
  }
  print('Mise à jour réussie: ${response.body}');
}


// AuthService.dart
// Méthode pour récupérer les informations de l'utilisateur
Future<Map<String, dynamic>> getUserInfo() async {
  final token = await getToken(); // Obtenir le token sauvegardé

  final response = await http.get(
    Uri.parse('$baseUrl/superadmin/me'), // Mettre à jour avec votre endpoint pour les infos utilisateur
    headers: {
      'Authorization': 'Bearer $token', // Inclure le token dans la requête
      'Content-Type': 'application/json',
    },
  );

  if (response.statusCode == 200) {
    final Map<String, dynamic>? data = json.decode(response.body);
    if (data == null) {
      throw Exception('Les données utilisateur sont nulles');
    }
    return data; // Retourner les infos utilisateur en tant que Map
  } else {
    print('Échec de la récupération des informations utilisateur: ${response.body}');
    throw Exception('Échec de la récupération des informations utilisateur: ${response.body}');
  }
}

}
