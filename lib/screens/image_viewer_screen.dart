import 'package:flutter/material.dart';

/// Full-screen enlarged image. Pinch to zoom; the AppBar back button (or the
/// system back gesture) returns to the details screen.
class ImageViewerScreen extends StatelessWidget {
  const ImageViewerScreen({
    super.key,
    required this.imagePath,
    required this.heroTag,
    required this.title,
  });

  final String imagePath;
  final String heroTag;
  final String title;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
        title: Text(title, overflow: TextOverflow.ellipsis),
      ),
      body: Center(
        child: InteractiveViewer(
          minScale: 1,
          maxScale: 4,
          child: Hero(
            tag: heroTag,
            child: Image.asset(
              imagePath,
              key: const Key('enlarged-image'),
              width: double.infinity,
              fit: BoxFit.contain,
            ),
          ),
        ),
      ),
    );
  }
}
