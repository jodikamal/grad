import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:google_mlkit_face_detection/google_mlkit_face_detection.dart';
import 'dart:math' as math;

class TryGlassesPage extends StatefulWidget {
  final String glassesImagePath;

  const TryGlassesPage({super.key, required this.glassesImagePath});

  @override
  _TryGlassesPageState createState() => _TryGlassesPageState();
}

class _TryGlassesPageState extends State<TryGlassesPage> {
  File? _image;
  double _glassesTop = 100;
  double _glassesLeft = 100;
  double _glassesWidth = 150;
  double _glassesHeight = 80;
  double _glassesRotation = 0;
  final GlobalKey _globalKey = GlobalKey();

  // Face detection variables
  late FaceDetector _faceDetector;
  bool _isDetecting = false;
  bool _autoDetectionEnabled = true;
  List<Face> _detectedFaces = [];
  Size? _imageSize;

  @override
  void initState() {
    super.initState();
    _initializeFaceDetector();
  }

  void _initializeFaceDetector() {
    _faceDetector = FaceDetector(
      options: FaceDetectorOptions(
        enableLandmarks: true,
        enableContours: true,
        enableClassification: true,
        enableTracking: true,
      ),
    );
  }

  @override
  void dispose() {
    _faceDetector.close();
    super.dispose();
  }

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _image = File(pickedFile.path);
        _glassesTop = 100;
        _glassesLeft = 100;
        _glassesWidth = 150;
        _glassesHeight = 80;
        _glassesRotation = 0;
        _detectedFaces.clear();
      });

      if (_autoDetectionEnabled) {
        await _detectFaces();
      }
    }
  }

  Future<void> _detectFaces() async {
    if (_image == null) return;

    setState(() {
      _isDetecting = true;
    });

    try {
      final inputImage = InputImage.fromFile(_image!);
      final faces = await _faceDetector.processImage(inputImage);

      // Get image dimensions - you might need to add image package for this
      // For now, we'll use a simple approach
      final bytes = await _image!.readAsBytes();
      final decodedImage = await decodeImageFromList(bytes);
      _imageSize = Size(
        decodedImage.width.toDouble(),
        decodedImage.height.toDouble(),
      );

      setState(() {
        _detectedFaces = faces;
        _isDetecting = false;
      });

      if (faces.isNotEmpty) {
        _positionGlassesOnFace(faces.first);
        _showSnackBar(
          '${faces.length} face(s) detected! Glasses positioned automatically.',
          Colors.green,
        );
      } else {
        _showSnackBar(
          'No faces detected. Try a different image or position glasses manually.',
          Colors.orange,
        );
      }
    } catch (e) {
      setState(() {
        _isDetecting = false;
      });
      _showSnackBar('Error detecting faces: ${e.toString()}', Colors.red);
    }
  }

  void _positionGlassesOnFace(Face face) {
    if (_imageSize == null) return;

    // Calculate scale factors between actual image and displayed image
    const double displayWidth = 300;
    const double displayHeight = 400;
    final double scaleX = displayWidth / _imageSize!.width;
    final double scaleY = displayHeight / _imageSize!.height;

    // Get face landmarks
    final leftEye = face.landmarks[FaceLandmarkType.leftEye];
    final rightEye = face.landmarks[FaceLandmarkType.rightEye];

    if (leftEye != null && rightEye != null) {
      // Calculate glasses position based on eye positions
      final leftEyeScaled = Offset(
        leftEye.position.x * scaleX,
        leftEye.position.y * scaleY,
      );
      final rightEyeScaled = Offset(
        rightEye.position.x * scaleX,
        rightEye.position.y * scaleY,
      );

      // Calculate center point between eyes
      final centerX = (leftEyeScaled.dx + rightEyeScaled.dx) / 2;
      final centerY = (leftEyeScaled.dy + rightEyeScaled.dy) / 2;

      // Calculate distance between eyes to determine glasses size
      final eyeDistance = (rightEyeScaled.dx - leftEyeScaled.dx).abs();

      // Calculate rotation angle based on eye positions
      final angle = math.atan2(
        rightEyeScaled.dy - leftEyeScaled.dy,
        rightEyeScaled.dx - leftEyeScaled.dx,
      );
      ////////////////////////////////////////////////////////////////////////////////////////////////////////
      setState(() {
        _glassesWidth =
            eyeDistance * 7; // Make glasses wider to cover both eyes properly
        _glassesHeight =
            _glassesWidth * 0.3; // Adjust aspect ratio for better fit
        _glassesLeft = centerX - (_glassesWidth / 2);
        _glassesTop =
            centerY - (_glassesHeight / 2); // Center on eyes, not above
        _glassesRotation = angle;
      });
    } else {
      // Fallback: position based on face bounding box
      final faceRect = face.boundingBox;
      final faceRectScaled = Rect.fromLTWH(
        faceRect.left * scaleX,
        faceRect.top * scaleY,
        faceRect.width * scaleX,
        faceRect.height * scaleY,
      );

      setState(() {
        _glassesWidth = faceRectScaled.width * 0.8; // Make glasses wider
        _glassesHeight = _glassesWidth * 0.4; // Better aspect ratio
        _glassesLeft =
            faceRectScaled.left + (faceRectScaled.width - _glassesWidth) / 2;
        _glassesTop =
            faceRectScaled.top +
            faceRectScaled.height * 0.4; // Position closer to eyes
        _glassesRotation = 0;
      });
    }
  }

  void _changeSize(double factor) {
    setState(() {
      _glassesWidth *= factor;
      _glassesHeight *= factor;
    });
  }

  void _moveGlasses(String direction) {
    setState(() {
      switch (direction) {
        case 'up':
          _glassesTop -= 5;
          break;
        case 'down':
          _glassesTop += 5;
          break;
        case 'left':
          _glassesLeft -= 5;
          break;
        case 'right':
          _glassesLeft += 5;
          break;
      }
    });
  }

  void _rotateGlasses(double angle) {
    setState(() {
      _glassesRotation += angle;
    });
  }

  void _resetGlasses() {
    setState(() {
      _glassesTop = 100;
      _glassesLeft = 100;
      _glassesWidth = 150;
      _glassesHeight = 80;
      _glassesRotation = 0;
    });
  }

  void _showSnackBar(String message, Color color) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: color,
        duration: const Duration(seconds: 3),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      appBar: AppBar(
        title: const Text("Try Glasses with Face Detection"),
        backgroundColor: const Color(0xFF5E36B1),
        elevation: 0,
        actions: [
          IconButton(
            icon: Icon(
              _autoDetectionEnabled ? Icons.face : Icons.face_outlined,
            ),
            onPressed: () {
              setState(() {
                _autoDetectionEnabled = !_autoDetectionEnabled;
              });
              _showSnackBar(
                _autoDetectionEnabled
                    ? 'Auto face detection enabled'
                    : 'Manual mode enabled',
                Colors.blue,
              );
            },
          ),
        ],
      ),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            children: [
              // Auto detection toggle
              Container(
                padding: const EdgeInsets.all(15),
                margin: const EdgeInsets.only(bottom: 20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black12,
                      blurRadius: 4,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text(
                      "Manual",
                      style: TextStyle(fontWeight: FontWeight.w500),
                    ),
                    const SizedBox(width: 10),
                    Switch(
                      value: _autoDetectionEnabled,
                      onChanged: (value) {
                        setState(() {
                          _autoDetectionEnabled = value;
                        });
                      },
                      activeColor: const Color(0xFF5E36B1),
                    ),
                    const SizedBox(width: 10),
                    const Text(
                      "Auto Detect",
                      style: TextStyle(fontWeight: FontWeight.w500),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 20),

              // Status indicator
              if (_isDetecting)
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.orange.shade100,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      ),
                      SizedBox(width: 8),
                      Text(
                        "Detecting faces...",
                        style: TextStyle(fontWeight: FontWeight.w500),
                      ),
                    ],
                  ),
                ),

              const SizedBox(height: 20),

              _image == null
                  ? const Text(
                    "📸 Choose a photo of your face",
                    style: TextStyle(
                      fontSize: 20,
                      color: Colors.grey,
                      fontWeight: FontWeight.w500,
                    ),
                  )
                  : Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.grey.shade300, width: 2),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black12,
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: RepaintBoundary(
                      key: _globalKey,
                      child: Stack(
                        children: [
                          ClipRRect(
                            borderRadius: BorderRadius.circular(10),
                            child: Image.file(
                              _image!,
                              width: 300,
                              height: 400,
                              fit: BoxFit.cover,
                            ),
                          ),
                          Positioned(
                            top: _glassesTop,
                            left: _glassesLeft,
                            child: GestureDetector(
                              onPanUpdate: (details) {
                                setState(() {
                                  _glassesTop += details.delta.dy;
                                  _glassesLeft += details.delta.dx;
                                });
                              },
                              child: Transform.rotate(
                                angle: _glassesRotation,
                                child: Image.network(
                                  widget.glassesImagePath,
                                  width: _glassesWidth,
                                  height: _glassesHeight,
                                  fit: BoxFit.contain,
                                ),
                              ),
                            ),
                          ),
                          // Face detection overlay (optional)
                          if (_detectedFaces.isNotEmpty && _imageSize != null)
                            ..._detectedFaces.map((face) {
                              final scaleX = 300 / _imageSize!.width;
                              final scaleY = 400 / _imageSize!.height;
                              return Positioned(
                                left: face.boundingBox.left * scaleX,
                                top: face.boundingBox.top * scaleY,
                                child: Container(
                                  width: face.boundingBox.width * scaleX,
                                  height: face.boundingBox.height * scaleY,
                                  decoration: BoxDecoration(
                                    border: Border.all(
                                      color: Colors.green.withOpacity(0.5),
                                      width: 2,
                                    ),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                ),
                              );
                            }).toList(),
                        ],
                      ),
                    ),
                  ),

              const SizedBox(height: 30),

              // Main controls
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  ElevatedButton.icon(
                    onPressed: _pickImage,
                    icon: const Icon(Icons.photo),
                    label: const Text("Choose Photo"),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF5E36B1),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30),
                      ),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 12,
                      ),
                    ),
                  ),
                  const SizedBox(width: 15),
                  ElevatedButton.icon(
                    onPressed: _autoDetectionEnabled ? _detectFaces : null,
                    icon: const Icon(Icons.face_retouching_natural),
                    label: const Text("Detect"),
                    style: circleButtonStyle,
                  ),
                ],
              ),

              const SizedBox(height: 20),

              // Size controls
              if (_image != null) ...[
                const Text(
                  "Size Controls",
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 10),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    ElevatedButton(
                      onPressed: () => _changeSize(1.1),
                      style: circleButtonStyle,
                      child: const Icon(Icons.zoom_in),
                    ),
                    const SizedBox(width: 10),
                    ElevatedButton(
                      onPressed: () => _changeSize(0.9),
                      style: circleButtonStyle,
                      child: const Icon(Icons.zoom_out),
                    ),
                  ],
                ),

                const SizedBox(height: 20),

                // Position controls
                const Text(
                  "Position Controls",
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 10),
                Column(
                  children: [
                    ElevatedButton(
                      onPressed: () => _moveGlasses('up'),
                      style: circleButtonStyle,
                      child: const Icon(Icons.keyboard_arrow_up),
                    ),
                    const SizedBox(height: 5),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        ElevatedButton(
                          onPressed: () => _moveGlasses('left'),
                          style: circleButtonStyle,
                          child: const Icon(Icons.keyboard_arrow_left),
                        ),
                        const SizedBox(width: 20),
                        ElevatedButton(
                          onPressed: () => _moveGlasses('right'),
                          style: circleButtonStyle,
                          child: const Icon(Icons.keyboard_arrow_right),
                        ),
                      ],
                    ),
                    const SizedBox(height: 5),
                    ElevatedButton(
                      onPressed: () => _moveGlasses('down'),
                      style: circleButtonStyle,
                      child: const Icon(Icons.keyboard_arrow_down),
                    ),
                  ],
                ),

                const SizedBox(height: 20),

                // Rotation controls
                const Text(
                  "Rotation Controls",
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 10),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    ElevatedButton(
                      onPressed: () => _rotateGlasses(-0.1),
                      style: circleButtonStyle,
                      child: const Icon(Icons.rotate_left),
                    ),
                    const SizedBox(width: 10),
                    ElevatedButton(
                      onPressed: () => _rotateGlasses(0.1),
                      style: circleButtonStyle,
                      child: const Icon(Icons.rotate_right),
                    ),
                  ],
                ),

                const SizedBox(height: 20),

                // Reset button
                ElevatedButton.icon(
                  onPressed: _resetGlasses,
                  icon: const Icon(Icons.refresh),
                  label: const Text("Reset Position"),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.orange,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 12,
                    ),
                  ),
                ),
              ],

              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  final ButtonStyle circleButtonStyle = ElevatedButton.styleFrom(
    shape: const CircleBorder(),
    padding: const EdgeInsets.all(12),
    backgroundColor: Colors.white,
    foregroundColor: const Color(0xFF5E36B1),
    elevation: 4,
    shadowColor: Colors.black26,
  );
}

// Don't forget to add the import for math
