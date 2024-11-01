import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:mussomobile/service/auth_service.dart';

class OffreEmploiPage extends StatefulWidget {
  @override
  _OffreEmploiPageState createState() => _OffreEmploiPageState();
}

class _OffreEmploiPageState extends State<OffreEmploiPage> {
  List<dynamic> offresEmploi = []; // Liste pour stocker les offres d'emploi

  @override
  void initState() {
    super.initState();
    fetchOffresEmploi(); // Récupère les offres d'emploi lors de l'initialisation
  }

  Future<void> fetchOffresEmploi() async {
    final response = await http.get(
      Uri.parse('http://localhost:8080/api/offres/liste'),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
    );

    if (response.statusCode == 200) {
      setState(() {
        offresEmploi = json.decode(response.body); // Décode la réponse JSON
      });
    } else {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('Erreur lors de la récupération des offres d\'emploi.'),
      ));
    }
  }

  Future<void> addOffreEmploi(String titre, String description, String entreprise, String localisation) async {
    AuthService authService = AuthService();
    String? token = await authService.getToken();

    if (token == null) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('Erreur : token non disponible.'),
      ));
      return;
    }

    final response = await http.post(
      Uri.parse('http://localhost:8080/api/offres/ajout'),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode(<String, dynamic>{
        'titre': titre,
        'description': description,
        'entreprise': entreprise,
        'localisation': localisation,
        'datePublication': DateTime.now().toIso8601String(),
        'dateExpiration': DateTime.now().add(Duration(days: 30)).toIso8601String(), // Par exemple, expire dans 30 jours
      }),
    );

    if (response.statusCode == 200) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('Offre d\'emploi ajoutée avec succès!'),
      ));
      fetchOffresEmploi(); // Met à jour la liste après ajout
    } else {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('Erreur lors de l\'ajout de l\'offre d\'emploi.'),
      ));
    }
  }

  void _showAddOffreEmploiDialog() {
    final _formKey = GlobalKey<FormState>();
    String titre = '';
    String description = '';
    String entreprise = '';
    String localisation = '';

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Ajouter Offre d\'Emploi', style: TextStyle(color: Colors.pinkAccent)),
          content: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextFormField(
                  decoration: InputDecoration(labelText: 'Titre', labelStyle: TextStyle(color: Colors.pinkAccent)),
                  onChanged: (value) {
                    titre = value;
                  },
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Veuillez entrer un titre';
                    }
                    return null;
                  },
                ),
                TextFormField(
                  decoration: InputDecoration(labelText: 'Description', labelStyle: TextStyle(color: Colors.pinkAccent)),
                  onChanged: (value) {
                    description = value;
                  },
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Veuillez entrer une description';
                    }
                    return null;
                  },
                ),
                TextFormField(
                  decoration: InputDecoration(labelText: 'Entreprise', labelStyle: TextStyle(color: Colors.pinkAccent)),
                  onChanged: (value) {
                    entreprise = value;
                  },
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Veuillez entrer le nom de l\'entreprise';
                    }
                    return null;
                  },
                ),
                TextFormField(
                  decoration: InputDecoration(labelText: 'Localisation', labelStyle: TextStyle(color: Colors.pinkAccent)),
                  onChanged: (value) {
                    localisation = value;
                  },
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Veuillez entrer une localisation';
                    }
                    return null;
                  },
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                if (_formKey.currentState!.validate()) {
                  addOffreEmploi(titre, description, entreprise, localisation);
                  Navigator.of(context).pop(); // Ferme le dialogue
                }
              },
              child: Text('Ajouter', style: TextStyle(color: Colors.pinkAccent)),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Ferme le dialogue
              },
              child: Text('Annuler', style: TextStyle(color: Colors.grey)),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
     appBar: AppBar(
  title: Text(
    'Gestion des Offres d\'Emploi',
    style: TextStyle(color: Colors.white), // Couleur du texte en blanc
  ),
  backgroundColor: Colors.pinkAccent,
  iconTheme: IconThemeData(color: Colors.white), // Couleur de l'icône en blanc
  actions: [
    IconButton(
      icon: Icon(Icons.add),
      onPressed: _showAddOffreEmploiDialog, // Ouvre le dialogue pour ajouter une offre
    ),
  ],
),

      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              Text(
                'Liste des Offres d\'Emploi',
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.pinkAccent),
              ),
              SizedBox(height: 10),
              ListView.builder(
                shrinkWrap: true,
                physics: NeverScrollableScrollPhysics(), // Pour éviter le défilement
                itemCount: offresEmploi.length,
                itemBuilder: (context, index) {
                  return Card(
                    margin: EdgeInsets.symmetric(vertical: 5),
                    elevation: 4,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Titre: ${offresEmploi[index]['titre']}', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.pinkAccent)),
                          SizedBox(height: 5),
                          Text('Description: ${offresEmploi[index]['description']}'),
                          SizedBox(height: 5),
                          Text('Entreprise: ${offresEmploi[index]['entreprise']}', style: TextStyle(fontStyle: FontStyle.italic)),
                          SizedBox(height: 5),
                          Text('Localisation: ${offresEmploi[index]['localisation']}'),
                          SizedBox(height: 5),
                          Text('Date de Publication: ${offresEmploi[index]['datePublication']}', style: TextStyle(color: Colors.grey)),
                          SizedBox(height: 5),
                          Text('Date d\'Expiration: ${offresEmploi[index]['dateExpiration']}', style: TextStyle(color: Colors.grey)),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
