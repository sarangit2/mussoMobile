
import 'dart:convert'; // Import pour jsonDecode
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:mussomobile/models/articles.dart';
import 'package:audioplayers/audioplayers.dart'; // Import du plugin

class LegalAdviceScreen extends StatefulWidget {
  @override
  _LegalAdviceScreenState createState() => _LegalAdviceScreenState();
}

class _LegalAdviceScreenState extends State<LegalAdviceScreen> {
  int _selectedTabIndex = 0;
  List<Article> _articles = [];
  AudioPlayer _audioPlayer = AudioPlayer(); // Instance de AudioPlayer

  @override
  void initState() {
    super.initState();
    _fetchArticles();
  }

  Future<void> _fetchArticles() async {
    final response = await http.get(Uri.parse('http://localhost:8080/api/articles/liste'));

    if (response.statusCode == 200) {
      List<dynamic> jsonList = jsonDecode(response.body);
      setState(() {
        _articles = jsonList.map((json) => Article.fromJson(json)).toList();
      });
    } else {
      throw Exception('Failed to load articles');
    }
  }

  void _playAudio(String url) async {
    // Créez une source à partir de l'URL et jouez-la
    await _audioPlayer.play(UrlSource(url)); // Joue l'audio à partir de l'URL
  }

  Widget _getSelectedContent() {
    if (_selectedTabIndex == 0) {
      return ListView.builder(
        padding: const EdgeInsets.all(8.0),
        itemCount: _articles.length,
        itemBuilder: (context, index) {
          final article = _articles[index];
          return Card(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
            elevation: 2,
            child: ListTile(
              leading: Icon(Icons.record_voice_over, color: Colors.pinkAccent),
              title: Text(article.titre),
              subtitle: Text(article.description),
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconButton(
                    icon: Icon(Icons.visibility, color: Colors.pinkAccent),
                    onPressed: () {
                      // Handle view details action
                    },
                  ),
                  IconButton(
                    icon: Icon(Icons.play_arrow, color: Colors.pinkAccent), // Icône pour jouer l'audio
                    onPressed: () {
                      _playAudio(article.audioUrl); // Appel à la méthode pour jouer l'audio
                    },
                  ),
                ],
              ),
            ),
          );
        },
      );
    } else {
      // Gérer les autres sections
      return Center(child: Text('Autres contenus à venir...'));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.pinkAccent,
        title: Text("Conseils Juridiques"),
        centerTitle: true,
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () {
            // Ajouter la fonctionnalité de retour
          },
        ),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: TextField(
              decoration: InputDecoration(
                hintText: "Recherche",
                prefixIcon: Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(30),
                  borderSide: BorderSide.none,
                ),
                filled: true,
                fillColor: Colors.grey[200],
              ),
            ),
          ),
          Container(
            decoration: BoxDecoration(
              color: Colors.grey[100],
              borderRadius: BorderRadius.circular(10),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _buildTabButton("Droits", 0),
                _buildTabButton("Articles", 1),
              ],
            ),
          ),
          Expanded(
            child: _getSelectedContent(),
          ),
        ],
      ),
      bottomNavigationBar: Theme(
        data: Theme.of(context).copyWith(
          canvasColor: Colors.pinkAccent,
        ),
        child: BottomNavigationBar(
          currentIndex: _selectedTabIndex,
          onTap: (index) {
            setState(() {
              _selectedTabIndex = index;
            });
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

  Widget _buildTabButton(String label, int index) {
    return Expanded(
      child: GestureDetector(
        onTap: () {
          setState(() {
            _selectedTabIndex = index;
          });
        },
        child: Container(
          padding: EdgeInsets.symmetric(vertical: 16),
          decoration: BoxDecoration(
            color: _selectedTabIndex == index ? Colors.pinkAccent : Colors.white,
            borderRadius: BorderRadius.circular(10),
          ),
          child: Center(
            child: Text(
              label,
              style: TextStyle(
                color: _selectedTabIndex == index ? Colors.white : Colors.black,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
