import 'package:flutter/material.dart';
import 'package:mussomobile/models/message.dart';
import 'package:mussomobile/pages/chat_page.dart';
import 'package:mussomobile/service/message_service.dart';
import 'package:mussomobile/service/auth_service.dart'; // Assurez-vous d'importer AuthService

class ReceivedMessagesPage extends StatefulWidget {
  @override
  _ReceivedMessagesPageState createState() => _ReceivedMessagesPageState();
}

class _ReceivedMessagesPageState extends State<ReceivedMessagesPage> {
  final MessageService messageService = MessageService();
  late Future<Map<String, List<Message>>> groupedMessagesFuture;
  late String userRole; // Ajout d'une variable pour le rôle de l'utilisateur

  @override
  void initState() {
    super.initState();
    groupedMessagesFuture = messageService.getReceivedMessages().then((messages) {
      // Regrouper les messages par utilisateur
      Map<String, List<Message>> groupedMessages = {};
      for (var message in messages) {
        final userId = message.utilisateur.id.toString();
        if (!groupedMessages.containsKey(userId)) {
          groupedMessages[userId] = [];
        }
        groupedMessages[userId]!.add(message);
      }
      return groupedMessages;
    });

    // Récupérer le rôle de l'utilisateur
    _getUserRole();
  }

  void _getUserRole() async {
    AuthService authService = AuthService();
    final roleResponse = await authService.getUserRole(); // Méthode fictive pour obtenir le rôle
    setState(() {
      userRole = roleResponse?.nom ?? ''; // Defaults to an empty string if null
    });
  }

  Future<void> acceptDiscussionAndNavigate(Message message) async {
    try {
      await messageService.acceptDiscussion(message.utilisateur.id);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Discussion acceptée avec ${message.utilisateur.nom}')),
      );

      setState(() {
        message.accepted = true; // Marquer le message comme accepté
      });

      // Naviguer vers ChatPage après avoir accepté la discussion
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => ChatPage(
            mentorId: message.utilisateur.id,
            mentorName: message.utilisateur.nom,
          ),
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erreur : $e')),
      );
    }
  }

  Future<void> sendMessageToMentor(int mentorId, String mentorName, String messageContent) async {
    try {
      final message = Message(content: messageContent, utilisateur: Utilisateur(id: mentorId, nom: mentorName)); // Créez un message
      Message sentMessage = await messageService.sendMessageToMentor(mentorId, message);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Message envoyé à ${sentMessage.utilisateur.nom}')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erreur lors de l\'envoi du message : $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Messages Reçus',
          style: TextStyle(color: Colors.white), // Couleur du texte en blanc
        ),
        centerTitle: true, // Aligne le texte au centre
        backgroundColor: Colors.pinkAccent,
      ),
      body: FutureBuilder<Map<String, List<Message>>>(
        future: groupedMessagesFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Erreur : ${snapshot.error}'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return Center(child: Text('Aucun message reçu.'));
          }

          return ListView(
            children: snapshot.data!.entries.map((entry) {
              final userId = entry.key;
              final messages = entry.value;
              final userName = messages.first.utilisateur.nom; // Utiliser le nom du premier message

              return Card(
                margin: EdgeInsets.symmetric(vertical: 8, horizontal: 10),
                elevation: 5,
                child: Padding(
                  padding: const EdgeInsets.all(10.0),
                  child: Row(
                    children: [
                      // Image par défaut pour l'utilisateur
                      CircleAvatar(
                        radius: 25,
                        backgroundImage: AssetImage('assets/form.png'), // Remplacez par le chemin de votre image
                        backgroundColor: Colors.grey[200],
                      ),
                      SizedBox(width: 10),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              messages.first.content,
                              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                            SizedBox(height: 5),
                            Text(
                              'De : $userName',
                              style: TextStyle(color: Colors.grey[600]),
                            ),
                          ],
                        ),
                      ),
                      SizedBox(width: 10),
                      ElevatedButton(
                        onPressed: () {
                          if (!messages.first.accepted) {
                            acceptDiscussionAndNavigate(messages.first);
                            sendMessageToMentor(
                              messages.first.utilisateur.id,  // mentorId
                              messages.first.utilisateur.nom,  // mentorName
                              "Votre message ici"               // messageContent
                            ); // Ajoutez votre message ici
                          } else {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => ChatPage(
                                  mentorId: messages.first.utilisateur.id,
                                  mentorName: userName,
                                ),
                              ),
                            );
                          }
                        },
                        child: Text(
                          messages.first.accepted 
                            ? 'Voir plus' 
                            : (userRole == 'MENTOR' ? 'Accepter' : 'Voir plus') // Afficher 'Voir plus' si le rôle n'est pas 'MENTOR'
                        ),
                        style: ElevatedButton.styleFrom(
                          foregroundColor: Colors.white,
                          backgroundColor: Colors.pinkAccent,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(30),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }).toList(),
          );
        },
      ),
    );
  }
}
