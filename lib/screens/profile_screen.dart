import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  var user = FirebaseAuth.instance.currentUser!;

  Future signOut() async {
    await FirebaseAuth.instance.signOut();
    Get.offAllNamed('/auth');
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        children: [
          Text(user.phoneNumber!),
          ElevatedButton(onPressed: signOut, child: const Text('Logout'))
        ],
      ),
    );
  }
}
