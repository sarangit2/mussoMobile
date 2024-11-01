import 'package:flutter/material.dart';
import 'package:mussomobile/models/formation.dart';
import 'package:video_player/video_player.dart';
import 'package:flutter_pdfview/flutter_pdfview.dart';

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
    
    // Vérification du lien PDF
    print(widget.formation.pdfPath);
    
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

  void _openPdfViewer() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => PDFView(
          filePath: widget.formation.pdfPath,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFFE7EE),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        
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
                    // PDF Button
                    if (widget.formation.pdfPath.isNotEmpty)
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Document PDF',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 18.0,
                              color: Colors.pinkAccent,
                            ),
                          ),
                          SizedBox(height: 4.0),
                          Text(
                            'Cliquez ci-dessous pour lire le document PDF.',
                            style: TextStyle(
                              color: Colors.black,
                              fontSize: 15.0,
                            ),
                          ),
                          SizedBox(height: 8.0),
                          ElevatedButton.icon(
                            onPressed: _openPdfViewer,
                            icon: Icon(Icons.picture_as_pdf),
                            label: Text('Ouvrir le PDF'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.pinkAccent,
                            ),
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
}
