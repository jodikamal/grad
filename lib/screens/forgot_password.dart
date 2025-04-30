import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../screens/otp_form.dart';
import 'package:email_otp/email_otp.dart';

class ForgetPassword extends StatefulWidget {
  @override
  ForgetPass createState() => ForgetPass();
}

class ForgetPass extends State<ForgetPassword> {
  final EmailOTP auth = EmailOTP();
  static String emailUser = '';
  final TextEditingController emailController = TextEditingController();
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    return kIsWeb ? buildWebForget() : buildMobileForget();
  }

  Widget buildMobileForget() {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: const Color(0xFF7D3C98), // Glamzy purple
        title: Text(
          'Forgot Password',
          style: GoogleFonts.poppins(color: Colors.white),
        ),
      ),
      body: SingleChildScrollView(
        child: ConstrainedBox(
          constraints: BoxConstraints(
            minHeight: MediaQuery.of(context).size.height,
          ),
          child: IntrinsicHeight(
            child: Stack(
              children: [
                Positioned(
                  top: -150.0,
                  left: 70.0,
                  child: Image.asset(
                    'assets/images/key.png',
                    width: 250.0,
                    fit: BoxFit.fitWidth,
                    height: 600.0,
                  ),
                ),
                Center(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20.0),
                    child: Form(
                      key: formKey,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const SizedBox(height: 60.0),
                          Text(
                            'Forgot password?',
                            style: GoogleFonts.poppins(
                              fontSize: 24.0,
                              fontWeight: FontWeight.bold,
                              color: const Color(0xFF7D3C98),
                            ),
                          ),
                          const SizedBox(height: 10.0),
                          Text(
                            'No worries, we\'ll send you reset instructions.',
                            style: GoogleFonts.poppins(
                              fontSize: 16.0,
                              color: Colors.black87,
                            ),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 20.0),
                          TextFormField(
                            controller: emailController,
                            decoration: InputDecoration(
                              hintText: 'Email',
                              hintStyle: GoogleFonts.poppins(),
                              prefixIcon: const Icon(Icons.email),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                            ),
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Please enter your email';
                              } else if (!RegExp(
                                r'^[^@]+@[^@]+\.[^@]+',
                              ).hasMatch(value)) {
                                return 'Please enter a valid email';
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 30),
                          ElevatedButton(
                            onPressed: () async {
                              if (formKey.currentState!.validate()) {
                                auth.setConfig(
                                  appEmail: "system@gmail.com",
                                  appName: "Glamzy, Your Verification Code",
                                  userEmail: emailController.text,
                                  otpLength: 4,
                                  otpType: OTPType.digitsOnly,
                                );

                                try {
                                  if (await auth.sendOTP()) {
                                    emailUser = emailController.text;
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(
                                        content: Text(
                                          "Verification code has been sent",
                                        ),
                                      ),
                                    );
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder:
                                            (context) => OtpForm(auth: auth),
                                      ),
                                    );
                                  } else {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(
                                        content: Text(
                                          "Oops, Verification code send failed",
                                        ),
                                      ),
                                    );
                                  }
                                } catch (e) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                      content: Text(
                                        "Error sending Verification code. Please try again later.",
                                      ),
                                    ),
                                  );
                                }
                              }
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF7D3C98),
                              padding: const EdgeInsets.symmetric(
                                horizontal: 110.0,
                                vertical: 13.0,
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10.0),
                              ),
                            ),
                            child: Text(
                              'Reset Password',
                              style: GoogleFonts.poppins(
                                color: Colors.white,
                                fontSize: 18.0,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget buildWebForget() {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: const Color(0xFF7D3C98),
        title: Text(
          'Forgot Password',
          style: GoogleFonts.poppins(color: Colors.white),
        ),
      ),
      body: SingleChildScrollView(
        child: ConstrainedBox(
          constraints: BoxConstraints(
            minHeight: MediaQuery.of(context).size.height,
          ),
          child: IntrinsicHeight(
            child: Stack(
              children: [
                Align(
                  alignment: Alignment.center,
                  child: Transform.translate(
                    offset: const Offset(0.0, -200.0),
                    child: Image.asset(
                      'assets/images/key.png',
                      width: 400.0,
                      fit: BoxFit.fitWidth,
                      height: 600.0,
                    ),
                  ),
                ),
                Center(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20.0),
                    child: Form(
                      key: formKey,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const SizedBox(height: 60.0),
                          Text(
                            'Forgot password?',
                            style: GoogleFonts.poppins(
                              fontSize: 24.0,
                              fontWeight: FontWeight.bold,
                              color: const Color(0xFF7D3C98),
                            ),
                          ),
                          const SizedBox(height: 10.0),
                          Text(
                            'No worries, we\'ll send you reset instructions.',
                            style: GoogleFonts.poppins(
                              fontSize: 16.0,
                              color: Colors.black87,
                            ),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 20.0),
                          TextFormField(
                            controller: emailController,
                            decoration: InputDecoration(
                              hintText: 'Email',
                              hintStyle: GoogleFonts.poppins(),
                              prefixIcon: const Icon(Icons.email),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                            ),
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Please enter your email';
                              } else if (!RegExp(
                                r'^[^@]+@[^@]+\.[^@]+',
                              ).hasMatch(value)) {
                                return 'Please enter a valid email';
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 30),
                          ElevatedButton(
                            onPressed: () async {
                              if (formKey.currentState!.validate()) {
                                auth.setConfig(
                                  appEmail: "system@gmail.com",
                                  appName: "plantpat, Your Verification Code",
                                  userEmail: emailController.text,
                                  otpLength: 4,
                                  otpType: OTPType.digitsOnly,
                                );

                                try {
                                  if (await auth.sendOTP()) {
                                    emailUser = emailController.text;
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(
                                        content: Text(
                                          "Verification code has been sent",
                                        ),
                                      ),
                                    );
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder:
                                            (context) => OtpForm(auth: auth),
                                      ),
                                    );
                                  } else {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(
                                        content: Text(
                                          "Oops, Verification code send failed",
                                        ),
                                      ),
                                    );
                                  }
                                } catch (e) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                      content: Text(
                                        "Error sending Verification code. Please try again later.",
                                      ),
                                    ),
                                  );
                                }
                              }
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF7D3C98),
                              padding: const EdgeInsets.symmetric(
                                horizontal: 110.0,
                                vertical: 13.0,
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10.0),
                              ),
                            ),
                            child: Text(
                              'Reset Password',
                              style: GoogleFonts.poppins(
                                color: Colors.white,
                                fontSize: 18.0,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
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
