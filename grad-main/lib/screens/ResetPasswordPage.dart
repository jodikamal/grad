import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:graduation/screens/ipadress.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../screens/sign_in_page.dart';
import '../screens/forgot_password.dart';

//import 'package:flutter/foundation.dart' show kIsWeb;

class NewPass extends StatefulWidget {
  @override
  NewPassword createState() => NewPassword();
}

class NewPassword extends State<NewPass> {
  bool valpass = false;
  TextEditingController passwordController1 = TextEditingController();
  TextEditingController passwordController2 = TextEditingController();
  var currentUser = FirebaseAuth.instance.currentUser;

  bool _obscurePassword = true;

  void togglePasswordVisibility() {
    setState(() {
      _obscurePassword = !_obscurePassword;
    });
  }

  GlobalKey<FormState> formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          Positioned(
            top: -230.0,
            left: 0.0,
            child: Image.asset(
              'assets/images/glamzy_logo.png',
              width: 400.0,
              fit: BoxFit.fitWidth,
              height: 700.0,
            ),
          ),
          Center(
            child: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Form(
                  key: formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SizedBox(height: 20.0),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'New Password',
                            style: TextStyle(
                              color: Colors.purple, // اللون البنفسجي
                              fontWeight: FontWeight.bold,
                              fontSize: 24.0,
                            ),
                          ),
                          SizedBox(height: 7.0),
                          Container(
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.8),
                              borderRadius: BorderRadius.circular(12.0),
                              border: Border.all(
                                color: Colors.purple.withOpacity(0.3),
                                width: 1.0,
                              ),
                            ),
                            child: TextFormField(
                              controller: passwordController1,
                              obscureText: _obscurePassword,
                              decoration: InputDecoration(
                                labelStyle: TextStyle(color: Colors.purple),
                                hintText: 'Enter your New Password',
                                border: InputBorder.none,
                                filled: true,
                                fillColor: Colors.white.withOpacity(0.8),
                                suffixIcon: IconButton(
                                  icon: Icon(
                                    _obscurePassword
                                        ? Icons.visibility_off
                                        : Icons.visibility,
                                    color: Colors.purple,
                                  ),
                                  onPressed: togglePasswordVisibility,
                                ),
                              ),
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Please enter your password';
                                }
                                return null;
                              },
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 20.0),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Confirm Password',
                            style: TextStyle(
                              color: Colors.purple, // اللون البنفسجي
                              fontWeight: FontWeight.bold,
                              fontSize: 24.0,
                            ),
                          ),
                          SizedBox(height: 7.0),
                          Container(
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.8),
                              borderRadius: BorderRadius.circular(12.0),
                              border: Border.all(
                                color: Colors.purple.withOpacity(0.3),
                                width: 1.0,
                              ),
                            ),
                            child: TextFormField(
                              controller: passwordController2,
                              obscureText: _obscurePassword,
                              decoration: InputDecoration(
                                labelStyle: TextStyle(color: Colors.purple),
                                hintText: 'Re-enter your password',
                                border: InputBorder.none,
                                filled: true,
                                fillColor: Colors.white.withOpacity(0.8),
                                suffixIcon: IconButton(
                                  icon: Icon(
                                    _obscurePassword
                                        ? Icons.visibility_off
                                        : Icons.visibility,
                                    color: Colors.purple,
                                  ),
                                  onPressed: togglePasswordVisibility,
                                ),
                              ),
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                      content: Text(
                                        "Please confirm your password",
                                      ),
                                    ),
                                  );
                                }
                                if (value != passwordController1.text) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                      content: Text("Passwords do not match"),
                                    ),
                                  );
                                }
                                return null;
                              },
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 20.0),
                      Center(
                        child: ElevatedButton(
                          onPressed: () async {
                            if (formKey.currentState!.validate()) {
                              if (passwordController1.text ==
                                  passwordController2.text) {
                                String email = ForgetPass.emailUser;

                                await updatePassword(
                                  email,
                                  passwordController1.text,
                                );
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => SignInPage(),
                                  ),
                                );
                              } else {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text("Passwords do not match"),
                                  ),
                                );
                              }
                            } else {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text("Please confirm your password"),
                                ),
                              );
                            }
                          },
                          style: ButtonStyle(
                            backgroundColor: MaterialStateProperty.all<Color>(
                              Colors.purple, // اللون البنفسجي
                            ),
                            padding:
                                MaterialStateProperty.all<EdgeInsetsGeometry>(
                                  EdgeInsets.symmetric(
                                    horizontal: 40.0,
                                    vertical: 13.0,
                                  ),
                                ),
                            shape: MaterialStateProperty.all<
                              RoundedRectangleBorder
                            >(
                              RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12.0),
                                side: BorderSide(
                                  color: Colors.white.withOpacity(0.5),
                                  width: 1.0,
                                ),
                              ),
                            ),
                          ),
                          child: Text(
                            'Update Password',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 18.0,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> updatePassword(String email, String newPassword) async {
    print(
      'Updating password for email: $email with new password: $newPassword',
    );
    try {
      final response = await http.put(
        Uri.parse('http://$ip:3000/resetPassword'),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
        },
        body: jsonEncode(<String, String>{
          'email': email,
          'newPassword': newPassword,
        }),
      );

      print('Response status: ${response.statusCode}');
      print('Response body: ${response.body}');

      if (response.statusCode == 200 || response.statusCode == 201) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Password updated successfully.')),
        );
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const SignInPage()),
        );
      } else {
        print('Failed to update password');
      }
    } catch (e) {
      print('Exception: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to update password. Please try again later.'),
        ),
      );
    }
  }
}
