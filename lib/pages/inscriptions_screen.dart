import 'package:flutter/material.dart';
import 'package:mussomobile/models/inscription.dart';
import 'package:mussomobile/pages/course_details_screen.dart';
import 'package:mussomobile/service/inscription_service.dart';

class InscriptionsScreen extends StatefulWidget {
  final String baseUrl; // URL de base pour le service
  final String jwtToken; // Jeton JWT pour l'authentification

  InscriptionsScreen({required this.baseUrl, required this.jwtToken});

  @override
  _InscriptionsScreenState createState() => _InscriptionsScreenState();
}

class _InscriptionsScreenState extends State<InscriptionsScreen> {
  late Future<List<Inscription>> futureInscriptions;

  @override
  void initState() {
    super.initState();
    // Initialiser la récupération des inscriptions
    futureInscriptions = InscriptionService(widget.baseUrl, widget.jwtToken).fetchUserInscriptions();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Mes Inscriptions'),
        foregroundColor: Colors.pinkAccent,
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [const Color.fromARGB(255, 228, 143, 171)!, Colors.white],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: FutureBuilder<List<Inscription>>(
          future: futureInscriptions,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return Center(child: CircularProgressIndicator()); // Chargement
            } else if (snapshot.hasError) {
              return Center(child: Text('Erreur: ${snapshot.error}')); // Erreur
            } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
              return Center(child: Text('Aucune inscription trouvée')); // Pas d'inscriptions
            } else {
              return ListView.builder(
                padding: EdgeInsets.all(16.0),
                itemCount: snapshot.data!.length,
                itemBuilder: (context, index) {
                  final inscription = snapshot.data![index];
                  return Card(
                    margin: EdgeInsets.symmetric(vertical: 8.0),
                    elevation: 4,
                    child: ListTile(
                      leading: Icon(Icons.school, size: 40, color: Colors.pinkAccent), // Icône de formation
                      title: Column(crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            inscription.formation.titre,
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                          Text('Statut: ${inscription.status}'),
                          Text('Date: ${inscription.dateInscription.toLocal()}'),
                        ],
                      ), // Afficher le titre de la formation
                      // subtitle: Column(
                      //   crossAxisAlignment: CrossAxisAlignment.start,
                      //   children: [
                      //     Text('Statut: ${inscription.status}'),
                      //     Text('Date: ${inscription.dateInscription.toLocal()}'),
                      //   ],
                      // ), // Afficher le statut et la date
                     
                      // isThreeLine: true,
                      subtitle: inscription.status == 'APPROUVER'
                          ? ElevatedButton(style: ElevatedButton.styleFrom(backgroundColor: Colors.pinkAccent),
                              onPressed: () {
                                // Logique pour suivre la formation
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => CourseDetailsScreen(formation: inscription.formation),
                                  ),
                                );
                              },
                              child: const Text('Suivre la formation',style: TextStyle(color: Colors.white),),
                            )
                          : null, // Pas de bouton si le statut n'est pas APPROUVER
                    ),
                  );
                },
              );
            }
          },
        ),
      ),
    );
  }
}
