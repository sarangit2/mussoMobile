import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:mussomobile/models/formation.dart';
import 'package:path_provider/path_provider.dart'; // Pour obtenir le répertoire de stockage

class CourseDetailsScreen extends StatelessWidget {
  
  final Formation formation;

  CourseDetailsScreen({required this.formation});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFFE7EE),
      appBar: AppBar(primary: true,
       backgroundColor: Colors.white, // Couleur de fond constante
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        title: Text(
          formation.titre,
          style: TextStyle(color: Colors.black),
        ),
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(flex: 3,
            child: Container(
                  padding: const EdgeInsets.all(16.0),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFFE7EE),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Flexible(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                              padding: EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                              decoration: BoxDecoration(
                                color: Colors.pinkAccent,
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: const Text(
                                'Formateur',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                            SizedBox(height: 8.0),
                            Text(
                              'Organisé par ${formation.organisateur}',
                              style: TextStyle(
                                color: Colors.black87,
                                fontSize: 24.0,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Flexible(
                        child: Image.asset(
                          'assets/form.png',
                          height: 180,
                          fit: BoxFit.contain,
                        ),
                      ),
                      const SizedBox(height: 24.0),
                    ],
                  ),
                ),
          ),
          if (formation.videoPath.isNotEmpty)

            Expanded(flex: 7,
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 30,horizontal: 15),
                          decoration: const BoxDecoration(color: Colors.white,
                          borderRadius: BorderRadius.only(topLeft: Radius.circular(20),topRight: Radius.circular(20))
                          ),
                          child: Column(crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                          Text(
                            'Titre de la Vidéo',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 18.0,
                              color: Colors.pinkAccent, // Couleur rouge pour le titre
                            ),
                          ),
                          SizedBox(height: 4.0), // Espace entre le titre et la section "À propos"
                          Text(
                            'À propos : Cette vidéo couvre des sujets importants concernant la formation.',
                            style: TextStyle(
                              color: Colors.black,
                              fontSize: 15.0,
                            ),
                          ),
            
                Expanded(
                  child: SingleChildScrollView(
                    child: Container(
                      child: Column(
                        children: [
                          pdfItem(context, formation.videoPath, 'Vidéo Formation', '500MB'),
                      pdfItem(context, formation.imageUrl, 'pdf Formation', '500MB'),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
              
                          )
                          
                          
                          )),
        ],
      ),
    );
  }

Widget pdfItem(BuildContext context, String title, String date, String size) {
  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      // Titre
      SizedBox(height: 10.0), // Espace avant le Container
      Container(
        padding: EdgeInsets.all(16.0),
        margin: EdgeInsets.only(bottom: 16.0),
        decoration: BoxDecoration(
          color: Color(0xFFFFFFFF), // Couleur de fond blanche
          borderRadius: BorderRadius.circular(12.0),
          boxShadow: [
            BoxShadow(
              color: Colors.black12,
              blurRadius: 4.0,
              offset: Offset(0, 8),
            ),
          ],
        ),
        child: Container(decoration: BoxDecoration(borderRadius: BorderRadius.all(Radius.circular(15)),
  color: Color.fromARGB(255, 228, 227, 227),
        ),
   
  padding: EdgeInsets.all(16.0), // Optionnel : ajouter du padding si nécessaire
  child: Row(
    children: [
      Icon(
        Icons.video_library,
        color: Color(0xFFEC0000),
        size: 36.0,
      ),
      SizedBox(width: 16.0),
      Expanded(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16.0,
              ),
            ),
            SizedBox(height: 4.0),
            Text(
              '$date | $size',
              style: TextStyle(
                color: Colors.grey,
              ),
            ),
          ],
        ),
      ),
      IconButton(
        icon: Icon(
          Icons.download,
          color: Color.fromARGB(255, 168, 120, 114),
        ),
        onPressed: () {
          downloadFile(context, title); // Utilisez title ou un chemin de fichier approprié
        },
      ),
    ],
  ),
),

      ),
    ],
  );
}

  // Méthode pour télécharger le fichier
  Future<void> downloadFile(BuildContext context, String fileUrl) async {
    Dio dio = Dio();
    try {
      var dir = await getApplicationDocumentsDirectory();
      String fileName = fileUrl.split('/').last;
      String filePath = "${dir.path}/$fileName";

      await dio.download(fileUrl, filePath, onReceiveProgress: (received, total) {
        if (total != -1) {
          print("Téléchargé: ${(received / total * 100).toStringAsFixed(0)}%");
        }
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Téléchargement terminé : $fileName")),
      );
    } catch (e) {
      print("Erreur lors du téléchargement : $e");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Échec du téléchargement")),
      );
    }
  }
}
