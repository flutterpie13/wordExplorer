import 'package:flutter/material.dart';
import 'dart:developer';

class FlipCard extends StatefulWidget {
  final String frontContent; // Inhalt der Vorderseite (Wort oder Szene)
  final VoidCallback onTap; // Aktion bei Klick
  final bool isFlipped; // Zeigt an, ob die Karte umgedreht ist

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
    try {
      _controller = AnimationController(
        duration: const Duration(milliseconds: 500),
        vsync: this,
      );
      _animation = Tween<double>(begin: 0, end: 1).animate(_controller);
    } catch (e, stackTrace) {
      log('Fehler beim Initialisieren der Animation: $e',
          stackTrace: stackTrace);
    }
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
            transform: Matrix4.identity()
              ..setEntry(3, 2, 0.001) // Perspektive hinzufügen
              ..rotateY(angle),
            child: isFront
                ? _buildBackSide()
                : Transform(
                    alignment: Alignment.center,
                    transform: Matrix4.rotationY(3.14159),
                    child: _buildFrontSide(),
                  ),
          );
        },
      ),
    );
  }

  Widget _buildBackSide() {
    return Container(
      color: Colors.grey,
      alignment: Alignment.center,
      child: const Text(
        'BACK',
        style: TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
      ),
    );
  }

  Widget _buildFrontSide() {
    return Container(
      color: Colors.blue,
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
    );
  }
}
