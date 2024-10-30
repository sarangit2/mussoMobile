import 'package:flutter/material.dart';
import 'package:mussomobile/models/message.dart';
import 'package:mussomobile/service/auth_service.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class ReceivedMessagesPage extends StatefulWidget {
  @override
  _ReceivedMessagesPageState createState() => _ReceivedMessagesPageState();
}

class _ReceivedMessagesPageState extends State<ReceivedMessagesPage> {
  final AuthService authService = AuthService();
  late Future<List<Message>> messagesFuture;

  @override
  void initState() {
    super.initState();
    messagesFuture = _fetchReceivedMessages();
  }

 Future<List<Message>> _fetchReceivedMessages() async {
  final url = Uri.parse('http://localhost:8080/api/messages/received'); // Changez localhost par votre IP
  final token = await authService.getToken();
  print('Token: $token'); // Debugging line

  final response = await http.get(
    url,
    headers: {
      'Authorization': 'Bearer $token',
    },
  );

  print('Response status: ${response.statusCode}'); // Debugging line
  print('En-têtes : ${{
    'Authorization': 'Bearer $token',
  }}'); // Debugging line

  if (response.statusCode == 200) {
    List<dynamic> jsonResponse = json.decode(response.body);
    return jsonResponse.map((message) => Message.fromJson(message)).toList();
  } else {
    print('Response body: ${response.body}'); // Debugging line
    throw Exception('Failed to load messages');
  }
}

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Messages Reçus'),
        backgroundColor: Color(0xFFFF4D6D),
      ),
      body: FutureBuilder<List<Message>>(
        future: messagesFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Erreur : ${snapshot.error}'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return Center(child: Text('Aucun message reçu.'));
          }

          return ListView.builder(
            itemCount: snapshot.data!.length,
            itemBuilder: (context, index) {
              final message = snapshot.data![index];
              return ListTile(
                title: Text(message.content),
                subtitle: Text('De : ${message.email}'),
              );
            },
          );
        },
      ),
    );
  }
}
