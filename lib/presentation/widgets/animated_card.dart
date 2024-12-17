import 'dart:math';
import 'package:flutter/material.dart';

class AnimatedCard extends StatefulWidget {
  final bool isFlipped;
  final Widget front;
  final Widget back;
  final VoidCallback onTap;

  const AnimatedCard({
    Key? key,
    required this.isFlipped,
    required this.front,
    required this.back,
    required this.onTap,
  }) : super(key: key);

  @override
  _AnimatedCardState createState() => _AnimatedCardState();
}

class _AnimatedCardState extends State<AnimatedCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );
    if (widget.isFlipped) {
      _controller.forward();
    }
  }

  @override
  void didUpdateWidget(covariant AnimatedCard oldWidget) {
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
        animation: _controller,
        builder: (context, child) {
          final angle = _controller.value * pi;
          final isFrontVisible = angle <= pi / 2;

          return Transform(
            alignment: Alignment.center,
            transform: Matrix4.rotationY(angle),
            child: isFrontVisible ? widget.front : widget.back,
          );
        },
      ),
    );
  }
}
