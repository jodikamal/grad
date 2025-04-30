import 'package:email_otp/email_otp.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../screens/ResetPasswordPage.dart';

class OtpForm extends StatefulWidget {
  final EmailOTP auth;

  const OtpForm({required this.auth});

  @override
  _OtpFormState createState() => _OtpFormState();
}

class _OtpFormState extends State<OtpForm> {
  final TextEditingController otp1 = TextEditingController();
  final TextEditingController otp2 = TextEditingController();
  final TextEditingController otp3 = TextEditingController();
  final TextEditingController otp4 = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white, //
      appBar: AppBar(
        backgroundColor: Color(0xFF9B51E0), // ـ Glamzy
        title: Text(
          'Verification Code',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.white,
            fontFamily: 'Poppins',
          ),
        ),
        centerTitle: true,
        elevation: 0,
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
                    'assets/images/email.png',
                    width: 250.0,
                    fit: BoxFit.fitWidth,
                    height: 600.0,
                  ),
                ),
                Center(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24.0),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        SizedBox(height: 60.0),
                        Text(
                          'Enter the Code',
                          style: TextStyle(
                            fontSize: 28,
                            fontWeight: FontWeight.bold,
                            fontFamily: 'Poppins',
                            color: Color(0xFF9B51E0),
                          ),
                        ),
                        SizedBox(height: 12),
                        Text(
                          'We’ve sent a verification code to your email.',
                          style: TextStyle(
                            fontSize: 16.0,
                            fontFamily: 'Poppins',
                            color: Colors.black87,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        SizedBox(height: 30.0),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            buildOtpTextField(otp1),
                            buildOtpTextField(otp2),
                            buildOtpTextField(otp3),
                            buildOtpTextField(otp4),
                          ],
                        ),
                        SizedBox(height: 30),
                        ElevatedButton(
                          onPressed: () async {
                            String otp =
                                otp1.text + otp2.text + otp3.text + otp4.text;
                            if (await widget.auth.verifyOTP(otp: otp)) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(content: Text("Verified")),
                              );
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => NewPass(),
                                ),
                              );
                            } else {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(content: Text("Invalid Code")),
                              );
                            }
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Color(0xFF9B51E0),
                            padding: EdgeInsets.symmetric(
                              horizontal: 100.0,
                              vertical: 14.0,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16.0),
                            ),
                            elevation: 4,
                          ),
                          child: Text(
                            'Confirm',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 18.0,
                              fontFamily: 'Poppins',
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
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

  Widget buildOtpTextField(TextEditingController controller) {
    return SizedBox(
      width: 55,
      child: TextField(
        controller: controller,
        keyboardType: TextInputType.number,
        textAlign: TextAlign.center,
        maxLength: 1,
        style: TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.bold,
          fontFamily: 'Poppins',
        ),
        decoration: InputDecoration(
          counterText: "",
          contentPadding: EdgeInsets.all(12),
          filled: true,
          fillColor: Color(0xFFF5F5F5),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: Color(0xFF9B51E0)),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: Color(0xFF9B51E0), width: 2),
          ),
        ),
        onChanged: (value) {
          if (value.length == 1) {
            FocusScope.of(context).nextFocus();
          }
        },
        inputFormatters: [FilteringTextInputFormatter.digitsOnly],
      ),
    );
  }
}
