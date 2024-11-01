import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:mussomobile/models/message.dart';
import 'package:mussomobile/service/auth_service.dart';

class MessageService {
  final AuthService authService = AuthService();

  Future<List<Message>> getReceivedMessages() async {
    final url = Uri.parse('http://localhost:8080/api/messages/received');

    final response = await http.get(
      url,
      headers: {
        'Authorization': 'Bearer ${await authService.getToken()}',
        'Content-Type': 'application/json',
      },
    );

    if (response.statusCode == 200) {
      List<dynamic> jsonData = json.decode(response.body);
      return jsonData.map((message) => Message.fromJson(message)).toList();
    } else {
      throw Exception('Erreur lors de la récupération des messages reçus');
    }
  }

  Future<void> acceptDiscussion(int userId) async {
    final url = Uri.parse('http://localhost:8080/api/messages/accept/$userId');
    final response = await http.post(
      url,
      headers: {
        'Authorization': 'Bearer ${await authService.getToken()}',
        'Content-Type': 'application/json',
      },
    );

    if (response.statusCode != 200) {
      throw Exception('Erreur lors de l\'acceptation de la discussion');
    }
  }
Future<void> sendMessage(Message message) async {
  final url = Uri.parse('http://localhost:8080/api/messages/send');

  // Imprimer l'URL de la requête
  print('URL de la requête : $url');

  // Imprimer le contenu du message avant l'envoi
  print('Message à envoyer : ${message.toJson()}');

  try {
    final response = await http.post(
      url,
      headers: {
        'Authorization': 'Bearer ${await authService.getToken()}',
        'Content-Type': 'application/json',
      },
      body: json.encode(message.toJson()), // Convertissez le message en JSON
    );

    // Imprimer le code de statut de la réponse
    print('Code de statut de la réponse : ${response.statusCode}');

    if (response.statusCode != 200) {
      // Imprimer le contenu de la réponse en cas d'erreur
      print('Réponse de l\'API : ${response.body}');
      throw Exception('Erreur lors de l\'envoi du message');
    } else {
      // Imprimer un message de succès
      print('Message envoyé avec succès !');
    }
  } catch (e) {
    // Imprimer l'erreur en cas d'exception
    print('Erreur lors de l\'envoi du message : $e');
  }
}


Future<List<Message>> getSentMessages() async {
  final url = Uri.parse('http://localhost:8080/api/messages/sent');

  final response = await http.get(
    url,
    headers: {
      'Authorization': 'Bearer ${await authService.getToken()}',
      'Content-Type': 'application/json',
    },
  );

  if (response.statusCode == 200) {
    List<dynamic> jsonData = json.decode(response.body);
    return jsonData.map((message) => Message.fromJson(message)).toList();
  } else {
    throw Exception('Erreur lors de la récupération des messages envoyés');
  }
}


Future<Message> sendMessageToMentor(int mentorId, Message message) async {
  final url = Uri.parse('http://localhost:8080/api/messages/send/$mentorId');

  // Imprimer l'URL de la requête
  print('URL de la requête : $url');

  // Imprimer le contenu du message avant l'envoi
  print('Message à envoyer : ${message.toJson()}');

  try {
    final response = await http.post(
      url,
      headers: {
        'Authorization': 'Bearer ${await authService.getToken()}',
        'Content-Type': 'application/json',
      },
      body: json.encode(message.toJson()), // Convertissez le message en JSON
    );

    // Imprimer le code de statut de la réponse
    print('Code de statut de la réponse : ${response.statusCode}');

    if (response.statusCode == 200) {
      final jsonResponse = json.decode(response.body);
      return Message.fromJson(jsonResponse); // Retourner le message sauvegardé
    } else {
      // Imprimer le contenu de la réponse en cas d'erreur
      print('Réponse de l\'API : ${response.body}');
      throw Exception('Erreur lors de l\'envoi du message');
    }
  } catch (e) {
    // Imprimer l'erreur en cas d'exception
    print('Erreur lors de l\'envoi du message : $e');
    throw e; // Lancer l'exception pour le gestionnaire d'erreurs
  }
}


}
