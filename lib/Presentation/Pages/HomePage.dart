import 'dart:async';
import 'dart:collection';
import 'dart:io';
import 'dart:typed_data';

import 'package:administration_emergency/Data/Models/EmergencyModel.dart';
import 'package:administration_emergency/Data/Services/Emergency_services.dart';
import 'package:administration_emergency/Presentation/Pages/DescriptionInfo.dart';
import 'package:administration_emergency/Presentation/Pages/DisplayImage.dart';
import 'package:administration_emergency/Presentation/Pages/validePage.dart';


import 'package:bitsdojo_window/bitsdojo_window.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:just_audio/just_audio.dart';

import 'package:path_provider/path_provider.dart';

class Homepage extends StatefulWidget {
     Homepage({super.key,required this.color,required this.Type});
  final Color color;
  final String Type;
 
  @override
  State<Homepage> createState() => _HomepageState();
}

class _HomepageState extends State<Homepage> {
 late EmergencyServices emergencyServices;
  final TextEditingController _searchController = TextEditingController();
  bool _isLoading = true;
  Uint8List?  imageBytes;
  
  
  @override
  void initState() {
    super.initState();
 
    // Initialize emergency services
    emergencyServices = EmergencyServices();
    
    // Start periodic updates
    emergencyServices.startRealTimeUpdates(widget.Type);
    
    // Add search listener
    _searchController.addListener(() {
      emergencyServices.updateSearchQuery(_searchController.text);
    });
  }
  
  @override
  void dispose() {
    emergencyServices.dispose();
    _searchController.dispose();
    super.dispose();
  }
  
  void _toggleFilter(String type) {
    emergencyServices.toggleFilter(type);
  }

  
Future<Uint8List> fetchImageBytes(String imageName) async {
 

  // Check if the image is already in cache
  if (ImageCache.hasInCache(imageName)) {
    return ImageCache.getFromCache(imageName)!;
  }

  // If not in cache, fetch from network
  final response = await http.get(Uri.parse("https://nejda.onrender.com/uploads/$imageName"));

  if (response.statusCode == 200) {
    // Add the fetched image to cache
    ImageCache.addToCache(imageName, response.bodyBytes);
    return response.bodyBytes;
  } else {
    throw Exception('Failed to load image: $imageName');
  }
}
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Column(
        children: [
          // Window title bar (unchanged)
          Container(
            color: widget.color,
            width: MediaQuery.of(context).size.width,
            height: 35,
            child: WindowTitleBarBox(
              child: Row(
                children: [
                  Expanded(child: MoveWindow()),
                  Row(
                    children: [
                      MinimizeWindowButton(colors: WindowButtonColors(
                        iconNormal: Colors.white,
                        mouseOver: widget.color.withOpacity(0.8),
                        mouseDown: widget.color.withOpacity(0.6),
                      )),
                      MaximizeWindowButton(colors: WindowButtonColors(
                        iconNormal: Colors.white,
                        mouseOver: widget.color.withOpacity(0.8),
                        mouseDown: widget.color.withOpacity(0.6),
                      )),
                      CloseWindowButton(colors: WindowButtonColors(
                        iconNormal: Colors.white,
                        mouseOver: Colors.red,
                        mouseDown: Colors.red.shade800,
                      )),
                    ],
                  ),
                ],
              ),
            ),
          ),
          
          // Main content
          Expanded(
            child: SafeArea(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 50, vertical: 20),
                child: Column(
                  children: [
                    // Search and filter row (unchanged)
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        SizedBox(
                          width: 500,
                          child: TextField(
                            controller: _searchController,
                            decoration: InputDecoration(
                              labelText: "Search...",
                              prefixIcon: Icon(Icons.search),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                            ),
                            keyboardType: TextInputType.text,
                          ),
                        ),
                        Row(
                          children: [
                            SizedBox(width: 20),
                            GestureDetector(
                              onTap: () {
                                Navigator.push(context, MaterialPageRoute(
                                  builder: (_) => MyWidget(color: widget.color, Type: widget.Type)
                                ));
                              },
                              child: Container(
                                padding: EdgeInsets.symmetric(horizontal: 30, vertical: 15),
                                decoration: BoxDecoration(
                                  color: Color(0xffA7A7A7),
                                  borderRadius: BorderRadius.circular(30)
                                ),
                                child: Center(child: Text("البلاغات التي تم قبولها", 
                                  style: TextStyle(color: Colors.white, fontSize: 16))),
                              ),
                            ),
                            SizedBox(width: 20),
                            GestureDetector(
                              onTap: () {
                                Navigator.push(context, MaterialPageRoute(
                                  builder: (_) => Homepage(color: widget.color, Type: widget.Type)
                                ));
                              },
                              child: Container(
                                padding: EdgeInsets.symmetric(horizontal: 30, vertical: 15),
                                decoration: BoxDecoration(
                                  color: widget.color,
                                  borderRadius: BorderRadius.circular(30)
                                ),
                                child: Center(child: Text("البلاغات الاخيرة", 
                                  style: TextStyle(color: Colors.white, fontSize: 16))),
                              ),
                            ),
                            SizedBox(width: 20),
                            PopupMenuButton<String>(
                              color: Colors.white,
                              onSelected: (value) {
                                _toggleFilter(value);
                              },
                              itemBuilder: (context) {
                                return [
                                  PopupMenuItem(
                                    value: 'raport',
                                    child: StatefulBuilder(
                                      builder: (context, setState) => Row(
                                        mainAxisAlignment: MainAxisAlignment.end,
                                        children: [
                                          Text("ابلاغ", style: TextStyle(color: widget.color)),
                                          Checkbox(
                                            side: BorderSide(color: widget.color),
                                            value: emergencyServices.selectedFilters.contains('raport'),
                                            onChanged: (value) {
                                              if (value != null) {
                                                setState(() {
                                                  _toggleFilter('raport');
                                                });
                                              }
                                            },
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                  PopupMenuItem(
                                    value: 'fastcall',
                                    child: StatefulBuilder(
                                      builder: (context, setState) => Row(
                                        mainAxisAlignment: MainAxisAlignment.end,
                                        children: [
                                          Text("اتصال سريع", style: TextStyle(color: widget.color)),
                                          Checkbox(
                                            side: BorderSide(color: widget.color),
                                            value: emergencyServices.selectedFilters.contains('fastcall'),
                                            onChanged: (value) {
                                              if (value != null) {
                                                setState(() {
                                                  _toggleFilter('fastcall');
                                                });
                                              }
                                            },
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                  PopupMenuItem(
                                    value: 'msg',
                                    child: StatefulBuilder(
                                      builder: (context, setState) => Row(
                                        mainAxisAlignment: MainAxisAlignment.end,
                                        children: [
                                          Text("رسالة نصية قصيرة", style: TextStyle(color: widget.color)),
                                          Checkbox(
                                            side: BorderSide(color: widget.color),
                                            value: emergencyServices.selectedFilters.contains('msg'),
                                            onChanged: (value) {
                                              if (value != null) {
                                                setState(() {
                                                  _toggleFilter('msg');
                                                });
                                              }
                                            },
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ];
                              },
                              child: Container(
                                padding: EdgeInsets.symmetric(horizontal: 10, vertical: 10),
                                decoration: BoxDecoration(
                                  color: widget.color,
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                child: Image.asset("Assets/Images/Vector.png", width: 40),
                              ),
                            )
                          ],
                        )
                      ],
                    ),
                    SizedBox(height: 20),
                    
                    
                    Expanded(
                      child: StreamBuilder<List<Emergencymodel>>(
                        stream: emergencyServices.emergencyStream,
                        builder: (context, snapshot) {
                          
                          if (snapshot.connectionState == ConnectionState.waiting && !snapshot.hasData) {
                            return Center(child: CircularProgressIndicator());
                          }
                          
                         
                          if (snapshot.hasError) {
                            return Center(
                              child: Text(
                                "Error loading data: ${snapshot.error}",
                                style: TextStyle(fontSize: 18, color: Colors.red)
                              )
                            );
                          }
                          
                          // If no data available
                          if (!snapshot.hasData || snapshot.data!.isEmpty) {
                            return Center(
                              child: Text(
                                "No emergency data available", 
                                style: TextStyle(fontSize: 18)
                              )
                            );
                          }
                          
                          // Display emergency data
                          List<Emergencymodel> emergencies = snapshot.data!;
                          return ListView.builder(
                            itemCount: emergencies.length,
                            itemBuilder: (context, index) {
                              final emergency = emergencies[index];
                              
                              return Container(
                                margin: EdgeInsets.symmetric(vertical: 10, horizontal: 15),
                                height: 300,
                                width: MediaQuery.of(context).size.width,
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(12),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.grey.withOpacity(0.3),
                                      spreadRadius: 2,
                                      blurRadius: 8,
                                      offset: Offset(0, 4),
                                    ),
                                  ],
                                ),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.end,
                                  children: [
                                    Padding(
                                      padding: const EdgeInsets.all(8.0),
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.end,
                                        children: [
                                          Row(
                                            children: [
                                              GestureDetector(
                                                onTap: () async {
                                                  bool success = await emergencyServices.confirmEmergency(emergency.id);
                                                  if (success) {
                                                    ScaffoldMessenger.of(context).showSnackBar(
                                                      SnackBar(
                                                        content: Text("تم تأكيد"),
                                                        behavior: SnackBarBehavior.floating,
                                                        margin: EdgeInsets.all(10),
                                                        duration: Duration(seconds: 3),
                                                        action: SnackBarAction(
                                                          label: 'OK',
                                                          textColor: Colors.white,
                                                          onPressed: () {
                                                            ScaffoldMessenger.of(context).hideCurrentSnackBar();
                                                          },
                                                        ),
                                                      ),
                                                    );
                                                  }
                                                },
                                                child: Container(
                                                  padding: EdgeInsets.symmetric(horizontal: 50, vertical: 15),
                                                  margin: EdgeInsets.only(top: 15),
                                                  decoration: BoxDecoration(
                                                    color: widget.color,
                                                    borderRadius: BorderRadius.circular(30),
                                                  ),
                                                  child: Center(
                                                    child: Text(
                                                      "تأكيد",
                                                      style: TextStyle(color: Colors.white, fontSize: 16),
                                                    ),
                                                  ),
                                                ),
                                              ),
                                              SizedBox(width: MediaQuery.of(context).size.width-500),
                                              Text(
                                                emergency.emergencyTypeArabic,
                                                style: TextStyle(
                                                  color: widget.color,
                                                  fontSize: 25,
                                                  fontWeight: FontWeight.bold,
                                                ),
                                              ),
                                            ],
                                          ),
                                          SizedBox(height: 20),
                                          SingleChildScrollView(
                                            scrollDirection: Axis.horizontal,
                                            child: Row(
                                              crossAxisAlignment: CrossAxisAlignment.start,
                                              children: [
                                                Column(
                                                  crossAxisAlignment: CrossAxisAlignment.end,
                                                  children: [
                                                    Row(
                                                      children: [
                                                        (emergency.fastcall != null && 
                                                          (emergency.fastcall!.images.isNotEmpty || emergency.fastcall!.video != ''))
                                                          ? GestureDetector(
                                                              onTap: () {
                                                                Navigator.push(context, MaterialPageRoute(
                                                                  builder: (_) => Displayimage(
                                                                    image: emergency.fastcall!.images, 
                                                                    video: emergency.fastcall!.video, 
                                                                    colors: widget.color,
                                                                  )
                                                                ));
                                                              },
                                                              child: _buildContactButtons(
                                                                text: "Images",
                                                                icon: Icons.image,
                                                                color: widget.color,
                                                              ),
                                                            )
                                                          : Text(""),
                                                           SizedBox(width: 10),
                                                        _buildContactButton(
                                                          text: DateFormat('yyyy-MM-dd  kk:mm').format(emergency.createdAt),
                                                          icon: Icons.timer,
                                                          color: widget.color
                                                          ,context: context
                                                        ),
                                                        SizedBox(width: 10),
                                                        _buildContactButton(
                                                          text: emergency.gps,
                                                          icon: Icons.map_outlined,
                                                          color: widget.color
                                                          ,context: context
                                                        ),
                                                        SizedBox(width: 10),
                                                        _buildContactButton(
                                                          text: emergency.user.phoneNumber,
                                                          icon: Icons.phone_android_outlined,
                                                          color: widget.color,context: context
                                                        ),
                                                        SizedBox(width: 10),
                                                        _buildContactButton(
                                                          text: emergency.nameUser,
                                                          icon: Icons.person_2_outlined,
                                                          color: widget.color
                                                          ,context: context
                                                        ),
                                                      ],
                                                    ),
                                                    SizedBox(height: 15),
                                                    Text(
                                                      "ما نوع الطارئ: ${emergency.emergencyTypeArabic}",
                                                      style: TextStyle(fontSize: 20),
                                                      textAlign: TextAlign.right, 
                                                    ),
                                                    if(emergency.emergencyTypeArabic == 'ابلاغ') 
                                                      GestureDetector(
                                                        onTap: () => Navigator.push(context, MaterialPageRoute(
                                                          builder: (_) => Descriptioninfo(
                                                            description: emergency.report!.description, 
                                                            clors: widget.color,
                                                          )
                                                        )),
                                                        child: Container(
                                                          width: MediaQuery.of(context).size.width/2,
                                                          child: Text(
                                                            "البلاغ : ${emergency.report!.description}", 
                                                            style: TextStyle(fontSize: 20),
                                                            textAlign: TextAlign.right,
                                                            overflow: TextOverflow.ellipsis,
                                                            maxLines: 2,
                                                          ),
                                                        ),
                                                      ),
                                                    if(emergency.emergencyTypeArabic == 'رسالة') 
                                                      Row(
                                                        children: [   
                                                          Text(
                                                            " هل انت مصاب: ${emergency.msg!.injured == true ? 'نعم' : 'لا'}",
                                                            style: TextStyle(fontSize: 20),
                                                            textAlign: TextAlign.right, 
                                                          ),
                                                          SizedBox(width: 20),
                                                          Text(
                                                            "هل انت في مكان الحادث : ${emergency.msg!.inTheSence == true ? 'نعم' : 'لا'}",
                                                            style: TextStyle(fontSize: 20),
                                                            textAlign: TextAlign.right, 
                                                          ),
                                                          SizedBox(width: 20),
                                                          Text(
                                                            "ما نوع الطارئ: ${emergency.msg!.emergencyType}",
                                                            style: TextStyle(fontSize: 20),
                                                            textAlign: TextAlign.right, 
                                                          ),
                                                        ],
                                                      ),
                                                    if (emergency.emergencyTypeArabic == 'اتصال سريع' && 
                                                        emergency.fastcall != null && 
                                                        emergency.fastcall!.vocal != '') 
                                                      AudioPlayerWidget(vocalUrl: emergency.fastcall!.vocal),
                                                  ],
                                                ),
                                                SizedBox(width: 10),
                                                FutureBuilder<Uint8List>(
  key: ValueKey(emergency.user.image), 
  future: fetchImageBytes(emergency.user.image),
  builder: (context, snapshot) {
    if (snapshot.connectionState == ConnectionState.waiting) {
      return CircleAvatar(
        radius: 70,
        child: Icon(Icons.person, size: 50),
      );
    } else if (snapshot.hasError) {
      return CircleAvatar(
        radius: 70,
        child: Icon(Icons.person, size: 50),
      );
    } else if (snapshot.hasData) {
      return CircleAvatar(
        radius: 70,
        backgroundImage: MemoryImage(snapshot.data!),
      );
    } else {
      return CircleAvatar(
        radius: 70,
        child: Icon(Icons.person, size: 50),
      );
    }
  },
)
                                              ],
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    Container(
                                      width: 10,
                                      height: 300,
                                      decoration: BoxDecoration(
                                        color: widget.color,
                                        borderRadius: BorderRadius.only(
                                          topRight: Radius.circular(12),
                                          bottomRight: Radius.circular(12),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              );
                            },
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }}

class ImageCache {
  static final Map<String, Uint8List> _cache = HashMap<String, Uint8List>();
  
  static void addToCache(String key, Uint8List imageBytes) {
    _cache[key] = imageBytes;
  }
  
  static Uint8List? getFromCache(String key) {
    return _cache[key];
  }
  
  static bool hasInCache(String key) {
    return _cache.containsKey(key);
  }
  
  static void clearCache() {
    _cache.clear();
  }
}
Widget _buildContactButton({required String text, required IconData icon ,required Color color,BuildContext? context}) {
  return GestureDetector(
    onTap: () {
       showDialog(
        context: context!,
        builder: (context) => AlertDialog(
          title: Text("التفاصيل"), // or "Details"
          content: Text(text),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text("إغلاق"), // or "Close"
            ),
          ],
        ),
      );
    },
    child: Container(
      padding: EdgeInsets.symmetric(horizontal: 20, vertical: 15),
      margin: EdgeInsets.only(top: 15),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(30),
      ),
      child: Center(
    child: Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        ConstrainedBox(
          constraints: BoxConstraints(maxWidth: 250), // adjust as needed
          child: Text(
            text,
            style: TextStyle(color: Colors.white, fontSize: 14),
            overflow: TextOverflow.ellipsis,
            maxLines: 1,
          ),
        ),
        SizedBox(width: 10),
        Icon(icon, color: Colors.white),
      ],
    ),
    ),
    ),
  );
}
Widget _buildContactButtons({required String text, required IconData icon ,required Color color}) {
  return  Container(
      padding: EdgeInsets.symmetric(horizontal: 20, vertical: 15),
      margin: EdgeInsets.only(top: 15),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(30),
      ),
      child: Center(
    child: Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        ConstrainedBox(
          constraints: BoxConstraints(maxWidth: 250), // adjust as needed
          child: Text(
            text,
            style: TextStyle(color: Colors.white, fontSize: 14),
            overflow: TextOverflow.ellipsis,
            maxLines: 1,
          ),
        ),
        SizedBox(width: 10),
        Icon(icon, color: Colors.white),
      ],
    ),
    ),
    );
  
}

class AudioPlayerWidget extends StatefulWidget {
  final String vocalUrl;

  const AudioPlayerWidget({super.key, required this.vocalUrl});

  @override
  State<AudioPlayerWidget> createState() => _AudioPlayerWidgetState();
}

class _AudioPlayerWidgetState extends State<AudioPlayerWidget> {
  AudioPlayer? _player;
  Duration _position = Duration.zero;
  Duration _duration = Duration.zero;
  bool _isLoading = false; // Start as not loading
  bool _isPlaying = false;
  String? _filePath;
  bool _isSeeking = false;
  // Store the current vocalUrl to detect changes
  late String _currentVocalUrl;

  @override
  void initState() {
    super.initState();
    _currentVocalUrl = widget.vocalUrl;
    _initializeAudioPlayer();
    // No autoplay when first entering the page
  }

  @override
  void didUpdateWidget(AudioPlayerWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    
    // Check if vocalUrl has changed due to a new emergency being streamed
    if (oldWidget.vocalUrl != widget.vocalUrl) {
      _currentVocalUrl = widget.vocalUrl;
      // Reload audio when vocalUrl changes
      _loadAndPlayAudio();
    }
  }

  void _initializeAudioPlayer() {
    _player = AudioPlayer();
    _setupAudioListeners();
  }

  void _setupAudioListeners() {
    _player?.positionStream.listen((position) {
      if (mounted && !_isSeeking) {
        setState(() => _position = position);
      }
    });

    _player?.durationStream.listen((duration) {
      if (mounted && duration != null) {
        setState(() => _duration = duration);
      }
    });

    _player?.playerStateStream.listen((state) {
      if (mounted) {
        setState(() => _isPlaying = state.playing);
      }
    });
  }

 Future<void> _loadAndPlayAudio() async {
  await _player?.stop();
  await _player?.dispose();
  
  _initializeAudioPlayer();

  setState(() => _isLoading = true);
  try {
    final cacheDir = await getTemporaryDirectory();
    final uri = Uri.parse("https://nejda.onrender.com/uploads/${_currentVocalUrl}");
    
    final safeFileName = '${DateTime.now().millisecondsSinceEpoch}_${_currentVocalUrl.replaceAll(RegExp(r'[^a-zA-Z0-9]'), '_')}';
    final file = File('${cacheDir.path}/audio_$safeFileName.mp3');

    final response = await http.get(uri);

    if (response.statusCode == 200) {
      await file.writeAsBytes(response.bodyBytes);
      setState(() => _filePath = file.path);
      
      try {
        await _player?.setFilePath(file.path);
        // Removed autoplay
      } catch (playerError) {
        _showError("Player error: $playerError");
      }
    } else {
      _showError("Failed to load audio (Status code: ${response.statusCode})");
    }
  } catch (e) {
    _showError("Error loading audio: $e");
  } finally {
    setState(() => _isLoading = false);
  }
}
  Future<void> _togglePlayback() async {
    if (_player == null) {
      await _loadAndPlayAudio();
      return;
    }

    if (_isPlaying) {
      await _player?.pause();
    } else {
      if (_filePath == null) {
        await _loadAndPlayAudio();
      } else {
        await _player?.play();
      }
    }
  }

  void _showError(String message) {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
    }
  }

  @override
  void dispose() {
    _player?.dispose();
    super.dispose();
  }

  String _formatDuration(Duration d) {
    final minutes = d.inMinutes.toString().padLeft(2, '0');
    final seconds = (d.inSeconds % 60).toString().padLeft(2, '0');
    return '$minutes:$seconds';
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.max,
      children: [
        IconButton(
          iconSize: 36,
          padding: EdgeInsets.zero,
          constraints: const BoxConstraints(),
          color: Colors.blue,
          onPressed: _isLoading ? null : _togglePlayback,
          icon: _isLoading
              ? const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : Icon(_isPlaying ? Icons.pause_circle : Icons.play_circle),
        ),
        const SizedBox(width: 8),
        Text(
          _formatDuration(_position),
          style: const TextStyle(fontSize: 12),
        ),
        Slider(
            min: 0,
            max: _duration.inMilliseconds > 0 ? _duration.inMilliseconds.toDouble() : 1.0,
            value: _position.inMilliseconds.toDouble().clamp(
              0,
              _duration.inMilliseconds > 0 ? _duration.inMilliseconds.toDouble() : 1.0,
            ),
            onChangeStart: (_) => setState(() => _isSeeking = true),
            onChanged: (value) {
              setState(() => _position = Duration(milliseconds: value.toInt()));
            },
            onChangeEnd: (value) async {
              setState(() => _isSeeking = false);
              await _player!.seek(Duration(milliseconds: value.toInt()));
            },
          ),
    
        Text(
          _formatDuration(_duration),
          style: const TextStyle(fontSize: 12),
        ),
      ],
    );
  }
}