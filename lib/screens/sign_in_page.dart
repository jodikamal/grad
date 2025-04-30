import 'package:flutter/material.dart';
import 'package:graduation/screens/MainNavigation.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'sign_up_page.dart';
import 'forgot_password.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'ipadress.dart';

class SignInPage extends StatefulWidget {
  const SignInPage({Key? key}) : super(key: key);

  @override
  State<SignInPage> createState() => _SignInPageState();
}

class _SignInPageState extends State<SignInPage> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isLoading = false;

  Future<void> _signIn() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    final email = _emailController.text.trim();
    final password = _passwordController.text.trim();

    try {
      print('🔵 Step 1: Sending request to Node.js server...');

      final serverResponse = await http.post(
        Uri.parse('http://$ip:3000/login'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'email': email, 'password': password}),
      );

      print('🟢 Server response code: ${serverResponse.statusCode}');
      print('🟢 Server response body: ${serverResponse.body}');

      // **أضفينا هنا شرط على الـ statusCode**
      if (serverResponse.statusCode != 200) {
        // فكّري تعرضي رسالة الخطأ اللي رجعها السيرفر
        final errorMsg =
            jsonDecode(serverResponse.body)['message'] ?? 'فشل تسجيل الدخول';
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(errorMsg)));
        return; // مهم ترجعي عشان ما تكمّلي لباقي الكود
      }

      // لو دخلنا هون معناها response.ok
      final responseBody = jsonDecode(serverResponse.body);

      print('✅ Step 4: Navigating to HomeScreen...');
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const HomeScreen()),
      );
    } catch (e) {
      print('❌ Error during login: $e');
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('cant reach server')));
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.deepPurple[50],
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          child: Form(
            key: _formKey,
            child: Column(
              children: [
                // 1.
                Image.asset(
                  'assets/images/glamzy_logo.png', //
                  height: 200, //
                ),
                const SizedBox(height: 30),

                const Text(
                  'Welcome Back to Glamzy!',
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: Colors.deepPurple,
                  ),
                ),
                const SizedBox(height: 30),
                TextFormField(
                  controller: _emailController,
                  decoration: InputDecoration(
                    labelText: 'Email',
                    border: OutlineInputBorder(),
                  ),
                  keyboardType: TextInputType.emailAddress,
                  validator:
                      (value) =>
                          value != null && value.contains('@')
                              ? null
                              : 'should use @',
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _passwordController,
                  decoration: InputDecoration(
                    labelText: 'Password',
                    border: OutlineInputBorder(),
                  ),
                  obscureText: true,
                  validator:
                      (value) =>
                          value != null && value.length >= 6
                              ? null
                              : 'too short password',
                ),
                const SizedBox(height: 24),

                // 2. Forget Password
                TextButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => ForgetPassword()),
                    );
                  },
                  child: Text(
                    'Forgot Password?',
                    style: TextStyle(color: Colors.deepPurple),
                  ),
                ),

                // 3. زر Login
                _isLoading
                    ? const CircularProgressIndicator()
                    : ElevatedButton(
                      onPressed: _signIn,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.deepPurple,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 50,
                          vertical: 15,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30),
                        ),
                      ),
                      child: const Text(
                        'Log In',
                        style: TextStyle(color: Colors.white, fontSize: 16),
                      ),
                    ),

                const SizedBox(height: 20),

                // 4. Don't have an account? Sign UP
                TextButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => SignUpPage()),
                    );
                  },
                  child: Text(
                    "Don't have an account? Sign Up",
                    style: TextStyle(color: Colors.deepPurple),
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
