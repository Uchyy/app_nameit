import 'package:flutter/material.dart';
import 'dart:math' as math;

class PageLoading2 extends StatefulWidget {
  final String first;
  final String second;
  final String third;
  final Widget nextPage;

  const PageLoading2({
    super.key,
    required this.first,
    required this.second,
    required this.third,
    required this.nextPage,
  });

  @override
  State<PageLoading2> createState() => _PageLoading2State();
}

class _PageLoading2State extends State<PageLoading2>
    with SingleTickerProviderStateMixin {
  double _progress = 0.0;
  late String _statusText = widget.first;
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(reverse: true);
    _runValidation();
  }

  Future<void> _runValidation() async {
    setState(() {
      _progress = 0.3;
      _statusText = widget.second;
    });
    await Future.delayed(const Duration(seconds: 1));

    setState(() {
      _progress = 0.6;
      _statusText = widget.third;
    });
    await Future.delayed(const Duration(seconds: 1));

    setState(() {
      _progress = 1.0;
      _statusText = "Finalizing...";
    });

    await Future.delayed(const Duration(milliseconds: 800));

    if (!mounted) return;
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => widget.nextPage),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    const gradientColors = [
      Color(0xFF8A6FB3),
      Color(0xFFE46C5D),
      Color(0xFFE2B96A),
    ];

    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(32.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Animated glowing "N"
              AnimatedBuilder(
                animation: _controller,
                builder: (context, child) {
                  final scale = 1 + 0.05 * math.sin(_controller.value * math.pi);
                  final glow = (1 - _controller.value) * 20;

                  return Transform.scale(
                    scale: scale,
                    child: Container(
                      width: 130,
                      height: 130,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: const LinearGradient(
                          colors: gradientColors,
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.purple.withOpacity(0.3),
                            blurRadius: glow,
                            spreadRadius: 4,
                          ),
                        ],
                      ),
                      alignment: Alignment.center,
                      child: ShaderMask(
                        shaderCallback: (bounds) => const LinearGradient(
                          colors: gradientColors,
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ).createShader(bounds),
                        child: Text(
                          "N",
                          style: const TextStyle(
                            fontSize: 80,
                            fontWeight: FontWeight.w900,
                            color: Colors.white,
                            fontFamily: 'Poppins',
                            letterSpacing: 2,
                          ),
                        ),
                      ),
                    ),
                  );
                },
              ),

              const SizedBox(height: 40),

              // Status text
              Text(
                _statusText,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1,
                  color: Color(0xFF4C3A75),
                ),
                textAlign: TextAlign.center,
              ),

              const SizedBox(height: 30),

              // Subtle linear progress
              SizedBox(
                width: 250,
                child: LinearProgressIndicator(
                  value: _progress,
                  backgroundColor: Colors.grey.shade200,
                  color: const Color(0xFF8A6FB3),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
