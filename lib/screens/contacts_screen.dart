import 'dart:developer';

import 'package:azlistview/azlistview.dart';
import 'package:flutter/material.dart';
import 'package:flutter_contacts/flutter_contacts.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';

import '../controllers/call_controller.dart';

class Connection extends ISuspensionBean {
  final String name;
  final String phoneNumber;

  Connection({required this.name, required this.phoneNumber});

  @override
  String getSuspensionTag() => name[0].toUpperCase();

  @override
  String toString() => 'Connection(name: $name, phoneNumber: $phoneNumber)';
}

String formatContactPhoneNumber(String phoneNumber) {
  return phoneNumber
      .replaceAll('(', '')
      .replaceAll(')', '')
      .replaceAll('-', '')
      .replaceAll(' ', '')
      .replaceFirst(RegExp(r'^\+91'), '')
      .trim();
}

class ContactsScreen extends StatefulWidget {
  const ContactsScreen({super.key});

  @override
  State<ContactsScreen> createState() => _ContactsScreenState();
}

class _ContactsScreenState extends State<ContactsScreen>
    with AutomaticKeepAliveClientMixin {
  final callController = Get.find<CallController>();

  Future<List<Connection>> getContacts() async {
    List<Connection> connections = [];
    try {
      if (await FlutterContacts.requestPermission()) {
        List<Contact> contacts =
            await FlutterContacts.getContacts(withProperties: true);
        for (var contact in contacts) {
          if (contact.phones.isNotEmpty) {
            for (var phone in contact.phones) {
              connections.add(Connection(
                  name: contact.displayName,
                  phoneNumber: formatContactPhoneNumber(phone.number)));
            }
          }
        }
      }
      return Future.value(connections);
    } catch (e) {
      log(e.toString());
      return Future.value(connections);
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
            List<Connection> connections = snapshot.data as List<Connection>;
            if (connections.isEmpty) {
              return Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: AspectRatio(
                        aspectRatio: 1,
                        child: SvgPicture.asset(
                            'assets/images/asset_no_contacts.svg')),
                  ),
                  const Text(
                    "No Contacts",
                    style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w400,
                        color: Colors.black),
                  ),
                ],
              );
            }
            return AzListView(
              data: connections,
              itemCount: connections.length,
              itemBuilder: (context, index) {
                return ListTile(
                  onTap: () {
                    callController.makeCall(connections[index].phoneNumber);
                  },
                  leading: const CircleAvatar(
                    child: Icon(Icons.person),
                  ),
                  title: Text(connections[index].name),
                  subtitle: Text(
                    connections[index].phoneNumber,
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w300,
                    ),
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
