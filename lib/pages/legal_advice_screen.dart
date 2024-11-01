import 'dart:convert'; // Import pour jsonDecode
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:mussomobile/models/articles.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:mussomobile/pages/article_detail_page.dart';
import 'package:mussomobile/pages/mentor_list_page.dart';
import 'package:mussomobile/pages/offre_emploi_page.dart';
import 'package:mussomobile/pages/training_screen.dart';
import 'package:mussomobile/pages/user_profile_page.dart';
import 'package:shared_preferences/shared_preferences.dart'; // Import pour SharedPreferences

class LegalAdviceScreen extends StatefulWidget {
  @override
  _LegalAdviceScreenState createState() => _LegalAdviceScreenState();
}

class _LegalAdviceScreenState extends State<LegalAdviceScreen> {
  int _selectedTabIndex = 0;
  List<Article> _articles = [];
  AudioPlayer _audioPlayer = AudioPlayer();
  bool _isPlaying = false;
  Duration _duration = Duration();
  Duration _position = Duration();
  String _userEmail = ''; // Variable pour stocker l'email de l'utilisateur
  String _jwtToken = ''; // Variable pour stocker le token JWT

  @override
  void initState() {
    super.initState();
    _fetchArticles();
    _loadUserEmail(); // Charger l'email de l'utilisateur lors de l'initialisation
    _loadJwtToken(); // Charger le token JWT lors de l'initialisation
    _audioPlayer.onDurationChanged.listen((duration) {
      setState(() {
        _duration = duration;
      });
    });

    _audioPlayer.onPositionChanged.listen((position) {
      setState(() {
        _position = position;
      });
    });

    

    
  }

  Future<void> _loadUserEmail() async {
    final prefs = await SharedPreferences.getInstance();
    String? userInfoJson = prefs.getString('userInfo');
    if (userInfoJson != null) {
      Map<String, dynamic> userInfo = jsonDecode(userInfoJson);
      setState(() {
        _userEmail = userInfo['email'] ?? ''; 
        // Récupérer l'email des infos utilisateur
      });
    }
  }

  Future<void> _loadJwtToken() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _jwtToken = prefs.getString('jwtToken') ?? ''; // Récupérer le token JWT
    });
  }

Future<void> _fetchArticles() async {
  print('Début de _fetchArticles'); // Confirme que la fonction est appelée
  
  try {
    final response = await http.get(Uri.parse('http://localhost:8080/api/articles/liste'));
    print('Réponse reçue avec code: ${response.statusCode}'); // Affiche le code de statut pour voir s'il est 200

    if (response.statusCode == 200) {
      print('Réponse réussie, décodage du JSON'); // Indique que le code de statut est correct
      List<dynamic> jsonList = jsonDecode(response.body);
      print('JSON décodé avec succès, nombre d\'articles: ${jsonList.length}'); // Confirme que le JSON a été décodé
      
      setState(() {
        _articles = jsonList.map((json) => Article.fromJson(json)).toList();
        print('Articles mis à jour dans l\'état'); // Indique que les articles sont bien ajoutés à l'état
      });
    } else {
      print('Échec du chargement des articles avec le code de statut: ${response.statusCode}');
      throw Exception('Échec du chargement des articles');
    }
  } catch (e) {
    print('Erreur lors de la récupération des articles: $e'); // Affiche toute exception attrapée
  }
}

  void _playAudio(String url) async {
    await _audioPlayer.play(UrlSource(url)); // Joue l'audio à partir de l'URL
    setState(() {
      _isPlaying = true; // Met à jour l'état de lecture
    });
  }

  void _pauseAudio() async {
    await _audioPlayer.pause(); // Met en pause l'audio
    setState(() {
      _isPlaying = false; // Met à jour l'état de lecture
    });
  }

  void _resumeAudio() async {
    await _audioPlayer.resume(); // Reprend la lecture de l'audio
    setState(() {
      _isPlaying = true; // Met à jour l'état de lecture
    });
  }

  void _stopAudio() async {
    await _audioPlayer.stop(); // Stoppe l'audio en cours de lecture
    setState(() {
      _isPlaying = false; // Met à jour l'état de lecture
    });
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
            Navigator.pop(context); // Naviguer en arrière
          },
        ),
      ),
      body: Column(
        children: [
          Padding(
  padding: const EdgeInsets.all(16.0), // Ajoute de l'espace autour du bouton
  child: ElevatedButton(
    onPressed: () {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => OffreEmploiPage()), // Naviguer vers OffreScreen
      );
    },
    style: ElevatedButton.styleFrom(
      foregroundColor: Colors.white, backgroundColor: Colors.pinkAccent, // Couleur du texte
      padding: EdgeInsets.symmetric(vertical: 15, horizontal: 30), // Ajout de padding
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(30), // Coins arrondis
      ),
    ),
    child: Text(
      'Voir les offres',
      style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold), // Style du texte
    ),
  ),
),

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
          if (_isPlaying || _position.inSeconds > 0) ...[
            Slider(
              min: 0.0,
              max: _duration.inSeconds.toDouble() == 0 ? 1 : _duration.inSeconds.toDouble(),
              value: _position.inSeconds.toDouble(),
              onChanged: (value) {
                final newPosition = Duration(seconds: value.toInt());
                _audioPlayer.seek(newPosition); // Change la position de l'audio
              },
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                IconButton(
                  icon: Icon(Icons.pause, color: Colors.pinkAccent),
                  onPressed: _pauseAudio,
                ),
                IconButton(
                  icon: Icon(Icons.play_arrow, color: Colors.pinkAccent),
                  onPressed: _resumeAudio,
                ),
              ],
            ),
          ],
        ],
      ),
     bottomNavigationBar: Theme(
  data: Theme.of(context).copyWith(
    canvasColor: Colors.pinkAccent,
  ),
  child: BottomNavigationBar(
    currentIndex: _selectedTabIndex,
    onTap: (index) {
      if (index != _selectedTabIndex) { // Évite de naviguer vers la même page
        setState(() {
          _selectedTabIndex = index; // Met à jour l'index sélectionné
        });
        
        Widget page;
        switch (index) {
          case 0:
            page = LegalAdviceScreen(); // Page des conseils juridiques
            break;
          case 1:
            page = TrainingScreen(); // Page de formation
            break;
          case 2:
            page = MentorListPage(); // Page des mentors
            break;
          case 3:
            page = UserProfilePage(); // Page de profil utilisateur
            break;
          default:
            page = LegalAdviceScreen(); // Valeur par défaut
        }
        
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => page), // Naviguer vers la page appropriée
        );
      }
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

Widget _getSelectedContent() {
  List<Article> filteredArticles;

  // Check if the selected tab is "Droits" or "Articles" and filter accordingly
  if (_selectedTabIndex == 0) {
    filteredArticles = _articles.where((article) => article.type == ArticleType.Droit).toList();
  } else {
    filteredArticles = _articles.where((article) => article.type == ArticleType.Article).toList();
  }

  return ListView.builder(
    padding: const EdgeInsets.all(8.0),
    itemCount: filteredArticles.length,
    itemBuilder: (context, index) {
      final article = filteredArticles[index];
      return Card(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
        elevation: 2,
        child: ListTile(
          title: Text(article.titre),
          subtitle: Text(article.description),
          trailing: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              IconButton(
                icon: Icon(Icons.visibility, color: Colors.pinkAccent),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => ArticleDetailPage(article: article)),
                  ); // Naviguer vers la page des détails
                },
              ),
              IconButton(
                icon: Icon(Icons.record_voice_over, color: Colors.pinkAccent),
                onPressed: () {
                  _playAudio(article.audioUrl); // Play audio for article
                },
              ),
            ],
          ),
        ),
      );
    },
  );
}

  Widget _buildTabButton(String label, int index) {
    return Expanded(
      child: GestureDetector(
        onTap: () {
          setState(() {
            _selectedTabIndex = index;
            if (index == 1) {
              _stopAudio(); // Stop audio when "Articles" tab is clicked
            }
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