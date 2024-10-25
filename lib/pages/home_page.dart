import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  String? userName;
  String? userEmail;
  String? userRole;

  @override
  void initState() {
    super.initState();
    _loadUserInfo();
  }

  // Charger les informations de l'utilisateur
  Future<void> _loadUserInfo() async {
    final prefs = await SharedPreferences.getInstance();
    String? userInfoJson = prefs.getString('userInfo');
    if (userInfoJson != null) {
      Map<String, dynamic> userInfo = jsonDecode(userInfoJson);
      setState(() {
        userName = userInfo['nom']; // Adaptez selon la structure de votre réponse
        userEmail = userInfo['email'];
        userRole = userInfo['role']['nom']; // Si le rôle est un sous-objet
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Page d\'accueil'),
      ),
      body: Center(
        child: userName == null
            ? CircularProgressIndicator()
            : Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text('Bienvenue $userName', style: TextStyle(fontSize: 24)),
                  Text('Email: $userEmail', style: TextStyle(fontSize: 18)),
                  Text('Rôle: $userRole', style: TextStyle(fontSize: 18)),
                ],
              ),
      ),
    );
  }
}
