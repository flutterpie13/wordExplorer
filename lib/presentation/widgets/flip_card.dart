import 'package:flutter/material.dart';

class FlipCard extends StatefulWidget {
  final String frontContent;
  final VoidCallback onTap;
  final bool isFlipped;

  const FlipCard({
    required this.frontContent,
    required this.onTap,
    required this.isFlipped,
    Key? key,
  }) : super(key: key);

  @override
  _FlipCardState createState() => _FlipCardState();
}

class _FlipCardState extends State<FlipCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );
    _animation = Tween<double>(begin: 0, end: 1).animate(_controller);

    if (widget.isFlipped) {
      _controller.forward();
    }
  }

  @override
  void didUpdateWidget(covariant FlipCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    print('FlipCard - isFlipped: ${widget.isFlipped}');
    if (widget.isFlipped != oldWidget.isFlipped) {
      if (widget.isFlipped) {
        _controller.forward();
      } else {
        _controller.reverse();
      }
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: widget.onTap,
      child: AnimatedBuilder(
        animation: _animation,
        builder: (context, child) {
          final angle = _animation.value * 3.14159;
          final isFront = angle <= 3.14159 / 2;

          return Transform(
            alignment: Alignment.center,
            transform: Matrix4.rotationY(angle),
            child: isFront
                ? Container(
                    color: Colors.grey, // Rückseite
                    alignment: Alignment.center,
                    child: const Text(
                      'BACK', // Text der Rückseite
                      style: TextStyle(fontSize: 18, color: Colors.white),
                    ),
                  )
                : Transform(
                    alignment: Alignment.center,
                    transform: Matrix4.rotationY(3.14159),
                    child: Container(
                      color: Colors.blue, // Vorderseite
                      alignment: Alignment.center,
                      child: Text(
                        widget.frontContent,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ),
          );
        },
      ),
    );
  }
}
