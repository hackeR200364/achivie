import 'package:achivie/styles.dart';
import 'package:flutter/material.dart';

import '../widgets/email_us_screen_widgets.dart';

class ImagePreviewScreen extends StatefulWidget {
  const ImagePreviewScreen({
    Key? key,
    required this.imageURL,
  }) : super(key: key);

  final String imageURL;

  @override
  State<ImagePreviewScreen> createState() => _ImagePreviewScreenState();
}

class _ImagePreviewScreenState extends State<ImagePreviewScreen>
    with SingleTickerProviderStateMixin {
  late TransformationController _transformationController;
  late AnimationController _animationController;
  Animation<Matrix4>? _animation;
  TapDownDetails? tapDownDetails;

  @override
  void initState() {
    _transformationController = TransformationController();
    _animationController = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 300),
    )..addListener(() {
        _transformationController.value = _animation!.value;
      });
    super.initState();
  }

  @override
  void dispose() {
    _transformationController.dispose();
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.mainColor,
      body: SafeArea(
        child: Stack(
          children: [
            Center(
              child: Hero(
                tag: widget.imageURL,
                child: GestureDetector(
                  onDoubleTapDown: ((details) => tapDownDetails = details),
                  onDoubleTap: (() {
                    final position = tapDownDetails!.localPosition;
                    const double scale = 3;
                    final x = -position.dx * (scale - 1);
                    final y = -position.dy * (scale - 1);
                    final zoomed = Matrix4.identity()
                      ..translate(x, y)
                      ..scale(scale);
                    final end = (_transformationController.value.isIdentity())
                        ? zoomed
                        : Matrix4.identity();

                    _animation = Matrix4Tween(
                      begin: _transformationController.value,
                      end: end,
                    ).animate(
                      CurveTween(curve: Curves.easeOut)
                          .animate(_animationController),
                    );

                    _animationController.forward(from: 0);
                  }),
                  child: InteractiveViewer(
                    transformationController: _transformationController,
                    clipBehavior: Clip.none,
                    child: Image.network(widget.imageURL),
                  ),
                ),
              ),
            ),
            Positioned(
              left: 20,
              top: 30,
              child: CustomAppBarLeading(
                onPressed: (() {
                  Navigator.pop(context);
                  // print(isPlaying);
                }),
                icon: Icons.arrow_back_ios_new,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
