import 'dart:convert'; // Import pour jsonDecode
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:mussomobile/models/articles.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:mussomobile/pages/mentor_list_page.dart';
import 'package:mussomobile/pages/training_screen.dart';
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
        _userEmail = userInfo['email'] ?? ''; // Récupérer l'email des infos utilisateur
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
    final response = await http.get(Uri.parse('http://localhost:8080/api/articles/liste'));
    if (response.statusCode == 200) {
      List<dynamic> jsonList = jsonDecode(response.body);
      setState(() {
        _articles = jsonList.map((json) => Article.fromJson(json)).toList();
      });
    } else {
      throw Exception('Échec du chargement des articles');
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
            padding: const EdgeInsets.all(16.0),
            child: Text("Email : $_userEmail", style: TextStyle(fontSize: 18)),
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
            setState(() {
              _selectedTabIndex = index;
            });
            if (index == 1) {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => TrainingScreen()), // Naviguer vers TrainingScreen
              );
            } else if (index == 2) { // Redirection vers MentorsScreen
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => MentorListPage()), // Passer le token JWT
              );
            } else if (index == 0) {
              _stopAudio(); // Arrête l'audio lorsque l'utilisateur clique sur "Articles"
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
              title: Text(article.titre),
              subtitle: Text(article.description),
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconButton(
                    icon: Icon(Icons.visibility, color: Colors.pinkAccent),
                    onPressed: () {
                      _stopAudio(); // Arrête l'audio lorsque l'utilisateur clique sur un article
                      // Logique pour afficher les détails de l'article
                    },
                  ),
                  IconButton(
                    icon: Icon(Icons.record_voice_over, color: Colors.pinkAccent), // Icône pour jouer l'audio
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
