import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:flutter_contacts/flutter_contacts.dart';
import 'package:get/get.dart';

import '../controllers/call_controller.dart';

class ContactsScreen extends StatefulWidget {
  const ContactsScreen({super.key});

  @override
  State<ContactsScreen> createState() => _ContactsScreenState();
}

class _ContactsScreenState extends State<ContactsScreen>
    with AutomaticKeepAliveClientMixin {
  final callController = Get.find<CallController>();

  Future<List<Contact>> getContacts() async {
    try {
      if (await FlutterContacts.requestPermission()) {
        return Future.value(
            await FlutterContacts.getContacts(withProperties: true));
      }
      return [];
    } catch (e) {
      log(e.toString());
      return Future.value([]);
    }
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return FutureBuilder(
        future: getContacts(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else {
            List<Contact> contacts = snapshot.data as List<Contact>;
            if (contacts.isEmpty) {
              return Center(
                child: GestureDetector(
                    onTap: () {
                      callController.testCall('9998082351');
                    },
                    child: const Text("No Contacts")),
              );
            }
            return ListView.builder(
              itemCount: contacts.length,
              itemBuilder: (context, index) {
                var contact = contacts[index];
                return ListTile(
                  onTap: () {
                    callController.testCall('7016783094');
                  },
                  title: Text(
                    contact.displayName,
                    style: const TextStyle(color: Colors.black),
                  ),
                  subtitle: Text(
                    contact.phones.firstOrNull == null
                        ? '***'
                        : contact.phones.first.number,
                    style: const TextStyle(color: Colors.black),
                  ),
                );
              },
            );
          }
        });
  }

  @override
  bool get wantKeepAlive => true;
}
