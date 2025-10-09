import 'package:app_nameit/account/profile.dart';
import 'package:app_nameit/misc/custom_snackbar.dart';
import 'package:app_nameit/model/player.dart';
import 'package:app_nameit/service/store_impl.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:firebase_auth/firebase_auth.dart';

class AccountScreen extends StatefulWidget {
  const AccountScreen({super.key});

  @override
  State<AccountScreen> createState() => _AccountScreenState();

}

class _AccountScreenState extends State<AccountScreen> {
  final _auth = FirebaseAuth.instance;
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _storeService = StoreImpl();
  bool _loading = false;

  Future<void> _createAccount() async {
    final email = _emailController.text.trim();
    final password = _passwordController.text.trim();

    if (email.isEmpty || password.isEmpty) {
      CustomSnackbar.show(
        context,
        title: "Error",
        message: "Please fill in all fields",
      );
      return;
    }

    setState(() => _loading = true);

    try {
      // 1️⃣ Create account with Firebase Auth
      final cred = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      // 2️⃣ Build user object using Firebase UID
      final user = cred.user;
      if (user == null) throw Exception("User creation failed");

      final player = Player(
        uid: user.uid,
        emailAddress: user.email ?? email,
      );

      // 3️⃣ Store user details in Firestore
      await _storeService.createUser(player);

      // 4️⃣ Notify success
      CustomSnackbar.show(
        context,
        title: "Success!",
        message: "Account created successfully.",
      );

      Navigator.pop(context); // Return to previous screen

    } on FirebaseAuthException catch (e) {
      debugPrint("ERROR WITH FIREBASEAUTH: $e");
      String message;
      switch (e.code) {
        case 'email-already-in-use':
          message = "This email is already registered.";
          break;
        case 'invalid-email':
          message = "Invalid email format.";
          break;
        case 'weak-password':
          message = "Password must be at least 6 characters.";
          break;
        default:
          message = "An unknown error occurred.";
      }

      CustomSnackbar.show(context, title: "Error!", message: message);
    } catch (e) {
      CustomSnackbar.show(
        context,
        title: "Error!",
        message: "Something went wrong. Please try again.",
      );
    } finally {
      setState(() => _loading = false);
    }
}

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_auth.currentUser != null) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const ProfileScreen()), // or your AccountScreen
        );
      }
    });
  }

 @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFEFF1ED),
      appBar: AppBar(
        title: const Text("NOMINO"),
        backgroundColor: const Color(0xFF717744),
        centerTitle: true,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const SizedBox(height: 40),

                Text(
                  "CREATE ACCOUNT",
                  style: TextStyle(
                    fontFamily: GoogleFonts.comfortaa().fontFamily,
                    fontWeight: FontWeight.bold,
                    fontSize: 22,
                    color: const Color(0xFF373D20),
                  ),
                ),
                const SizedBox(height: 30),

                // Email field
                TextField(
                  controller: _emailController,
                  decoration: const InputDecoration(
                    labelText: "Email",
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.email),
                  ),
                ),
                const SizedBox(height: 20),

                // Password field
                TextField(
                  controller: _passwordController,
                  obscureText: true,
                  decoration: const InputDecoration(
                    labelText: "Password",
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.lock),
                  ),
                ),
                const SizedBox(height: 30),

                // Create account button
                _loading
                    ? const CircularProgressIndicator(color: Color(0xFF717744))
                    : ElevatedButton(
                        onPressed: _createAccount,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF717744),
                          padding: const EdgeInsets.symmetric(
                              horizontal: 40, vertical: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(30),
                          ),
                        ),
                        child: const Text(
                          "CREATE ACCOUNT",
                          style: TextStyle(color: Colors.white),
                        ),
                      ),

                const SizedBox(height: 30),

                const Row(
                  children: [
                    Expanded(child: Divider(thickness: 1)),
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: 8.0),
                      child: Text("OR"),
                    ),
                    Expanded(child: Divider(thickness: 1)),
                  ],
                ),
                const SizedBox(height: 20),

                OutlinedButton.icon(
                  onPressed: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                          content: Text("Google Sign-In coming soon")),
                    );
                  },
                  icon: const Icon(Icons.account_circle_outlined),
                  label: const Text("Sign in with Google"),
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 30, vertical: 14),
                  ),
                ),

                const SizedBox(height: 40),
              ],
            ),
          ),
        ),
      ),
    );
  }

}
