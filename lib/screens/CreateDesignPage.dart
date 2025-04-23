import 'package:flutter/material.dart';
import 'package:graduation/models/product.dart'; // استيراد الكلاس Product

class CreateDesignPage extends StatefulWidget {
  final Product product; // المنتج المختار

  const CreateDesignPage({super.key, required this.product});

  @override
  State<CreateDesignPage> createState() => _CreateDesignPageState();
}

class _CreateDesignPageState extends State<CreateDesignPage> {
  Offset stickerPosition = Offset(150, 250);
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
  ];

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
            child: Image.asset(
              widget.product.imagePath, // عرض صورة المنتج المختار
              width: 300,
              fit: BoxFit.cover,
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
                onScaleUpdate: (details) {
                  setState(() {
                    stickerScale = details.scale;
                    stickerRotation = details.rotation;
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
        ],
      ),
      bottomNavigationBar: SizedBox(
        height: 100,
        child: ListView.builder(
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.all(8.0),
          itemCount: stickers.length,
          itemBuilder: (context, index) {
            final sticker = stickers[index];
            return GestureDetector(
              onTap: () {
                setState(() {
                  selectedSticker = sticker;
                  stickerPosition = Offset(150, 250);
                  stickerScale = 1.0;
                  stickerRotation = 0.0;
                });
              },
              child: Container(
                margin: const EdgeInsets.symmetric(horizontal: 8.0),
                padding: const EdgeInsets.all(4.0),
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
                child: Image.asset(sticker, width: 60),
              ),
            );
          },
        ),
      ),
    );
  }
}
