import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:mussomobile/models/formation.dart';
import 'course_details_screen.dart'; // Import de l'écran des détails de la formation

class TrainingScreen extends StatefulWidget {
  @override
  _TrainingScreenState createState() => _TrainingScreenState();
}

class _TrainingScreenState extends State<TrainingScreen> {
  late Future<List<Formation>> formations;
  late Future<Set<String>> categories; // Variable pour les catégories

  @override
  void initState() {
    super.initState();
    formations = fetchFormations();
    categories = fetchCategories(); // Récupérer les catégories
  }

  Future<List<Formation>> fetchFormations() async {
    final response = await http.get(Uri.parse('http://localhost:8080/api/formations/liste'));

    if (response.statusCode == 200) {
      List jsonResponse = json.decode(response.body);
      return jsonResponse.map((formation) => Formation.fromJson(formation)).toList();
    } else {
      throw Exception('Failed to load formations');
    }
  }

  Future<Set<String>> fetchCategories() async {
    final response = await http.get(Uri.parse('http://localhost:8080/api/categories/liste'));

    if (response.statusCode == 200) {
      List jsonResponse = json.decode(response.body);
      return jsonResponse.map<String>((categorie) => categorie.toString()).toSet();
    } else {
      throw Exception('Failed to load categories');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.pinkAccent,
        title: Text('Formations', style: TextStyle(color: Colors.white)),
        centerTitle: true,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () {
            Navigator.pop(context); // Retour en arrière
          },
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            FutureBuilder<Set<String>>(
              future: categories,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return CircularProgressIndicator();
                } else if (snapshot.hasError) {
                  return Text('Error: ${snapshot.error}');
                } else {
                  return SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: snapshot.data!.map((category) {
                        return Padding(
                          padding: const EdgeInsets.only(right: 8.0),
                          child: CategoryButton(category, 0),
                        );
                      }).toList(),
                    ),
                  );
                }
              },
            ),
            SizedBox(height: 16),
            TextField(
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
                    return Center(child: Text('Error: ${snapshot.error}'));
                  } else {
                    return ListView.builder(
                      itemCount: snapshot.data?.length,
                      itemBuilder: (context, index) {
                        return CourseCard(
                          snapshot.data![index],
                          () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => CourseDetailsScreen(formation: snapshot.data![index]),
                              ),
                            );
                          },
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
}

class CategoryButton extends StatelessWidget {
  final String label;
  final int courseCount;

  CategoryButton(this.label, this.courseCount);

  @override
  Widget build(BuildContext context) {
    return Chip(
      label: Text('$label\n$courseCount Cours'),
      backgroundColor: Colors.pink[100],
      padding: EdgeInsets.symmetric(vertical: 8, horizontal: 16),
    );
  }
}

class CourseCard extends StatelessWidget {
  final Formation formation;
  final VoidCallback onFollow; // Callback pour le bouton "Suivre Formation"

  CourseCard(this.formation, this.onFollow);

  @override
  Widget build(BuildContext context) {
    // Vérification de l'URL de l'image
    final imageUrl = formation.imageUrl;

    // Afficher l'URL dans la console pour débogage
    print('Image URL: $imageUrl');

    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: ListTile(
       leading: imageUrl.isNotEmpty
    ? Image.network(
        imageUrl,
        width: 50,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) {
          print('Image loading error: $error');
          return Image.asset(
            'assets/form.png', // Image par défaut en cas d'erreur
            width: 50,
          );
        },
      )
    : Image.asset('assets/form.png', width: 50), // Placeholder si l'URL de l'image est nulle

        title: Text(formation.titre),
        subtitle: Text(formation.organisateur),
        trailing: ElevatedButton(
          onPressed: onFollow,
          child: Text("Suivre Formation"),
          style: ElevatedButton.styleFrom(backgroundColor: Colors.pinkAccent),
        ),
      ),
    );
  }
}
