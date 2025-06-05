import 'dart:io';
import 'dart:math' as math;
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:google_mlkit_face_detection/google_mlkit_face_detection.dart';

class TryGlassesPage extends StatefulWidget {
  final String glassesImageUrl;

  const TryGlassesPage({super.key, required this.glassesImageUrl});

  @override
  State<TryGlassesPage> createState() => _TryGlassesPageState();
}

class _TryGlassesPageState extends State<TryGlassesPage> {
  File? _imageFile;
  ui.Image? _rawImage;
  Size? _displayedSize;
  List<Face> _faces = [];

  double _glassesTop = 100;
  double _glassesLeft = 100;
  double _glassesWidth = 150;
  double _glassesHeight = 80;
  double _rotation = 0;
  bool _detecting = false;

  final _faceDetector = FaceDetector(
    options: FaceDetectorOptions(enableLandmarks: true),
  );

  @override
  void dispose() {
    _faceDetector.close();
    super.dispose();
  }

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);
    if (pickedFile == null) return;

    final file = File(pickedFile.path);
    final bytes = await file.readAsBytes();
    final decodedImage = await decodeImageFromList(bytes);

    setState(() {
      _imageFile = file;
      _rawImage = decodedImage;
    });

    await _detectFaces(file);
  }

  Future<void> _detectFaces(File image) async {
    setState(() => _detecting = true);

    final inputImage = InputImage.fromFile(image);
    final faces = await _faceDetector.processImage(inputImage);

    setState(() {
      _faces = faces;
      _detecting = false;
    });

    if (faces.isNotEmpty && _displayedSize != null) {
      _positionGlasses(faces.first);
      _showMessage("✔️ تم اكتشاف الوجه", Colors.green);
    } else {
      _showMessage("❌ لم يتم العثور على وجه", Colors.orange);
    }
  }

  void _positionGlasses(Face face) {
    final imgW = _rawImage!.width.toDouble();
    final imgH = _rawImage!.height.toDouble();

    final renderW = _displayedSize!.width;
    final renderH = _displayedSize!.height;

    final scaleX = renderW / imgW;
    final scaleY = renderH / imgH;

    final leftEye = face.landmarks[FaceLandmarkType.leftEye];
    final rightEye = face.landmarks[FaceLandmarkType.rightEye];

    if (leftEye != null && rightEye != null) {
      final lx = leftEye.position.x * scaleX;
      final ly = leftEye.position.y * scaleY;
      final rx = rightEye.position.x * scaleX;
      final ry = rightEye.position.y * scaleY;

      final centerX = (lx + rx) / 2;
      final centerY = (ly + ry) / 2;
      final distance = (rx - lx).abs();
      final angle = math.atan2(ry - ly, rx - lx);

      const double yOffsetCompensation = 10;

      setState(() {
        _glassesWidth = distance * 6.8; // أدق من 7
        _glassesHeight = _glassesWidth * 0.35;
        _glassesLeft = centerX - (_glassesWidth / 2);
        _glassesTop = centerY - (_glassesHeight / 2) + yOffsetCompensation;
        _rotation = angle;
      });
    }
  }

  void _showMessage(String msg, Color color) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(msg), backgroundColor: color));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('جرب النظارات'),
        backgroundColor: Colors.deepPurple,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            ElevatedButton.icon(
              onPressed: _pickImage,
              icon: const Icon(Icons.photo),
              label: const Text('اختر صورة'),
            ),
            const SizedBox(height: 16),
            Expanded(
              child:
                  _imageFile == null
                      ? const Center(child: Text('لم يتم اختيار صورة'))
                      : LayoutBuilder(
                        builder: (context, constraints) {
                          final maxW = constraints.maxWidth;
                          final maxH = constraints.maxHeight;

                          final imgRatio = _rawImage!.width / _rawImage!.height;
                          final containerRatio = maxW / maxH;

                          double shownW, shownH;
                          if (imgRatio > containerRatio) {
                            shownW = maxW;
                            shownH = maxW / imgRatio;
                          } else {
                            shownH = maxH;
                            shownW = maxH * imgRatio;
                          }

                          _displayedSize = Size(shownW, shownH);

                          return Center(
                            child: Stack(
                              children: [
                                Image.file(
                                  _imageFile!,
                                  width: shownW,
                                  height: shownH,
                                  fit: BoxFit.contain,
                                ),
                                if (_faces.isNotEmpty)
                                  Positioned(
                                    top: _glassesTop,
                                    left: _glassesLeft,
                                    child: Transform.rotate(
                                      angle: _rotation,
                                      child: Image.network(
                                        widget.glassesImageUrl,
                                        width: _glassesWidth,
                                        height: _glassesHeight,
                                        fit: BoxFit.contain,
                                      ),
                                    ),
                                  ),
                                if (_detecting)
                                  const Positioned.fill(
                                    child: Center(
                                      child: CircularProgressIndicator(),
                                    ),
                                  ),
                              ],
                            ),
                          );
                        },
                      ),
            ),
          ],
        ),
      ),
    );
  }
}
