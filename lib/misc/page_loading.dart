import 'package:flutter/material.dart';

/*
 Exampel usage :
 Navigator.push(
  context,
  MaterialPageRoute(builder: (_) => PageLoading(
    second: 'Validating answers...', 
    third: 'Calculating score', 
    first: 'Checking dictionary......', 
    nextPage: ResultsScreen(),  
  )),
);
*/

class PageLoading extends StatefulWidget {
  final String first;
  final String second;
  final String third;
  final Widget nextPage; // 👈 page to navigate to after validation

  const PageLoading({
    super.key,
    required this.first,
    required this.second,
    required this.third,
    required this.nextPage, // 👈 required param
  });

  @override
  State<PageLoading> createState() => _ValidationScreenState();
}

class _ValidationScreenState extends State<PageLoading> {
  double _progress = 0.0;
  late String _statusText = widget.first;

  @override
  void initState() {
    super.initState();
    _runValidation();
  }

  Future<void> _runValidation() async {
    // Step 1
    setState(() {
      _progress = 0.3;
      _statusText = widget.second;
    });
    await Future.delayed(const Duration(seconds: 1));

    // Step 2
    setState(() {
      _progress = 0.6;
      _statusText = widget.third;
    });
    await Future.delayed(const Duration(seconds: 1));

    // Step 3
    setState(() {
      _progress = 1.0;
      _statusText = "finalizing........";
    });

    await Future.delayed(const Duration(milliseconds: 800));

    // Navigate to provided next page
    if (!mounted) return;
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => widget.nextPage),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              _statusText,
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),
            SizedBox(
              width: 250,
              child: LinearProgressIndicator(value: _progress),
            ),
          ],
        ),
      ),
    );
  }
}
