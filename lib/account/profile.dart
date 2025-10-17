import 'package:nomino/main.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, _) async {
        if (didPop) return;
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const nomino()),
        );
      }, 
      child: Scaffold(
      backgroundColor: const Color(0xFFEFF1ED),
      appBar: AppBar(
        backgroundColor: const Color(0xFF717744),
        centerTitle: true,
        title: const Text("Profile"),
        actions: [
          IconButton(
            color: Colors.white,
            onPressed: () { },
            icon: const Icon(Icons.settings), 
          ),
        ],
      ),
      body: user == null
        ? const Center(
            child: Text(
              "Not signed in",
              style: TextStyle(fontSize: 16),
            ),
          )
        : Center(
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                CircleAvatar(
                  radius: 40,
                  backgroundColor: const Color(0xFF717744),
                  child: Text(
                    user.email![0].toUpperCase(),
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 30,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),

                const SizedBox(height: 15),
                Text(
                  user.email ?? '',
                  style: TextStyle(
                    fontFamily: GoogleFonts.lato().fontFamily,
                    fontSize: 18,
                  ),
                ),
                const SizedBox(height: 8),
                SelectableText(
                  "id: ${user.uid}",
                  style: const TextStyle(fontSize: 14, color: Colors.grey),
                ),

                const SizedBox(height: 50),


                //Sign out BUTTOM
                ElevatedButton.icon(
                  onPressed: () async {
                    await FirebaseAuth.instance.signOut();
                    Navigator.pop(context);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF717744),
                    padding: const EdgeInsets.symmetric(
                        horizontal: 30, vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(25),
                    ),
                  ),
                  icon: const Icon(Icons.logout, color: Colors.white),
                  label: const Text(
                    "Sign Out",
                    style: TextStyle(color: Colors.white),
                  ),
                ),
              ],
            ),
          ),
        )      
      )
    );  
  }
}
