import 'package:flutter/material.dart';
import 'package:mussomobile/models/message.dart';
import 'package:mussomobile/service/auth_service.dart';
import 'package:mussomobile/service/message_service.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class ChatPage extends StatefulWidget {
  final int mentorId;
  final String mentorName;

  ChatPage({required this.mentorId, required this.mentorName});

  @override
  _ChatPageState createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  final AuthService authService = AuthService();
  final MessageService messageService = MessageService();
  TextEditingController messageController = TextEditingController();
  List<Message> receivedMessages = [];
  List<Message> sentMessages = [];

  @override
  void initState() {
    super.initState();
    fetchMessages();
    fetchSentMessages();
  }

  Future<void> fetchMessages() async {
    final url = Uri.parse('http://localhost:8080/api/messages/received');

    try {
      final response = await http.get(url, headers: {
        'Authorization': 'Bearer ${await authService.getToken()}',
      });

      if (response.statusCode == 200) {
        List<dynamic> jsonData = json.decode(response.body);
        setState(() {
          receivedMessages = jsonData.map((json) => Message.fromJson(json)).toList();
        });
      } else {
        throw Exception('Échec de la récupération des messages');
      }
    } catch (e) {
      print('Erreur lors de la récupération des messages: $e');
    }
  }

  Future<void> fetchSentMessages() async {
    try {
      List<Message> sent = await messageService.getSentMessages();
      setState(() {
        sentMessages = sent;
      });
    } catch (e) {
      print('Erreur lors de la récupération des messages envoyés: $e');
    }
  }

  Future<void> sendMessage() async {
    if (messageController.text.isEmpty) return;

    final url = Uri.parse('http://localhost:8080/api/messages/send/${widget.mentorId}');
    final message = Message(
      content: messageController.text,
      utilisateur: Utilisateur(id: 1, nom: 'Votre Nom'),
    );

    try {
      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer ${await authService.getToken()}',
        },
        body: json.encode(message.toJson()),
      );

      if (response.statusCode == 200) {
        messageController.clear();
        fetchMessages();
        fetchSentMessages();
      } else {
        throw Exception('Erreur lors de l\'envoi du message');
      }
    } catch (e) {
      print('Erreur d\'envoi du message: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Chat avec ${widget.mentorName}'),
        backgroundColor: Colors.pinkAccent,
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              itemCount: receivedMessages.length + sentMessages.length,
              itemBuilder: (context, index) {
                final message = index < receivedMessages.length 
                    ? receivedMessages[index] 
                    : sentMessages[index - receivedMessages.length];
                
                bool isSentByUser = message.utilisateur.id == 1;

                return Align(
                  alignment: isSentByUser ? Alignment.centerRight : Alignment.centerLeft,
                  child: Container(
                    margin: EdgeInsets.symmetric(vertical: 5, horizontal: 10),
                    padding: EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: isSentByUser ? Colors.green[200] : const Color.fromARGB(255, 212, 209, 0),
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.grey.withOpacity(0.3),
                          spreadRadius: 1,
                          blurRadius: 5,
                          offset: Offset(0, 3), // changes position of shadow
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: isSentByUser ? CrossAxisAlignment.end : CrossAxisAlignment.start,
                      children: [
                        Text(
                          message.content,
                          style: TextStyle(color: Colors.black, fontSize: 16),
                        ),
                        SizedBox(height: 5),
                        Text(
                          message.utilisateur.nom,
                          style: TextStyle(color: Colors.black54, fontSize: 12),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: messageController,
                    decoration: InputDecoration(
                      hintText: 'Entrez votre message...',
                      border: OutlineInputBorder(),
                      focusedBorder: OutlineInputBorder(
                        borderSide: BorderSide(color: Colors.pinkAccent, width: 2),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderSide: BorderSide(color: Colors.grey, width: 1),
                      ),
                    ),
                  ),
                ),
                IconButton(
                  icon: Icon(Icons.send, color: Colors.pinkAccent),
                  onPressed: sendMessage,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
