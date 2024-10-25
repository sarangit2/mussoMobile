import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:mussomobile/models/formation.dart';
import 'package:mussomobile/service/auth_service.dart';
import 'package:mussomobile/service/inscription_service.dart'; // Import du service d'inscription
import 'package:shared_preferences/shared_preferences.dart'; // Import pour SharedPreferences

class TrainingScreen extends StatefulWidget {
  @override
  _TrainingScreenState createState() => _TrainingScreenState();
}

class _TrainingScreenState extends State<TrainingScreen> {
  late Future<List<Formation>> formations;
  late Future<Map<String, int>> categoriesWithCount;
  String searchQuery = "";
  final AuthService _authService = AuthService();
  late InscriptionService _inscriptionService; // Déclaration du service d'inscription
  String _userEmail = ''; // Variable pour stocker l'email de l'utilisateur
  int _userId = 0; // Variable pour stocker l'ID de l'utilisateur

  @override
  void initState() {
    super.initState();
    formations = fetchFormations();
    categoriesWithCount = fetchCategoriesWithCount();
    _loadUserInfo(); // Charger les informations de l'utilisateur lors de l'initialisation
    _initializeInscriptionService(); // Initialiser le service d'inscription avec le token
  }

  Future<void> _initializeInscriptionService() async {
    String? token = await _authService.getToken(); // Récupérer le token
    if (token != null) {
      _inscriptionService = InscriptionService('http://localhost:8080', token); // Initialiser le service avec le token
    } else {
      // Gérer le cas où le token est null (ex: déconnexion)
      print('Aucun token trouvé, utilisateur non connecté.');
      // Vous pouvez rediriger vers l'écran de connexion ici si nécessaire
    }
  }

  Future<void> _loadUserInfo() async {
    final prefs = await SharedPreferences.getInstance();
    String? userInfoJson = prefs.getString('userInfo');
    if (userInfoJson != null) {
      Map<String, dynamic> userInfo = jsonDecode(userInfoJson);
      setState(() {
        _userEmail = userInfo['email'] ?? ''; // Récupérer l'email des infos utilisateur
        _userId = userInfo['id'] ?? 0; // Récupérer l'ID des infos utilisateur
      });
    }
  }

  // Méthode pour récupérer la liste des formations
  Future<List<Formation>> fetchFormations() async {
    final response = await http.get(Uri.parse('http://localhost:8080/api/formations/liste'));

    if (response.statusCode == 200) {
      List jsonResponse = json.decode(response.body);
      return jsonResponse.map((formation) => Formation.fromJson(formation)).toList();
    } else {
      throw Exception('Échec du chargement des formations');
    }
  }

  // Méthode pour récupérer les catégories avec le nombre de formations
  Future<Map<String, int>> fetchCategoriesWithCount() async {
    final formations = await fetchFormations();
    Map<String, int> categoryCounts = {};

    for (var formation in formations) {
      String category = formation.categorie;
      categoryCounts[category] = (categoryCounts[category] ?? 0) + 1;
    }

    return categoryCounts;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.pinkAccent,
        title: Text('Formations', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        centerTitle: true,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Afficher l'email et l'ID de l'utilisateur
            Padding(
              padding: const EdgeInsets.only(bottom: 16.0),
              child: Text("Email : $_userEmail\nID Utilisateur : $_userId", style: TextStyle(fontSize: 18)),
            ),
            FutureBuilder<Map<String, int>>(
              future: categoriesWithCount,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Center(child: CircularProgressIndicator());
                } else if (snapshot.hasError) {
                  return Text('Erreur: ${snapshot.error}');
                } else {
                  return SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: snapshot.data!.entries.map((entry) {
                        return Padding(
                          padding: const EdgeInsets.only(right: 8.0),
                          child: CategoryButton(entry.key, entry.value),
                        );
                      }).toList(),
                    ),
                  );
                }
              },
            ),
            SizedBox(height: 16),
            TextField(
              onChanged: (value) {
                setState(() {
                  searchQuery = value.toLowerCase();
                });
              },
              decoration: InputDecoration(
                hintText: 'Recherche',
                prefixIcon: Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(30),
                  borderSide: BorderSide.none,
                ),
                filled: true,
                fillColor: Colors.grey[200],
              ),
            ),
            SizedBox(height: 16),
            Expanded(
              child: FutureBuilder<List<Formation>>(
                future: formations,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return Center(child: CircularProgressIndicator());
                  } else if (snapshot.hasError) {
                    return Center(child: Text('Erreur: ${snapshot.error}'));
                  } else {
                    final filteredFormations = snapshot.data!.where((formation) {
                      return formation.titre.toLowerCase().contains(searchQuery);
                    }).toList();

                    return ListView.builder(
                      itemCount: filteredFormations.length,
                      itemBuilder: (context, index) {
                        final formation = filteredFormations[index];
                        return CourseCard(
                          formation,
                          () => _showConfirmationDialog(formation.id), // Call the dialog here
                        );
                      },
                    );
                  }
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Méthode pour afficher la boîte de dialogue de confirmation
  void _showConfirmationDialog(int formationId) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Confirmer l\'inscription'),
          content: Text('Êtes-vous sûr de vouloir vous inscrire à cette formation?'),
          actions: [
            TextButton(
              child: Text('Annuler'),
              onPressed: () {
                Navigator.of(context).pop(); // Fermer le dialogue
              },
            ),
            TextButton(
              child: Text('Confirmer'),
              onPressed: () async {
                Navigator.of(context).pop(); // Fermer le dialogue
                await registerForFormation(formationId); // Appeler l'inscription
              },
            ),
          ],
        );
      },
    );
  }

  // Méthode pour s'inscrire à une formation
  Future<void> registerForFormation(int formationId) async {
    bool success = await _inscriptionService.registerForFormation(formationId);
    if (success) {
      // Inscription réussie
      print('Inscription réussie pour la formation ID: $formationId');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Inscription réussie !')),
      );
    } else {
      // Échec de l'inscription
      print('Échec de l\'inscription pour la formation ID: $formationId');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Échec de l\'inscription.')),
      );
    }
  }
}

class CategoryButton extends StatelessWidget {
  final String category;
  final int count;

  CategoryButton(this.category, this.count);

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: () {
        // Logique pour gérer le clic sur la catégorie
      },
      child: Text('$category ($count)'),
    );
  }
}

class CourseCard extends StatelessWidget {
  final Formation formation;
  final VoidCallback onFollow;

  CourseCard(this.formation, this.onFollow);

  @override
  Widget build(BuildContext context) {
    final imageUrl = formation.imageUrl;

    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: ListTile(
        leading: ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: imageUrl.isNotEmpty
              ? Image.network(
                  imageUrl,
                  width: 50,
                  height: 50,
                  fit: BoxFit.cover,
                )
              : Container(
                  width: 50,
                  height: 50,
                  color: Colors.pinkAccent,
                  child: Icon(Icons.image, color: Colors.white),
                ),
        ),
        title: Text(formation.titre),
        subtitle: Text(formation.description),
        trailing: ElevatedButton(
          onPressed: onFollow, // Appel de la méthode de confirmation ici
          style: ElevatedButton.styleFrom(
            foregroundColor: Colors.white, backgroundColor: Colors.pinkAccent, // Change the text color to white
          ),
          
          child: Text("S'inscrire"),
        ),
      ),
    );
  }
}
