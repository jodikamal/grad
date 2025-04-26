import 'package:flutter/material.dart';
import 'package:graduation/models/product.dart';

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

  void _adjustScale(double value) {
    setState(() {
      stickerScale += value;
      if (stickerScale < 0.5) stickerScale = 0.5;
      if (stickerScale > 3.0) stickerScale = 3.0;
    });
  }

  void _rotateStickerRight() {
    setState(() {
      stickerRotation += 0.1;
    });
  }

  void _rotateStickerLeft() {
    setState(() {
      stickerRotation -= 0.1;
    });
  }

  void _addToCart() {
    if (selectedSticker == null) return;

    print('Added to cart: ${widget.product.name}');
    print('Sticker: $selectedSticker');
    print('Position: $stickerPosition');
    print('Scale: $stickerScale');
    print('Rotation: $stickerRotation');

    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text("Design added to cart!")));
  }

  void _removeSticker() {
    setState(() {
      selectedSticker = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Customize Design'),
        backgroundColor: Colors.purple,
      ),
      backgroundColor: const Color(0xFFFAF5FF),
      body: Stack(
        children: [
          Center(
            child: Stack(
              children: [
                Image.asset(
                  widget.product.imagePath,
                  width: 300,
                  fit: BoxFit.cover,
                ),
                if (selectedSticker != null)
                  Positioned(
                    left: 0,
                    top: 0,
                    child: IconButton(
                      icon: const Icon(Icons.close, color: Colors.red),
                      onPressed: _removeSticker,
                    ),
                  ),
              ],
            ),
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
                    child: Image.asset(selectedSticker!, width: 100),
                  ),
                ),
              ),
            ),

          // Buttons
          Positioned(
            bottom: 100,
            left: 20,
            child: Row(
              children: [
                IconButton(
                  icon: const Icon(Icons.zoom_in, color: Colors.purple),
                  onPressed: () => _adjustScale(0.1),
                ),
                IconButton(
                  icon: const Icon(Icons.zoom_out, color: Colors.purple),
                  onPressed: () => _adjustScale(-0.1),
                ),
                IconButton(
                  icon: const Icon(Icons.rotate_left, color: Colors.purple),
                  onPressed: _rotateStickerLeft,
                ),
                IconButton(
                  icon: const Icon(Icons.rotate_right, color: Colors.purple),
                  onPressed: _rotateStickerRight,
                ),
              ],
            ),
          ),
        ],
      ),
      bottomNavigationBar: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            height: 140,
            padding: const EdgeInsets.symmetric(horizontal: 8.0),
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
                    margin: const EdgeInsets.symmetric(horizontal: 8.0),
                    padding: const EdgeInsets.all(6.0),
                    decoration: BoxDecoration(
                      border: Border.all(
                        color:
                            selectedSticker == sticker
                                ? Colors.purple
                                : Colors.grey,
                        width: 2,
                      ),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Image.asset(sticker, width: 70),
                  ),
                );
              },
            ),
          ),
          Container(
            width: double.infinity,
            color: Colors.purple,
            child: TextButton.icon(
              onPressed: _addToCart,
              icon: const Icon(Icons.add_shopping_cart, color: Colors.white),
              label: const Text(
                "Add to Cart",
                style: TextStyle(color: Colors.white),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
