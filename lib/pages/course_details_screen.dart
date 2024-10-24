import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:mussomobile/models/formation.dart';
import 'package:video_player/video_player.dart';
import 'package:path_provider/path_provider.dart'; // Pour obtenir le répertoire de stockage
import 'package:open_file/open_file.dart'; // Import pour ouvrir le fichier

class CourseDetailsScreen extends StatefulWidget {
  final Formation formation;

  CourseDetailsScreen({required this.formation});

  @override
  _CourseDetailsScreenState createState() => _CourseDetailsScreenState();
}

class _CourseDetailsScreenState extends State<CourseDetailsScreen> {
  late VideoPlayerController _videoController;

  @override
  void initState() {
    super.initState();
    if (widget.formation.videoPath.isNotEmpty) {
      _videoController = VideoPlayerController.network(widget.formation.videoPath)
        ..initialize().then((_) {
          setState(() {}); // Mise à jour de l'état lorsque la vidéo est prête
        });
    }
  }

  @override
  void dispose() {
    if (widget.formation.videoPath.isNotEmpty) {
      _videoController.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFFE7EE),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        title: Text(
          widget.formation.titre,
          style: TextStyle(color: Colors.black),
        ),
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Partie supérieure avec le formateur et l'image
          Expanded(
            flex: 3,
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
                          'Organisé par ${widget.formation.organisateur}',
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

          // Partie avec vidéo et PDF
          Expanded(
            flex: 7,
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 30, horizontal: 15),
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(20),
                  topRight: Radius.circular(20),
                ),
              ),
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Vidéo
                    if (widget.formation.videoPath.isNotEmpty)
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Titre de la Vidéo',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 18.0,
                              color: Colors.pinkAccent,
                            ),
                          ),
                          SizedBox(height: 4.0),
                          Text(
                            'À propos : Cette vidéo couvre des sujets importants concernant la formation.',
                            style: TextStyle(
                              color: Colors.black,
                              fontSize: 15.0,
                            ),
                          ),
                          SizedBox(height: 16.0),
                          _videoController.value.isInitialized
                              ? AspectRatio(
                                  aspectRatio: _videoController.value.aspectRatio,
                                  child: VideoPlayer(_videoController),
                                )
                              : Center(child: CircularProgressIndicator()),
                          VideoProgressIndicator(_videoController, allowScrubbing: true),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              IconButton(
                                icon: Icon(
                                  _videoController.value.isPlaying ? Icons.pause : Icons.play_arrow,
                                ),
                                onPressed: () {
                                  setState(() {
                                    _videoController.value.isPlaying
                                        ? _videoController.pause()
                                        : _videoController.play();
                                  });
                                },
                              ),
                            ],
                          ),
                          SizedBox(height: 24.0),
                        ],
                      ),

                    // PDF
                    if (widget.formation.imageUrl.isNotEmpty)
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Ressources PDF',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 18.0,
                              color: Colors.pinkAccent,
                            ),
                          ),
                          SizedBox(height: 16.0),
                          pdfItem(
                            context,
                            widget.formation.imageUrl,
                            'PDF Formation',
                            '500MB',
                          ),
                        ],
                      ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget pdfItem(BuildContext context, String url, String title, String size) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(height: 10.0),
        Container(
          padding: EdgeInsets.all(16.0),
          margin: EdgeInsets.only(bottom: 16.0),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12.0),
            boxShadow: [
              BoxShadow(
                color: Colors.black12,
                blurRadius: 4.0,
                offset: Offset(0, 8),
              ),
            ],
          ),
          child: Row(
            children: [
              Icon(
                Icons.picture_as_pdf,
                color: Colors.red,
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
                      '$size',
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
                  color: Colors.pinkAccent,
                ),
                onPressed: () async {
                  String? filePath = await downloadPdf(url);
                  if (filePath != null) {
                    OpenFile.open(filePath); // Ouvrir le fichier PDF
                  }
                },
              ),
            ],
          ),
        ),
      ],
    );
  }

  Future<String?> downloadPdf(String url) async {
    try {
      // Obtenir le répertoire temporaire
      Directory tempDir = await getTemporaryDirectory();
      String filePath = '${tempDir.path}/formation.pdf';

      // Télécharger le PDF
      await Dio().download(url, filePath);
      return filePath; // Retourner le chemin du fichier
    } catch (e) {
      print('Erreur de téléchargement: $e');
      return null; // Retourner null en cas d'erreur
    }
  }
}
