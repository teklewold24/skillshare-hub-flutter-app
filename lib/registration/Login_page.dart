import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import 'package:skillshare_hub/registration/signup_page.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _formKey = GlobalKey<FormState>();
  var _email = '';
  var _password = '';
  Future<void> _submitForm(String email, String password) async {
    final auth = FirebaseAuth.instance;

    try {
      await auth.signInWithEmailAndPassword(email: email, password: password);

      if (!mounted) return;

      Navigator.pushReplacementNamed(context, '/navigation');
    } on FirebaseAuthException catch (e) {
      String message = "Login failed";

      switch (e.code) {
        case "user-not-found":
          message = "No account found with this email.";
          break;

        case "wrong-password":
          message = "Incorrect password.";
          break;

        case "invalid-email":
          message = "The email format is invalid.";
          break;

        case "user-disabled":
          message = "This account has been disabled.";
          break;

        default:
          message = e.message ?? "Unknown error";
      }

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(message), backgroundColor: Colors.red),
      );
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Something went wrong. Try again."),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  void _startAuthentication() {
    final isvalid = _formKey.currentState!.validate();
    FocusScope.of(context).unfocus();
    if (isvalid) {
      _formKey.currentState!.save();

      _submitForm(_email, _password);
    }
  }

  Widget _buildInputField(String hint, {bool isPassword = false}) {
    return TextFormField(
      validator: (value) {
        if (hint == 'Email') {
          if (value == null || value.isEmpty || !value.contains('@')) {
            return 'Please enter a valid email address';
          }
          return null;
        } else {
          if (value == null || value.isEmpty || value.length < 8) {
            return 'Password must be at least 8 characters long';
          }
          return null;
        }
      },
      onSaved: (value) {
        if (hint == 'Email') {
          _email = value!;
        } else {
          _password = value!;
        }
      },
      obscureText: isPassword,
      style: const TextStyle(color: Colors.white),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: const TextStyle(color: Colors.white54),
        filled: true,
        fillColor: const Color.fromARGB(255, 60, 64, 93),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide.none,
        ),
        contentPadding: EdgeInsets.symmetric(horizontal: 20, vertical: 18),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 42, 46, 76),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(25.0),
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const SizedBox(height: 80),

                const Text(
                  'Welcome Back',
                  style: TextStyle(
                    fontSize: 25,
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  'Login to continue',
                  style: TextStyle(color: Colors.white70, fontSize: 16),
                ),

                const SizedBox(height: 30),
                _buildInputField("Email"),
                const SizedBox(height: 10),
                _buildInputField("Password", isPassword: true),
                const SizedBox(height: 28),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _startAuthentication,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color.fromARGB(255, 60, 64, 93),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 20),
                    ),
                    child: const Text(
                      'Login',
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text(
                      'Don\'t have an account?',
                      style: TextStyle(color: Colors.white),
                    ),
                    TextButton(
                      onPressed: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (context) => const SignUpPage(),
                          ),
                        );
                      },
                      child: const Text(
                        'Sign Up',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Color.fromARGB(255, 94, 107, 120),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 30),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
