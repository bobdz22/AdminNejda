import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:media_kit/media_kit.dart';
import 'package:media_kit_video/media_kit_video.dart';
import 'package:path_provider/path_provider.dart';
import 'package:video_player/video_player.dart';

class Displayimage extends StatefulWidget {
  Displayimage({super.key, required this.image, required this.video,required this.colors});
  List<String> image;
  String video;
  final Color colors;
  @override
  State<Displayimage> createState() => _DisplayimageState();
}

class _DisplayimageState extends State<Displayimage> {
  Future<List<Uint8List>> fetchImageBytes(List<String> imageNames) async {
    if (imageNames.isEmpty) {
      throw Exception('Image list is empty');
    }

    List<Uint8List> images = [];

    for (String imageName in imageNames) {
      final response = await http.get(Uri.parse("https://nejda.onrender.com/uploads/$imageName"));

      if (response.statusCode == 200) {
        images.add(response.bodyBytes);
      } else {
        throw Exception('Failed to load image: $imageName');
      }
    }

    return images;
  }

  // New method to check if video exists and get its URL
Future<Uint8List?> getVideoData(String videoName) async {
  if (videoName.isEmpty) {
    return null;
  }

  final videoUrl = "https://nejda.onrender.com/uploads/$videoName";

  try {
    final response = await http.get(Uri.parse(videoUrl));

    if (response.statusCode == 200) {
     
      return response.bodyBytes; 
    } else {
      print('Video not found: $videoName');
      return null;
    }
  } catch (e) {
    print('Error fetching video: $e');
    return null;
  }
}
  void _openFullScreenImage(BuildContext context, Uint8List imageBytes) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => FullScreenImageView(imageBytes: imageBytes),
      ),
    );
  }

 void _openFullScreenVideo(BuildContext context, Uint8List videoBytes) {
  Navigator.push(
    context,
    MaterialPageRoute(
      builder: (context) => FullScreenVideoView(videoBytes: videoBytes),
    ),
  );
}

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            children: [
              Row(
                children: [
                  GestureDetector(
                    onTap: () {
                      Navigator.pop(context);
                    },
                    child: Container(
                      padding: EdgeInsets.all(15),
                      decoration: BoxDecoration(
                        color: widget.colors,
                        shape: BoxShape.circle
                      ),
                      child: Icon(Icons.arrow_back, color: Colors.white, size: 50),
                    ),
                  ),
                  SizedBox(width: 40),
                  Text("FastCall Media", style: TextStyle(color: widget.colors, fontSize: 50)),
                ],
              ),
              SizedBox(height: 100),
              Expanded(
                child: Center(
                  child: FutureBuilder<Map<String, dynamic>>(
                   future: Future.wait([
  widget.image.isNotEmpty ? fetchImageBytes(widget.image) : Future.value([]),
  widget.video.isNotEmpty ? getVideoData(widget.video) : Future.value(null)
]).then((results) => {
  'images': results[0],
  'videoBytes': results[1],
}),
                    builder: (context, snapshot) {
                      return LayoutBuilder(
                        builder: (context, constraints) {
                          final isWideScreen = constraints.maxWidth > 800;
                          
                          if (snapshot.connectionState == ConnectionState.waiting) {
                            return Center(
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  const CircularProgressIndicator(
                                    strokeWidth: 2,
                                    valueColor: AlwaysStoppedAnimation(Colors.blue),
                                  ),
                                  const SizedBox(height: 16),
                                  Text(
                                    'Loading Media...',
                                    style: TextStyle(
                                      color: Colors.grey[600],
                                      fontSize: 16,
                                    ),
                                  ),
                                ],
                              ),
                            );
                          }
                          
                          if (snapshot.hasError) {
                            return Center(
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(Icons.error_outline, size: 48, color: Colors.red[400]),
                                  const SizedBox(height: 16),
                                  Text(
                                    'Failed to Load Media',
                                    style: TextStyle(
                                      color: Colors.red[400],
                                      fontSize: 18,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ],
                              ),
                            );
                          }
                          
final images = (snapshot.data?['images'] as List<dynamic>?)?.cast<Uint8List>() ?? [];
                            final videoUrl = snapshot.data?['videoBytes'] as Uint8List?;
                          
                          if ((images.isEmpty || images.isEmpty) && videoUrl == null) {
                            return Center(
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(Icons.no_photography, size: 48, color: Colors.grey[600]),
                                  const SizedBox(height: 16),
                                  Text(
                                    'No Media Available',
                                    style: TextStyle(
                                      color: Colors.grey[600],
                                      fontSize: 18,
                                      fontStyle: FontStyle.italic,
                                    ),
                                  ),
                                ],
                              ),
                            );
                          }
                          
                          // Calculate total items to display (images + video if exists)
                          final totalItems = images.length + (videoUrl != null ? 1 : 0);
                          
                          return GridView.builder(
                            gridDelegate: SliverGridDelegateWithMaxCrossAxisExtent(
                              maxCrossAxisExtent: isWideScreen ? 400 : 300,
                              childAspectRatio: 1.5,
                              mainAxisSpacing: 24,
                              crossAxisSpacing: 24,
                            ),
                            itemCount: totalItems,
                            itemBuilder: (context, index) {
                              // Display video thumbnail as the first item if video exists
                              if (videoUrl != null && index == 0) {
                                return GestureDetector(
                                  onTap: () => _openFullScreenVideo(context, videoUrl),
                                  child: MouseRegion(
                                    cursor: SystemMouseCursors.click,
                                    child: Container(
                                      decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(12),
                                        color: Colors.black87,
                                        boxShadow: [
                                          BoxShadow(
                                            color: Colors.black.withOpacity(0.1),
                                            blurRadius: 6,
                                            offset: const Offset(0, 3),
                                          ),
                                        ],
                                      ),
                                      child: ClipRRect(
                                        borderRadius: BorderRadius.circular(12),
                                        child: Stack(
                                          alignment: Alignment.center,
                                          children: [
                                            Center(
                                              child: Icon(
                                                Icons.video_library,
                                                size: 80,
                                                color: Colors.white70,
                                              ),
                                            ),
                                            Positioned(
                                              bottom: 10,
                                              child: Container(
                                                padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                                decoration: BoxDecoration(
                                                  color: Colors.black.withOpacity(0.6),
                                                  borderRadius: BorderRadius.circular(8),
                                                ),
                                                child: Text(
                                                  'Play Video',
                                                  style: TextStyle(
                                                    color: Colors.white,
                                                    fontWeight: FontWeight.bold,
                                                  ),
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ),
                                );
                              }
                              
                              // Adjust index for images if video exists
                              final imageIndex = videoUrl != null ? index - 1 : index;
                              
                              return GestureDetector(
                                onTap: () => _openFullScreenImage(context, images[imageIndex]),
                                child: MouseRegion(
                                  cursor: SystemMouseCursors.click,
                                  child: Container(
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(12),
                                      boxShadow: [
                                        BoxShadow(
                                          color: Colors.black.withOpacity(0.1),
                                          blurRadius: 6,
                                          offset: const Offset(0, 3),
                                        ),
                                      ],
                                    ),
                                    child: ClipRRect(
                                      borderRadius: BorderRadius.circular(12),
                                      child: Image.memory(
                                        images[imageIndex],
                                        fit: BoxFit.cover,
                                        width: double.infinity,
                                        height: double.infinity,
                                      ),
                                    ),
                                  ),
                                ),
                              );
                            },
                          );
                        },
                      );
                    },
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// Keep the existing FullScreenImageView class

// Add new class for the full-screen video view
class FullScreenVideoView extends StatefulWidget {
   final Uint8List videoBytes;

  const FullScreenVideoView({Key? key, required this.videoBytes}) : super(key: key);

  @override
  State<FullScreenVideoView> createState() => _FullScreenVideoViewState();
}

class _FullScreenVideoViewState extends State<FullScreenVideoView> {
    late final Player _player; // ✅ Initialize in initState
  late final VideoController _controller;
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _player = Player(); // ✅ Initialize player
    _controller = VideoController(_player);
    _loadVideo();
  }

  Future<void> _loadVideo() async {
    try {
      final tempDir = await getTemporaryDirectory();
      final file = File('${tempDir.path}/temp_video.mp4');
      await file.writeAsBytes(widget.videoBytes);

      await _player.open(Media(file.path)); // ✅ Ensure _player is initialized before usage

      setState(() {
        _isLoading = false;
      });

      _player.play();
    } catch (e) {
      setState(() {
        _isLoading = false;
        _errorMessage = 'Error initializing video: ${e.toString()}';
      });
    }
  }

  @override
  void dispose() {
    _player.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          Center(
            child: _isLoading
                ? CircularProgressIndicator(color: Colors.white)
                : _errorMessage != null
                    ? Text(
                        _errorMessage!,
                        style: TextStyle(color: Colors.white),
                      )
                    : Video(controller: _controller),
          ),
          Positioned(
            top: 40,
            left: 20,
            child: SafeArea(
              child: GestureDetector(
                onTap: () => Navigator.pop(context),
                child: Container(
                  padding: EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.4),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(Icons.close, color: Colors.white, size: 30),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
// Add this new class for the full-screen image view
class FullScreenImageView extends StatelessWidget {
  final Uint8List imageBytes;

  const FullScreenImageView({Key? key, required this.imageBytes}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          // Image with zoom capabilities
          GestureDetector(
            onTap: () => Navigator.pop(context),
            child: Center(
              child: InteractiveViewer(
                minScale: 0.5,
                maxScale: 4.0,
                child: Image.memory(
                  imageBytes,
                  fit: BoxFit.contain,
                  width: double.infinity,
                  height: double.infinity,
                ),
              ),
            ),
          ),
   
          Positioned(
            top: 40,
            left: 20,
            child: SafeArea(
              child: GestureDetector(
                onTap: () => Navigator.pop(context),
                child: Container(
                  padding: EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.4),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(Icons.close, color: Colors.white, size: 30),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}