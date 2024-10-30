import 'package:flutter/material.dart';
import 'package:mussomobile/models/register_user_dto.dart';
import 'package:mussomobile/service/auth_service.dart';

class UserProfilePage extends StatelessWidget {
  final AuthService authService = AuthService();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Profil Utilisateur'),
      ),
      body: FutureBuilder<Map<String, dynamic>>(
        future: authService.getUserInfo(), // Appeler la méthode pour récupérer les informations utilisateur
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator()); // Indicateur de chargement
          } else if (snapshot.hasError) {
            return Center(child: Text('Erreur: ${snapshot.error}')); // Message d'erreur
          } else if (snapshot.hasData && snapshot.data != null) {
            final userInfo = snapshot.data!;
            final RegisterUserDto user = RegisterUserDto.fromJson(userInfo); // Convertir en modèle

            return Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Nom: ${user.nom}', style: TextStyle(fontSize: 20)),
                  SizedBox(height: 10),
                  Text('Prénom: ${user.prenom}', style: TextStyle(fontSize: 20)),
                  SizedBox(height: 10),
                  Text('Email: ${user.email}', style: TextStyle(fontSize: 20)),
                  SizedBox(height: 10),
                  Text('Téléphone: ${user.phone}', style: TextStyle(fontSize: 20)),
                  SizedBox(height: 10),
                  Text('Rôle: ${user.role.nom}', style: TextStyle(fontSize: 20)), // Afficher le nom du rôle
                ],
              ),
            );
          } else {
            return Center(child: Text('Aucune donnée disponible')); // Message de fallback
          }
        },
      ),
    );
  }
}
