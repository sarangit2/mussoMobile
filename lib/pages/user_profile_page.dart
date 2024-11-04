import 'package:flutter/material.dart';
import 'package:mussomobile/models/register_user_dto.dart';
import 'package:mussomobile/pages/legal_advice_screen.dart';
import 'package:mussomobile/pages/login_screen.dart';
import 'package:mussomobile/pages/mentor_list_page.dart';
import 'package:mussomobile/pages/training_screen.dart';
import 'package:mussomobile/service/auth_service.dart';

class UserProfilePage extends StatefulWidget {
  @override
  State<UserProfilePage> createState() => _UserProfilePageState();
}

class _UserProfilePageState extends State<UserProfilePage> {
  final AuthService authService = AuthService();
  int _selectedTabIndex = 3; // Index par défaut pour le profil utilisateur

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Profil Utilisateur',
          style: TextStyle(color: Colors.white),
        ),
        centerTitle: true, // Centre le titre
        backgroundColor: Colors.pinkAccent,
        elevation: 0,
      ),
      body: FutureBuilder<Map<String, dynamic>>(
        future: authService.getUserInfo(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Erreur: ${snapshot.error}'));
          } else if (snapshot.hasData && snapshot.data != null) {
            final userInfo = snapshot.data!;
            final RegisterUserDto user = RegisterUserDto.fromJson(userInfo);

            return Padding(
              padding: const EdgeInsets.all(16.0),
              child: Card(
                elevation: 5,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Informations Personnelles',
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: Colors.pinkAccent,
                        ),
                      ),
                      Divider(color: Colors.grey),
                      _buildUserInfoRow(Icons.person, 'Nom', user.nom),
                      _buildUserInfoRow(Icons.person_outline, 'Prénom', user.prenom),
                      _buildUserInfoRow(Icons.email, 'Email', user.email),
                      _buildUserInfoRow(Icons.phone, 'Téléphone', user.phone),
                      _buildUserInfoRow(Icons.account_box, 'Rôle', user.role.nom),
                      SizedBox(height: 20), // Espacement avant le bouton
                      ElevatedButton(
                        onPressed: () async {
                          await authService.logout(); // Appel à la méthode de déconnexion
                          Navigator.of(context).pushReplacement(
                            MaterialPageRoute(builder: (context) => LoginScreen()), // Remplacez LoginScreen par votre page de connexion
                          );
                        },
                         child: Text(
    'Se Déconnecter',
    style: TextStyle(color: Colors.white), // Change la couleur du texte en blanc
  ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.pinkAccent, // Couleur du bouton
                          padding: EdgeInsets.symmetric(vertical: 12.0, horizontal: 24.0),
                          textStyle: TextStyle(fontSize: 18),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          } else {
            return Center(child: Text('Aucune donnée disponible'));
          }
        },
      ),
      bottomNavigationBar: BottomNavigationBar(
        backgroundColor: Colors.pinkAccent,
        currentIndex: _selectedTabIndex,
        onTap: (index) {
          if (index != _selectedTabIndex) {
            setState(() {
              _selectedTabIndex = index;
            });
            Widget page;
            switch (index) {
              case 0:
                page = LegalAdviceScreen();
                break;
              case 1:
                page = TrainingScreen();
                break;
              case 2:
                page = MentorListPage();
                break;
              case 3:
                page = UserProfilePage();
                break;
              default:
                page = LegalAdviceScreen();
            }
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => page),
            );
          }
        },
        selectedItemColor: Colors.white,
        unselectedItemColor: const Color.fromARGB(179, 0, 0, 0),
        type: BottomNavigationBarType.fixed,
        items: [
          BottomNavigationBarItem(
            icon: Icon(Icons.article),
            label: "Article",
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.school),
            label: "Formation",
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person_search),
            label: "Spécialiste",
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: "Profil",
          ),
        ],
      ),
    );
  }

  Widget _buildUserInfoRow(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        children: [
          Icon(icon, color: Colors.pinkAccent),
          SizedBox(width: 10),
          Text(
            '$label:',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          SizedBox(width: 10),
          Expanded(
            child: Text(value, style: TextStyle(fontSize: 18)),
          ),
        ],
      ),
    );
  }
}
