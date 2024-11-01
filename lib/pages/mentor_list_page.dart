import 'package:flutter/material.dart'; 
import 'package:mussomobile/models/mentor.dart';
import 'package:mussomobile/pages/legal_advice_screen.dart';
import 'package:mussomobile/pages/training_screen.dart';

import 'package:mussomobile/pages/user_profile_page.dart';
import 'package:mussomobile/service/mentor_service.dart';
import 'package:mussomobile/service/auth_service.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:mussomobile/models/message.dart';
import 'package:mussomobile/pages/received_messages_page.dart'; // Importez votre page de messages reçus ici

class MentorListPage extends StatefulWidget {
  
  @override
  _MentorListPageState createState() => _MentorListPageState();
}

class _MentorListPageState extends State<MentorListPage> {
  
  final MentorService mentorService = MentorService();
  final AuthService authService = AuthService();
  late Future<List<Mentor>> mentorsFuture;
  String searchQuery = '';
  ScrollController _scrollController = ScrollController();
  int _selectedTabIndex = 2; // Index par défaut pour l'onglet Spécialiste

  @override
  void initState() {
    super.initState();
    mentorsFuture = mentorService.getMentors();
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  // Méthode pour afficher le dialogue de contact
  void _showContactDialog(Mentor mentor) {
    TextEditingController messageController = TextEditingController();

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Contactez ${mentor.nom} ${mentor.prenom}'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('Vous pouvez contacter ce mentor à l\'adresse suivante : ${mentor.email}.'),
              SizedBox(height: 10),
              TextField(
                controller: messageController,
                decoration: InputDecoration(
                  hintText: 'Entrez votre message ici...',
                  border: OutlineInputBorder(),
                ),
                maxLines: 3,
              ),
            ],
          ),
          actions: <Widget>[
            TextButton(
              child: Text('Envoyer'),
              onPressed: () {
                String messageContent = messageController.text;
                _sendMessage(messageContent, mentor.email, mentor.id);
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: Text('Fermer'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  // Méthode pour envoyer le message via API
  Future<void> _sendMessage(String messageContent, String mentorEmail, int mentorId) async {
    final url = Uri.parse('http://localhost:8080/api/messages/send/$mentorId');

    try {
      final message = Message(
        content: messageContent,
        email: mentorEmail,
        utilisateur: Utilisateur(id: 1, nom: 'Votre Nom'), // Remplacez par l'utilisateur actuel
         
      );

      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer ${await authService.getToken()}',
        },
        body: json.encode(message.toJson()),
      );

      if (response.statusCode == 200) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Message envoyé avec succès!')),
        );
      } else {
        try {
          final errorResponse = json.decode(response.body);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Erreur: ${errorResponse['error'] ?? 'Erreur inconnue'}')),
          );
        } catch (e) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Erreur de réponse invalide du serveur.')),
          );
        }
      }
    } catch (error) {
      print('Erreur d\'envoi de message: $error');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erreur d\'envoi du message. Veuillez réessayer.')),
      );
    }
  }

  void _stopAudio() {
    // Arrête l'audio si nécessaire
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
  
  title: Text(
    'Nos spécialistes',
    style: TextStyle(color: Colors.white),
  ),
  centerTitle: true, // Centre le titre
  actions: [
    IconButton(
      icon: Icon(Icons.message, color: Colors.white), // Icône pour voir les messages reçus
      onPressed: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => ReceivedMessagesPage()), // Remplacez par votre page de messages reçus
        );
      },
    ),
  ],
  backgroundColor: Colors.pinkAccent,
  elevation: 0,
),

      body: SingleChildScrollView(
        controller: _scrollController,
        child: Column(
          children: [
            Padding(
              padding: EdgeInsets.all(16.0),
              child: TextField(
                onChanged: (value) => setState(() => searchQuery = value),
                decoration: InputDecoration(
                  hintText: 'Rechercher',
                  suffixIcon: Icon(Icons.search, color: Color(0xFFFF4D6D)),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                  filled: true,
                  fillColor: Colors.grey[100],
                ),
              ),
            ),
            Container(
              height: MediaQuery.of(context).size.height - 200,
              child: FutureBuilder<List<Mentor>>(
                future: mentorsFuture,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return Center(child: CircularProgressIndicator());
                  } else if (snapshot.hasError) {
                    return Center(child: Text('Erreur : ${snapshot.error}'));
                  } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                    return Center(child: Text('Aucun spécialiste trouvé.'));
                  }

                  var filteredMentors = snapshot.data!.where((mentor) {
                    return mentor.nom.toLowerCase().contains(searchQuery.toLowerCase());
                  }).toList();

                  return ListView.builder(
                    shrinkWrap: true,
                    physics: AlwaysScrollableScrollPhysics(),
                    itemCount: filteredMentors.length,
                    itemBuilder: (context, index) {
                      final mentor = filteredMentors[index];
                      return Container(
                        margin: EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                        padding: EdgeInsets.all(16.0),
                        decoration: BoxDecoration(
                          color: Color.fromARGB(255, 247, 162, 179),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Row(
                          children: [
                            Container(
                              width: 80,
                              height: 80,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(8),
                                image: DecorationImage(
                                  image: AssetImage('assets/special.png'),
                                  fit: BoxFit.cover,
                                ),
                              ),
                            ),
                            SizedBox(width: 16),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    '${mentor.nom} ${mentor.prenom}',
                                    style: TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  SizedBox(height: 8),
                                  Align(
                                    alignment: Alignment.centerRight,
                                    child: ElevatedButton(
                                      onPressed: () => _showContactDialog(mentor),
                                      child: Text(
                                        'Contactez',
                                        style: TextStyle(
                                          color: Colors.white,
                                        ),
                                      ),
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: Color(0xFFFF4D6D),
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(20),
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
     bottomNavigationBar: Theme(
  data: Theme.of(context).copyWith(
    canvasColor: Colors.pinkAccent,
  ),
  child: BottomNavigationBar(
    currentIndex: _selectedTabIndex,
    onTap: (index) {
      if (index != _selectedTabIndex) { // Vérifier si l'index sélectionné est différent de l'index actuel
        setState(() {
          _selectedTabIndex = index; // Mettre à jour l'index sélectionné
        });

        if (index == 0) {
          // Navigation vers la page des Articles
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => LegalAdviceScreen()),
          );
        } else if (index == 1) {
          // Navigation vers la page de Formation
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => TrainingScreen()),
          );
        } else if (index == 2) {
          // Déjà sur la page des Mentors, aucune action nécessaire
          // Vous pouvez choisir de ne rien faire ici
        } else if (index == 3) {
          // Navigation vers la page de Profil
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => UserProfilePage()),
          );
        }
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
        label: "Profile",
      ),
    ],
  ),
),

    );
  }
}
