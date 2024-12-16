import 'package:flutter/material.dart';

class FlipCard extends StatefulWidget {
  final String frontText;
  final String backText;
  final VoidCallback onTap;
  final bool isFlipped;

  const FlipCard({
    required this.frontText,
    required this.backText,
    required this.onTap,
    required this.isFlipped,
  });

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
      duration: Duration(milliseconds: 500),
      vsync: this,
    );
    _animation = Tween<double>(begin: 0, end: 1).animate(_controller);
  }

  @override
  void didUpdateWidget(covariant FlipCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isFlipped) {
      _controller.forward();
    } else {
      _controller.reverse();
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
                      color: Colors.blue,
                      alignment: Alignment.center,
                      child: Text(
                        widget.frontText,
                        style: const TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    )
                  : Transform(
                      alignment: Alignment.center,
                      transform: Matrix4.rotationY(3.14159),
                      child: Container(
                        color: Colors.red,
                        alignment: Alignment.center,
                        child: Text(
                          widget.backText, // Zeige Text statt Bild
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ));
        },
      ),
    );
  }
}
