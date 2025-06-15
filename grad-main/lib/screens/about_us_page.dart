import 'package:flutter/material.dart';

class AboutUsPage extends StatelessWidget {
  const AboutUsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('About Us'),
        backgroundColor: Colors.purple[100],
      ),
      body: const Padding(
        padding: EdgeInsets.all(16.0),
        child: Text(
          'Glamzy is your go-to fashion store for the latest in clothes, accessories, and sunglasses.\n\n'
          'We provide a seamless shopping experience with a modern and elegant design.\n\n'
          'Thank you for choosing Glamzy!',
          style: TextStyle(fontSize: 16),
        ),
      ),
    );
  }
}
