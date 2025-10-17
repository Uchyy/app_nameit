import 'package:nomino/account/profile.dart';
import 'package:nomino/misc/custom_snackbar.dart';
import 'package:nomino/model/player.dart';
import 'package:nomino/service/store_impl.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

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
      CustomSnackbar.show(context,
          title: "Error", message: "Please fill in all fields");
      return;
    }

    setState(() => _loading = true);

    try {
      // Firebase already checks if the email exists
      final cred = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      final user = cred.user;
      if (user == null) throw Exception("User creation failed");

      final player = Player(
        uid: user.uid,
        emailAddress: user.email ?? email,
      );

      await _storeService.createUser(player);

      CustomSnackbar.show(
        context,
        title: "Success!",
        message: "Account created successfully.",
      );

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const ProfileScreen()),
      );
    } on FirebaseAuthException catch (e) {
      _handleAuthError(e);
    } finally {
      setState(() => _loading = false);
    }
  }


  Future<void> _signInAccount() async {
    final email = _emailController.text.trim();
    final password = _passwordController.text.trim();

    if (email.isEmpty || password.isEmpty) {
      CustomSnackbar.show(context,
          title: "Error", message: "Please fill in all fields");
      return;
    }

    setState(() => _loading = true);
    try {
      await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      CustomSnackbar.show(
        context,
        title: "Welcome back!",
        message: "Signed in successfully.",
      );

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const ProfileScreen()),
      );
    } on FirebaseAuthException catch (e) {
      _handleAuthError(e);
    } finally {
      setState(() => _loading = false);
    }
  }

  void _handleAuthError(FirebaseAuthException e) {
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
      case 'user-not-found':
        message = "No account found for this email.";
        break;
      case 'wrong-password':
        message = "Incorrect password.";
        break;
      default:
        message = "An unexpected error occurred.";
    }
    CustomSnackbar.show(context, title: "Error!", message: message);
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_auth.currentUser != null) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const ProfileScreen()),
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFEFF1ED),
      appBar: AppBar(
        title: const Text("ACCOUNT",
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        backgroundColor: const Color(0xFF717744),
        centerTitle: true,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const SizedBox(height: 40),
              Text(
                "Sign in or create a new account",
                style: TextStyle(
                  fontFamily: GoogleFonts.comfortaa().fontFamily,
                  fontWeight: FontWeight.bold,
                  fontSize: 15,
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

              //Forgotten password button
              Align(
                alignment: Alignment.centerRight, // 👈 aligns the button to the right
                child: TextButton(
                  onPressed: () async {
                    CustomSnackbar.show(context, title: "SENDING", message: "Sending password reset email");
                    final email = _emailController.text.trim().toLowerCase();
                    if (email.isEmpty) CustomSnackbar.show(context, title: "ERROR", message: "Email cannot be empty");
                    await _auth.sendPasswordResetEmail(email: email);
                    CustomSnackbar.show(context, title: "SENT", message: "Check your email for password reset link");
                  },
                  child: const Text(
                    "Forgotten password?",
                    style: TextStyle(
                      color: Color.fromARGB(255, 155, 172, 89),
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 30),

              // Buttons
              _loading
                  ? const CircularProgressIndicator(color: Color(0xFF717744))
                  : Column(
                      children: [
                        ElevatedButton(
                          onPressed: _signInAccount,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF717744),
                            padding: const EdgeInsets.symmetric(
                                horizontal: 40, vertical: 14),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(30),
                            ),
                          ),
                          child: const Text("SIGN IN",
                              style: TextStyle(color: Colors.white)),
                        ),
                        const SizedBox(height: 15),
                        OutlinedButton(
                          onPressed: _createAccount,
                          style: OutlinedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 40, vertical: 14),
                          ),
                          child: const Text("CREATE ACCOUNT"),
                        ),
                      ],
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
                    const SnackBar(content: Text("Google Sign-In coming soon")),
                  );
                },
                icon: const Icon(Icons.account_circle_outlined),
                label: const Text("Sign in with Google"),
                style: OutlinedButton.styleFrom(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 30, vertical: 14),
                ),
              ),
              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }
}
