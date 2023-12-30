import 'dart:developer';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';

class AuthScreen extends StatefulWidget {
  const AuthScreen({super.key});

  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  final firebaseAuth = FirebaseAuth.instance;
  bool isLoading = false;
  String phoneInput = "";
  String otpInput = "";

  bool optSent = false;
  late String verificationId;
  int? opt;
  bool isOtpInvalid = false;
  bool isErrorMessageShown = false;
  String errorMessage = "";

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 430,
      padding: const EdgeInsets.all(10),
      color: Colors.white,
      child: Form(
        child: SingleChildScrollView(
          child: Column(
            children: [
              const Text(
                "Let's Get You Started",
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const SizedBox(
                height: 20,
              ),
              AspectRatio(
                  aspectRatio: 2 / 1,
                  child: SvgPicture.asset('assets/images/asset_connection.svg')),
              if (!optSent)
                TextFormField(
                  key: const ValueKey("phone"),
                  keyboardType: TextInputType.phone,
                  maxLength: 10,
                  decoration: InputDecoration(
                      counter: const SizedBox.shrink(),
                      prefix: const Text("+91 "),
                      prefixIcon: phoneInput.length != 10
                          ? const Icon(Icons.phone)
                          : null,
                      suffixIcon: phoneInput.length == 10
                          ? const Icon(
                              Icons.check_circle,
                              color: Colors.green,
                            )
                          : null,
                      label: const Text("Enter Phone"),
                      border: const OutlineInputBorder(
                          borderRadius: BorderRadius.all(Radius.circular(15)))),
                  initialValue: phoneInput,
                  onChanged: (value) {
                    setState(() {
                      phoneInput = value;
                    });
                  },
                )
              else
                TextFormField(
                  key: const ValueKey("otp"),
                  keyboardType: TextInputType.phone,
                  maxLength: 6,
                  decoration: InputDecoration(
                      errorText: isOtpInvalid ? "Invalid OTP" : null,
                      counter: const SizedBox.shrink(),
                      suffixIcon: otpInput.length == 6
                          ? const Icon(
                              Icons.check_circle,
                              color: Colors.green,
                            )
                          : null,
                      label: const Text("Enter OTP"),
                      border: const OutlineInputBorder(
                          borderRadius: BorderRadius.all(Radius.circular(15)))),
                  initialValue: otpInput,
                  onChanged: (value) {
                    setState(() {
                      isOtpInvalid = false;
                      otpInput = value;
                    });
                  },
                ),
              const SizedBox(
                height: 20,
              ),
              if (isLoading)
                const CircularProgressIndicator()
              else if (optSent)
                TextButton(
                    onPressed: otpInput.length != 6 ? null : verifyOtp,
                    child: const Text("LogIn"))
              else
                TextButton(
                    onPressed: phoneInput.length != 10 ? null : logIn,
                    child: const Text("Send OTP")),
              if (isErrorMessageShown)
                Text(
                  errorMessage,
                  style: const TextStyle(color: Colors.red),
                )
            ],
          ),
        ),
      ),
    );
  }

  Future logIn() async {
    FocusScope.of(context).unfocus();
    setState(() {
      isLoading = true;
    });
    var phone = "+91$phoneInput";
    try {
      await firebaseAuth.verifyPhoneNumber(
          phoneNumber: phone,
          verificationCompleted: (phoneAuthCredential) async {
            await firebaseAuth.signInWithCredential(phoneAuthCredential);
          },
          verificationFailed: (e) {
            log(e.toString());
          },
          codeSent: (id, code) async {
            setState(() {
              optSent = true;
              verificationId = id;
              opt = code;
              isLoading = false;
            });
          },
          codeAutoRetrievalTimeout: (codeAutoRetrievalTimeout) {});
    } on FirebaseAuthException catch (e) {
      setState(() {
        isErrorMessageShown = true;
        errorMessage = e.message!;
      });
    }
  }

  Future verifyOtp() async {
    FocusScope.of(context).unfocus();
    setState(() {
      isLoading = true;
    });
    try {
      var user = await firebaseAuth.signInWithCredential(
          PhoneAuthProvider.credential(
              verificationId: verificationId, smsCode: otpInput));
      if (user.user != null) {
        Get.back();
      } else {
        log("Something went wrong while verifying otp");
      }
    } on FirebaseAuthException catch (e) {
      if (e.code == 'invalid-verification-code') {
        setState(() {
          isOtpInvalid = true;
        });
        return;
      }

      setState(() {
        isErrorMessageShown = true;
        errorMessage = e.message!;
      });
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }
}
