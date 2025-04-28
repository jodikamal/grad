import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class OtpVerificationPage extends StatefulWidget {
  const OtpVerificationPage({super.key});

  @override
  State<OtpVerificationPage> createState() => _OtpVerificationPageState();
}

class _OtpVerificationPageState extends State<OtpVerificationPage> {
  final _otpController1 = TextEditingController();
  final _otpController2 = TextEditingController();
  final _otpController3 = TextEditingController();
  final _otpController4 = TextEditingController();

  final _newPasswordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  bool _isLoading = false;
  String? email;
  String? otp;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final arguments = ModalRoute.of(context)?.settings.arguments as Map?;
    email = arguments?['email'] as String?;
    otp = arguments?['otp'] as String?;
  }

  // التحقق من OTP وإعادة التوجيه إلى صفحة إعادة تعيين كلمة المرور
  Future<void> _verifyOtp() async {
    setState(() {
      _isLoading = true;
    });

    // دمج القيم المدخلة في المربعات الأربعة للكود
    String otp =
        _otpController1.text +
        _otpController2.text +
        _otpController3.text +
        _otpController4.text;

    try {
      // التحقق من صحة OTP باستخدام Firebase
      await FirebaseAuth.instance.verifyPasswordResetCode(otp);

      // إذا تم التحقق بنجاح، التوجه لصفحة إعادة تعيين كلمة المرور
      Navigator.pushReplacementNamed(
        context,
        '/resetPassword',
        arguments: {'email': email, 'otp': otp},
      );
    } on FirebaseAuthException catch (e) {
      setState(() {
        _isLoading = false;
      });
      _showDialog("Error: ${e.message}");
    }
  }

  // إعادة تعيين كلمة المرور بعد التحقق من OTP
  Future<void> _resetPassword() async {
    if (_newPasswordController.text != _confirmPasswordController.text) {
      _showDialog("Passwords do not match");
      return;
    }

    try {
      // إعادة تعيين كلمة المرور باستخدام OTP
      await FirebaseAuth.instance.confirmPasswordReset(
        code: otp!,
        newPassword: _newPasswordController.text,
      );

      // عرض رسالة نجاح
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Password reset successful")),
      );

      // العودة إلى صفحة تسجيل الدخول بعد تغيير كلمة المرور
      Navigator.pushReplacementNamed(context, '/login');
    } on FirebaseAuthException catch (e) {
      _showDialog("Error: ${e.message}");
    }
  }

  void _showDialog(String message) {
    showDialog(
      context: context,
      builder:
          (_) => AlertDialog(
            content: Text(message),
            actions: [
              TextButton(
                child: const Text("OK"),
                onPressed: () => Navigator.pop(context),
              ),
            ],
          ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 243, 233, 245),
      appBar: AppBar(
        title: const Text("OTP Verification"),
        backgroundColor: Colors.purple[700],
        foregroundColor: Colors.white,
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: ListView(
            shrinkWrap: true,
            children: [
              Text(
                'Enter the OTP sent to your email',
                style: GoogleFonts.cairo(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  buildOtpTextField(_otpController1),
                  buildOtpTextField(_otpController2),
                  buildOtpTextField(_otpController3),
                  buildOtpTextField(_otpController4),
                ],
              ),
              const SizedBox(height: 16),
              _isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : ElevatedButton(
                    onPressed: _verifyOtp,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.purple,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 40,
                        vertical: 12,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                    ),
                    child: Text(
                      'Verify OTP',
                      style: GoogleFonts.cairo(
                        fontSize: 18,
                        color: Colors.white,
                      ),
                    ),
                  ),
              const SizedBox(height: 16),
              TextField(
                controller: _newPasswordController,
                obscureText: true,
                decoration: InputDecoration(
                  labelText: 'New Password',
                  border: const OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: _confirmPasswordController,
                obscureText: true,
                decoration: InputDecoration(
                  labelText: 'Confirm Password',
                  border: const OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),
              _isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : ElevatedButton(
                    onPressed: _resetPassword,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.purple,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 40,
                        vertical: 12,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                    ),
                    child: Text(
                      'Reset Password',
                      style: GoogleFonts.cairo(
                        fontSize: 18,
                        color: Colors.white,
                      ),
                    ),
                  ),
            ],
          ),
        ),
      ),
    );
  }

  Widget buildOtpTextField(TextEditingController controller) {
    return SizedBox(
      width: 50,
      child: TextField(
        controller: controller,
        keyboardType: TextInputType.number,
        textAlign: TextAlign.center,
        maxLength: 1,
        decoration: InputDecoration(
          counterText: "",
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
        ),
        onChanged: (value) {
          if (value.length == 1) {
            FocusScope.of(context).nextFocus();
          }
        },
      ),
    );
  }
}
