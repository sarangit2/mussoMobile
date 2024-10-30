import 'package:flutter/material.dart';
import 'package:mussomobile/models/register_user_dto.dart';

import 'package:mussomobile/pages/home_page.dart';
import 'package:mussomobile/pages/legal_advice_screen.dart';
import 'package:mussomobile/pages/mentor_list_page.dart';
import 'package:mussomobile/pages/sign_up_screen.dart';
import 'package:mussomobile/service/auth_service.dart';

class LoginScreen extends StatefulWidget {
  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  bool _isLoading = false;
  String message = '';

  void _login() async {
    setState(() {
      _isLoading = true;
      message = '';
    });

    try {
      AuthService authService = AuthService();
      // Assurez-vous que votre méthode login retourne un Map<String, dynamic>
      final response = await authService.login(
        emailController.text.trim(),
        passwordController.text.trim(),
      );

      _handleResponse(response);
    } catch (e) {
      setState(() {
        message = 'Erreur: $e';
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _handleResponse(Map<String, dynamic> response) {
    // Vérification du rôle ou autre logique après connexion
    if (response.containsKey('token')) {
      // Récupérer le rôle de l'utilisateur depuis la réponse
      Role userRole = Role.fromJson(response['role']); // Supposons que 'role' est un champ de la réponse

      // Navigation en fonction du rôle de l'utilisateur
      if (userRole.nom == 'MENTOR') {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => MentorListPage()), // Page pour le MENTOR
        );
      } else if (userRole.nom == 'ADMIN') {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => HomePage()), // Page pour l'ADMIN
        );
      } else {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => LegalAdviceScreen()), // Page par défaut pour les autres rôles
        );
      }
    } else {
      setState(() {
        message = 'Erreur lors de la connexion.';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Logo en haut de la page
              Image.asset(
                'assets/LogoMusso.png', // Assurez-vous que le chemin du logo est correct
                height: 150,
              ),
              SizedBox(height: 20),
              // Titre "Login"
              Text(
                'Login',
                style: TextStyle(
                  fontSize: 30,
                  fontWeight: FontWeight.bold,
                  color: Colors.pink,
                ),
              ),
              SizedBox(height: 20),
              // Champ Email
              TextField(
                controller: emailController,
                decoration: InputDecoration(
                  labelText: 'Email',
                  prefixIcon: Icon(Icons.email, color: Colors.pink),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                ),
              ),
              SizedBox(height: 20),
              // Champ Mot de passe
              TextField(
                controller: passwordController,
                decoration: InputDecoration(
                  labelText: 'Password',
                  prefixIcon: Icon(Icons.lock, color: Colors.pink),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                ),
                obscureText: true,
              ),
              SizedBox(height: 20),
              // Bouton de connexion
              _isLoading
                  ? CircularProgressIndicator()
                  : ElevatedButton(
                      onPressed: _login,
                      style: ElevatedButton.styleFrom(
                        padding: EdgeInsets.symmetric(
                            horizontal: 50, vertical: 15),
                        backgroundColor: Colors.pink,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30),
                        ),
                      ),
                      child: Text(
                        'Connexion',
                        style: TextStyle(fontSize: 19,  color: const Color.fromARGB(255, 255, 255, 255)),
                        
                      ),
                    ),
              SizedBox(height: 10),
              // Lien pour s'inscrire
              GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => SignupScreen()),
                  );
                },
                child: Text(
                  "Pas de compte? S'inscrire",
                  style: TextStyle(
                    fontSize: 16,
                    color: const Color.fromARGB(255, 24, 4, 114),
                    decoration: TextDecoration.underline,
                  ),
                ),
              ),
              if (message.isNotEmpty) ...[
                SizedBox(height: 10),
                Text(message, style: TextStyle(color: Colors.pinkAccent)),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
