import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final _formKey = GlobalKey<FormState>();
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final confirmController = TextEditingController();

  bool hidePassword = true;
  bool hideConfirm = true;
  bool isLoading = false;

  // ================= REGISTER EMAIL =================
  Future<void> register() async {
    if (isLoading) return;
    if (!_formKey.currentState!.validate()) return;

    setState(() => isLoading = true);

    try {
      final email = emailController.text.trim();
      final password = passwordController.text.trim();

      final userCredential = await FirebaseAuth.instance
          .createUserWithEmailAndPassword(email: email, password: password);

      final user = userCredential.user!;

      // Send verification email
      await user.sendEmailVerification();

      // Save user in Firestore
      await FirebaseFirestore.instance.collection('users').doc(user.uid).set({
        'email': email,
        'role': 'user',
        'createdAt': FieldValue.serverTimestamp(),
      });

      // Logout until email is verified
      await FirebaseAuth.instance.signOut();

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            "Account created successfully. Please verify your email before logging in.",
          ),
        ),
      );

      Navigator.pushNamedAndRemoveUntil(context, "/login", (route) => false);
    } on FirebaseAuthException catch (e) {
      String message;

      switch (e.code) {
        case 'email-already-in-use':
          message = 'This email is already in use.';
          break;
        case 'weak-password':
          message = 'Password is too weak.';
          break;
        case 'invalid-email':
          message = 'Invalid email.';
          break;
        case 'network-request-failed':
          message = 'No internet connection.';
          break;
        default:
          message = e.message ?? 'Registration failed.';
      }

      if (!mounted) return;

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(message)));
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("Something went wrong.")));
    } finally {
      if (mounted) {
        setState(() => isLoading = false);
      }
    }
  }

  // ================= GOOGLE SIGN IN =================

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

      // إنشاء المستخدم إذا كانت أول مرة
      if (!snapshot.exists) {
        await docRef.set({
          'email': user.email,
          'name': user.displayName,
          'role': 'user',
          'createdAt': FieldValue.serverTimestamp(),
        });
      }

      // قراءة الدور من Firestore
      final newSnapshot = await docRef.get();
      final role = newSnapshot.data()?['role'];

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
      ).showSnackBar(SnackBar(content: Text('Google error: $e')));
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
      backgroundColor: Colors.white,
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(25),
          child: Form(
            key: _formKey,
            child: Column(
              children: [
                const Text('Create Account', style: TextStyle(fontSize: 28)),
                const SizedBox(height: 25),

                // EMAIL
                TextFormField(
                  controller: emailController,
                  decoration: const InputDecoration(
                    labelText: 'Email',
                    prefixIcon: Icon(Icons.email),
                    border: OutlineInputBorder(),
                  ),
                  validator: (val) {
                    if (val == null || val.isEmpty) return 'Enter email';
                    if (!val.contains('@')) return 'Invalid email';
                    return null;
                  },
                ),
                const SizedBox(height: 15),

                // PASSWORD
                TextFormField(
                  controller: passwordController,
                  obscureText: hidePassword,
                  decoration: InputDecoration(
                    labelText: 'Password',
                    prefixIcon: const Icon(Icons.lock),
                    border: const OutlineInputBorder(),
                    suffixIcon: IconButton(
                      icon: Icon(
                        hidePassword ? Icons.visibility_off : Icons.visibility,
                      ),
                      onPressed: () =>
                          setState(() => hidePassword = !hidePassword),
                    ),
                  ),
                  validator: (val) {
                    if (val == null || val.isEmpty) return 'Enter password';
                    if (val.length < 6) return 'Min 6 chars';
                    return null;
                  },
                ),
                const SizedBox(height: 15),

                // CONFIRM
                TextFormField(
                  controller: confirmController,
                  obscureText: hideConfirm,
                  decoration: InputDecoration(
                    labelText: 'Confirm Password',
                    prefixIcon: const Icon(Icons.lock),
                    border: const OutlineInputBorder(),
                    suffixIcon: IconButton(
                      icon: Icon(
                        hideConfirm ? Icons.visibility_off : Icons.visibility,
                      ),
                      onPressed: () =>
                          setState(() => hideConfirm = !hideConfirm),
                    ),
                  ),
                  validator: (val) {
                    if (val != passwordController.text) {
                      return 'Passwords do not match';
                    }
                    return null;
                  },
                ),

                const SizedBox(height: 25),

                // REGISTER BUTTON
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton(
                    onPressed: isLoading ? null : register,
                    child: isLoading
                        ? const CircularProgressIndicator(color: Colors.white)
                        : const Text('Register'),
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
              ],
            ),
          ),
        ),
      ),
    );
  }
}
