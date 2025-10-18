import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:nomino/helpers/game_provider.dart';
import 'package:nomino/model/categories.dart';
import 'package:provider/provider.dart';

class PageLoading extends StatefulWidget {
  final String first;
  final String second;
  final String third;
  final Widget nextPage;

  const PageLoading({
    super.key,
    required this.first,
    required this.second,
    required this.third,
    required this.nextPage,
  });

  @override
  State<PageLoading> createState() => _PageLoadingState();
}

class _PageLoadingState extends State<PageLoading> {
  double _progress = 0.0;
  late String _statusText = widget.first;

  @override
  void initState() {
    super.initState();
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
  Widget build(BuildContext context) {
    final categories = context
        .watch<GameProvider>()
        .game
        .categories
        .take(4)
        .where((c) => c.isSelected)
        
        .toList();

    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Status text
              Text(
                _statusText,
                style: TextStyle(
                  fontSize: 18,            
                  fontFamily: GoogleFonts.dancingScript().fontFamily,
                  color: Theme.of(context).primaryColorDark,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1,
                ),
                textAlign: TextAlign.center,
              ),

              const SizedBox(height: 30),

              // Category progress icons
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(categories.length, (index) {
                  final isActive = (index / categories.length) <= _progress;
                  final icon = getIconForCategory(categories[index].name);

                  return AnimatedContainer(
                    duration: const Duration(milliseconds: 400),
                    margin: const EdgeInsets.symmetric(horizontal: 8),
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: isActive
                          ? const LinearGradient(
                              colors: [Color(0xFF8A6FB3), Color(0xFFE46C5D)],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            )
                          : LinearGradient(
                              colors: [Colors.grey, Colors.grey.shade300],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                      boxShadow: isActive
                          ? [
                              BoxShadow(
                                color: Colors.purple.withOpacity(0.3),
                                blurRadius: 8,
                                offset: const Offset(0, 3),
                              ),
                            ]
                          : [],
                    ),
                    child: Icon(
                      icon,
                      color: isActive ? Colors.white : Colors.black54,
                      size: 30,
                    ),
                  );
                }),
              ),

              const SizedBox(height: 40),

              /*
              // Subtle numeric progress bar for fallback clarity
              SizedBox(
                width: 200,
                child: LinearProgressIndicator(
                  value: _progress,
                  backgroundColor: Colors.grey.shade200,
                  color: const Color(0xFF8A6FB3),
                ),
              ),
              */
            ],
          ),
        ),
      ),
    );
  }
}
