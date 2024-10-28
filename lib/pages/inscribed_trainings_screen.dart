import 'package:flutter/material.dart';
import 'package:mussomobile/models/formation.dart';
import 'package:mussomobile/service/inscription_service.dart';

class InscribedTrainingsScreen extends StatefulWidget {
  final int userId;
  final String jwtToken;

  InscribedTrainingsScreen({required this.userId, required this.jwtToken});

  @override
  _InscribedTrainingsScreenState createState() => _InscribedTrainingsScreenState();
}

class _InscribedTrainingsScreenState extends State<InscribedTrainingsScreen> {
  late Future<List<Formation>> _inscribedFormations;
  late InscriptionService _inscriptionService;

  @override
  void initState() {
    super.initState();
    _inscriptionService = InscriptionService('http://localhost:8080', widget.jwtToken);
  
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.pinkAccent,
        title: Text('Formations Inscrites', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        centerTitle: true,
      ),
      body: FutureBuilder<List<Formation>>(
        future: _inscribedFormations,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Erreur: ${snapshot.error}'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return Center(child: Text('Aucune formation inscrite.'));
          } else {
            final formations = snapshot.data!;
            return ListView.builder(
              itemCount: formations.length,
              itemBuilder: (context, index) {
                final formation = formations[index];
                return Card(
                  margin: const EdgeInsets.all(8.0),
                  child: ListTile(
                    title: Text(formation.titre),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(formation.description),
                       // Text('Status: ${formation.status}', style: TextStyle(color: Colors.grey)),
                      ],
                    ),
                  ),
                );
              },
            );
          }
        },
      ),
    );
  }
}