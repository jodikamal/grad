import 'dart:typed_data';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:graduation/screens/ipadress.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:graduation/models/product.dart';
import 'package:http_parser/http_parser.dart';
import 'package:shared_preferences/shared_preferences.dart';

class CreateDesignPage extends StatefulWidget {
  final Product product;

  const CreateDesignPage({super.key, required this.product});

  @override
  State<CreateDesignPage> createState() => _CreateDesignPageState();
}

class _CreateDesignPageState extends State<CreateDesignPage> {
  Offset stickerPosition = const Offset(150, 250);
  double stickerScale = 1.0;
  double stickerRotation = 0.0;
  String? selectedSticker;

  final List<String> stickers = [
    'assets/images/st1.png',
    'assets/images/st2.png',
    'assets/images/st3.png',
    'assets/images/st4.png',
    'assets/images/st5.png',
    'assets/images/st6.png',
    'assets/images/st7.png',
  ];

  final GlobalKey _previewContainerKey = GlobalKey();

  void _adjustScale(double value) {
    setState(() {
      stickerScale = (stickerScale + value).clamp(0.5, 3.0);
    });
  }

  void _rotateStickerRight() => setState(() => stickerRotation += 0.1);
  void _rotateStickerLeft() => setState(() => stickerRotation -= 0.1);
  void _removeSticker() => setState(() => selectedSticker = null);

  Future<Uint8List> _capturePng() async {
    RenderRepaintBoundary boundary =
        _previewContainerKey.currentContext!.findRenderObject()
            as RenderRepaintBoundary;
    ui.Image image = await boundary.toImage(pixelRatio: 3.0);
    ByteData? byteData = await image.toByteData(format: ui.ImageByteFormat.png);
    return byteData!.buffer.asUint8List();
  }

  Future<void> _addToCart() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    int? userId = prefs.getInt('userId');
    if (selectedSticker == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text("Please select a sticker."),
          backgroundColor: Colors.redAccent,
        ),
      );
      return;
    }

    try {
      final pngBytes = await _capturePng();

      final uri = Uri.parse("http://$ip:3000/cart/add/$userId");
      final request =
          http.MultipartRequest("POST", uri)
            ..files.add(
              http.MultipartFile.fromBytes(
                'image',
                pngBytes,
                filename: 'design.png',
                contentType: MediaType('image', 'png'),
              ),
            )
            ..fields['product_id'] = widget.product.productId.toString()
            ..fields['quantity'] = '1';

      final response = await request.send();

      if (response.statusCode == 200) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text("Added to cart!"),
            backgroundColor: Colors.green,
          ),
        );
      } else {
        final respStr = await response.stream.bytesToString();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Server Error: $respStr"),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Error: ${e.toString()}"),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF7F3FF),
      appBar: AppBar(
        title: const Text('Create Your Style'),
        centerTitle: true,
        backgroundColor: Colors.purple,
      ),
      body: Column(
        children: [
          const SizedBox(height: 12),
          Expanded(
            child: Center(
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  border: Border.all(color: Colors.purple.shade100),
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: const [
                    BoxShadow(blurRadius: 6, color: Colors.black12),
                  ],
                ),
                padding: const EdgeInsets.all(12),
                child: RepaintBoundary(
                  key: _previewContainerKey,
                  child: Stack(
                    children: [
                      Image.network(
                        widget.product.imagePath,
                        width: 300,
                        fit: BoxFit.cover,
                      ),
                      if (selectedSticker != null)
                        Positioned(
                          left: stickerPosition.dx,
                          top: stickerPosition.dy,
                          child: GestureDetector(
                            onPanUpdate: (details) {
                              setState(() {
                                stickerPosition += details.delta;
                              });
                            },
                            child: Transform.rotate(
                              angle: stickerRotation,
                              child: Transform.scale(
                                scale: stickerScale,
                                child: Image.asset(
                                  selectedSticker!,
                                  width: 100,
                                ),
                              ),
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              ),
            ),
          ),

          if (selectedSticker != null)
            Padding(
              padding: const EdgeInsets.only(top: 8.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _buildIconButton(Icons.zoom_in, () => _adjustScale(0.1)),
                  _buildIconButton(Icons.zoom_out, () => _adjustScale(-0.1)),
                  _buildIconButton(Icons.rotate_left, _rotateStickerLeft),
                  _buildIconButton(Icons.rotate_right, _rotateStickerRight),
                  _buildIconButton(
                    Icons.delete,
                    _removeSticker,
                    color: Colors.red,
                  ),
                ],
              ),
            ),

          const Padding(
            padding: EdgeInsets.symmetric(vertical: 8.0),
            child: Text(
              "Add a sticker for \$15 extra",
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: Colors.redAccent,
              ),
            ),
          ),

          SizedBox(
            height: 100,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: stickers.length,
              itemBuilder: (context, index) {
                final sticker = stickers[index];
                return GestureDetector(
                  onTap: () {
                    setState(() {
                      selectedSticker = sticker;
                      stickerPosition = const Offset(150, 250);
                      stickerScale = 1.0;
                      stickerRotation = 0.0;
                    });
                  },
                  child: Container(
                    margin: const EdgeInsets.symmetric(horizontal: 6),
                    padding: const EdgeInsets.all(5),
                    decoration: BoxDecoration(
                      border: Border.all(
                        color:
                            selectedSticker == sticker
                                ? Colors.purple
                                : Colors.transparent,
                        width: 2,
                      ),
                      borderRadius: BorderRadius.circular(10),
                      color: Colors.white,
                    ),
                    child: Image.asset(sticker, width: 70),
                  ),
                );
              },
            ),
          ),

          Container(
            width: double.infinity,
            margin: const EdgeInsets.all(10),
            child: ElevatedButton.icon(
              onPressed: _addToCart,
              icon: const Icon(Icons.add_shopping_cart),
              label: const Text("Add to Cart"),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.purple,
                padding: const EdgeInsets.symmetric(vertical: 14),
                textStyle: const TextStyle(fontSize: 16),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildIconButton(
    IconData icon,
    VoidCallback onPressed, {
    Color color = Colors.purple,
  }) {
    return IconButton(
      icon: Icon(icon),
      color: color,
      onPressed: onPressed,
      splashRadius: 24,
    );
  }
}
