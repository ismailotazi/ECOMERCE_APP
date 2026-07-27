import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:ecomerce_app/auth/register_page.dart';
import 'package:ecomerce_app/auth/forgot_password_page.dart';
import 'package:google_sign_in/google_sign_in.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  bool isLoading = false;
  bool hidePassword = true;

  // ================= EMAIL LOGIN =================
  Future<void> login() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => isLoading = true);

    try {
      final email = emailController.text.trim();
      final password = passwordController.text.trim();

      UserCredential userCredential = await FirebaseAuth.instance
          .signInWithEmailAndPassword(email: email, password: password);

      User? user = userCredential.user;

      await user?.reload();
      user = FirebaseAuth.instance.currentUser;

      // Verify email
      if (user != null && !user.emailVerified) {
        await FirebaseAuth.instance.signOut();

        if (!mounted) return;

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text("Verify your email first"),
            action: SnackBarAction(
              label: "Resend",
              onPressed: () async {
                await user!.sendEmailVerification();
              },
            ),
          ),
        );

        return;
      }

      // Read user from Firestore
      final doc = await FirebaseFirestore.instance
          .collection('users')
          .doc(user!.uid)
          .get();

      if (!doc.exists) {
        await FirebaseAuth.instance.signOut();

        if (!mounted) return;

        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text("User data not found.")));

        return;
      }

      final role = doc.data()?['role'] as String?;

      if (!mounted) return;

      if (role == 'admin') {
        Navigator.pushNamedAndRemoveUntil(
          context,
          "/mainAdmin",
          (route) => false,
        );
      } else {
        Navigator.pushNamedAndRemoveUntil(context, "/main", (route) => false);
      }
    } on FirebaseAuthException catch (e) {
      String message;

      switch (e.code) {
        case 'user-not-found':
          message = 'User not found';
          break;
        case 'wrong-password':
          message = 'Wrong password';
          break;
        case 'invalid-email':
          message = 'Invalid email';
          break;
        default:
          message = e.message ?? 'Login failed';
      }

      if (!mounted) return;

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(message)));
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(e.toString())));
    } finally {
      if (mounted) {
        setState(() => isLoading = false);
      }
    }
  }

  // ================= GOOGLE LOGIN =================
  Future<void> signInWithGoogle() async {
    setState(() => isLoading = true);

    try {
      final GoogleSignIn googleSignIn = GoogleSignIn();

      final GoogleSignInAccount? googleUser = await googleSignIn.signIn();

      if (googleUser == null) {
        setState(() => isLoading = false);
        return;
      }

      final GoogleSignInAuthentication googleAuth =
          await googleUser.authentication;

      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      UserCredential userCredential = await FirebaseAuth.instance
          .signInWithCredential(credential);

      final user = userCredential.user!;

      final docRef = FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid);

      final snapshot = await docRef.get();

      // First login
      if (!snapshot.exists) {
        await docRef.set({
          'email': user.email,
          'name': user.displayName,
          'role': 'user',
          'createdAt': FieldValue.serverTimestamp(),
        });
      }

      // Read role
      final userDoc = await docRef.get();
      final role = userDoc.data()?['role'] as String?;

      if (!mounted) return;

      if (role == 'admin') {
        Navigator.pushNamedAndRemoveUntil(
          context,
          "/mainAdmin",
          (route) => false,
        );
      } else {
        Navigator.pushNamedAndRemoveUntil(context, "/main", (route) => false);
      }
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Google error: $e")));
    } finally {
      if (mounted) {
        setState(() => isLoading = false);
      }
    }
  }

  // ================= UI =================
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [Colors.deepOrange, Colors.orangeAccent],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
          ),
          Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 25),
              child: Card(
                elevation: 8,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(25),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(25),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Text(
                          "Login",
                          style: TextStyle(
                            fontSize: 28,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 25),

                        // EMAIL
                        TextFormField(
                          controller: emailController,
                          decoration: const InputDecoration(
                            labelText: "Email",
                            prefixIcon: Icon(Icons.email),
                            border: OutlineInputBorder(),
                          ),
                        ),
                        const SizedBox(height: 15),

                        // PASSWORD
                        TextFormField(
                          controller: passwordController,
                          obscureText: hidePassword,
                          decoration: InputDecoration(
                            labelText: "Password",
                            prefixIcon: const Icon(Icons.lock),
                            border: const OutlineInputBorder(),
                            suffixIcon: IconButton(
                              icon: Icon(
                                hidePassword
                                    ? Icons.visibility_off
                                    : Icons.visibility,
                              ),
                              onPressed: () =>
                                  setState(() => hidePassword = !hidePassword),
                            ),
                          ),
                        ),

                        const SizedBox(height: 10),

                        Align(
                          alignment: Alignment.centerRight,
                          child: TextButton(
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => const ForgotPasswordPage(),
                                ),
                              );
                            },
                            child: const Text("Forgot Password?"),
                          ),
                        ),

                        const SizedBox(height: 15),

                        // LOGIN BUTTON
                        SizedBox(
                          width: double.infinity,
                          height: 50,
                          child: ElevatedButton(
                            onPressed: isLoading ? null : login,
                            child: isLoading
                                ? const CircularProgressIndicator(
                                    color: Colors.white,
                                  )
                                : const Text("Login"),
                          ),
                        ),

                        const SizedBox(height: 15),
                        const Text("OR"),
                        const SizedBox(height: 15),

                        // GOOGLE BUTTON
                        SizedBox(
                          width: double.infinity,
                          height: 50,
                          child: OutlinedButton.icon(
                            onPressed: isLoading ? null : signInWithGoogle,
                            icon: const Icon(Icons.login),
                            label: const Text("Continue with Google"),
                          ),
                        ),

                        const SizedBox(height: 20),

                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Text("Don't have an account? "),
                            GestureDetector(
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) => const RegisterPage(),
                                  ),
                                );
                              },
                              child: const Text(
                                "Register",
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: Colors.deepPurple,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
