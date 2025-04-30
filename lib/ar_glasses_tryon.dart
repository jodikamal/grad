import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter/rendering.dart';

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
  final GlobalKey _globalKey = GlobalKey();

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
      });
    }
  }

  void _changeSize(double factor) {
    setState(() {
      _glassesWidth *= factor;
      _glassesHeight *= factor;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Try Glasses")),
      body: Center(
        child: SingleChildScrollView(
          child: Column(
            children: [
              const SizedBox(height: 20),
              _image == null
                  ? const Text(
                    "Choose a photo of your face",
                    style: TextStyle(fontSize: 18),
                  )
                  : RepaintBoundary(
                    key: _globalKey,
                    child: Stack(
                      children: [
                        Image.file(
                          _image!,
                          width: 300,
                          height: 400,
                          fit: BoxFit.cover,
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
                            child: Image.asset(
                              widget.glassesImagePath,
                              width: _glassesWidth,
                              height: _glassesHeight,
                              fit: BoxFit.contain,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  ElevatedButton(
                    onPressed: _pickImage,
                    child: const Text("Choose a Photo"),
                  ),
                  const SizedBox(width: 10),
                  ElevatedButton(
                    onPressed: () => _changeSize(1.1),
                    child: const Icon(Icons.zoom_in),
                  ),
                  const SizedBox(width: 10),
                  ElevatedButton(
                    onPressed: () => _changeSize(0.9),
                    child: const Icon(Icons.zoom_out),
                  ),
                ],
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }
}
