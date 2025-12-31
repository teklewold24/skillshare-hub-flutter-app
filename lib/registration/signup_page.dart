import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:skillshare_hub/registration/Login_page.dart';
import 'package:skillshare_hub/structure/pagecontroller.dart';

class SignUpPage extends StatefulWidget {
  const SignUpPage({super.key});

  @override
  State<SignUpPage> createState() => _SignUpPageState();
}

class _SignUpPageState extends State<SignUpPage> {
  
  final _formKey = GlobalKey<FormState>();

  var _email = '';
  var _password = '';
  var _firstname = '';
  var _lastname = '';

  Future<void> _submitForm(
    String email,
    String password,
    String firstname,
    String lastname,
  ) async {
    final auth = FirebaseAuth.instance;

    try {
   
      UserCredential authResult = await auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      await FirebaseFirestore.instance
          .collection('users')
          .doc(authResult.user!.uid)
          .set({
        'firstname': firstname,
        'lastname': lastname,
        'email': email,
        'createdAt': Timestamp.now(),
        'profileCompleted': false,
      });

    
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (_) => Pagecontroller()),
      );
    } on FirebaseAuthException catch (e) {
      String message = "";

      if (e.code == "email-already-in-use") {
        message = "This email is already registered.";
      } else if (e.code == "weak-password") {
        message = "Your password is too weak.";
      } else if (e.code == "invalid-email") {
        message = "Please enter a valid email.";
      } else {
        message = "Something went wrong.";
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: Colors.red,
          content: Text(message),
        ),
      );
    }
  }

  void _startAuthentication() {
    
    final isvalid = _formKey.currentState!.validate();
    FocusScope.of(context).unfocus();

    if (isvalid) {
      _formKey.currentState!.save();

      
      _submitForm(_email, _password, _firstname, _lastname);
    }
  }

  Widget _buildInputField(String hint, {bool isPassword = false}) {
    return TextFormField(
      validator: (value) {
        if (hint == 'Email') {
          if (value == null || !value.contains('@') || value.isEmpty) {
            return 'Please enter a valid email address';
          }
          return null;
        } else if (hint == 'Password') {
          if (value == null || value.length < 8) {
            return 'Password must be at least 8 characters long';
          }
          return null;
        } else {
          if (value == null || value.isEmpty) {
            return 'Please enter your ${hint.toLowerCase()}';
          }
          return null;
        }
      },
      onSaved: (value) {
       
        if (hint == 'Email') {
          _email = value!;
        } else if (hint == 'Password') {
          _password = value!;
        } else if (hint == 'First Name') {
          _firstname = value!;
        } else {
          _lastname = value!;
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
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
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
                const SizedBox(height: 50),
                const Text(
                  'create account',
                  style: TextStyle(
                    fontSize: 25,
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 35),
                _buildInputField("First Name"),
                const SizedBox(height: 10),
                _buildInputField("Last Name"),
                const SizedBox(height: 10),
                _buildInputField("Email"),
                const SizedBox(height: 10),
                _buildInputField("Password", isPassword: true),
                const SizedBox(height: 28),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _startAuthentication,
                    
                    style: ElevatedButton.styleFrom(
                      backgroundColor:
                          const Color.fromARGB(255, 60, 64, 93),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      padding:
                          const EdgeInsets.symmetric(vertical: 20),
                    ),
                    child: const Text(
                      'Create Account',
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text(
                      'Already have an account?',
                      style: TextStyle(color: Colors.white),
                    ),
                    TextButton(
                      onPressed: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (context) => LoginPage(),
                          ),
                        );
                      },
                      child: const Text(
                        'Login',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Color.fromARGB(255, 94, 107, 120),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
