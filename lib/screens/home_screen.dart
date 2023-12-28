import 'dart:developer';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:share_bits/screens/call_screen.dart';
import 'package:share_bits/screens/contacts_screen.dart';
import 'package:share_bits/screens/profile_screen.dart';
import 'package:share_bits/widgets/call_actions.dart';
import 'package:top_snackbar_flutter/custom_snack_bar.dart';
import 'package:top_snackbar_flutter/top_snack_bar.dart';
import '../controllers/call_controller.dart';
import '../controllers/socket_controller.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final socketController = Get.find<SocketController>();
  final callController = Get.find<CallController>();

  PageController pageController = PageController();
  int currentPage = 0;
  AnimationController? localAnimationController;

  @override
  void initState() {
    super.initState();
    // getToken();
    socketController.connectSocket(
        FirebaseAuth.instance.currentUser!.phoneNumber!.substring(3),
        callController);

    ever(socketController.socketConnected, (callback) {
      if (!socketController.socketConnected.value) {
        showTopSnackBar(
          Overlay.of(context),
          const CustomSnackBar.error(
            message: "Connecting...",
          ),
          persistent: true,
          onAnimationControllerInit: (controller) =>
              localAnimationController = controller,
        );
      } else {
        if (localAnimationController != null) {
          localAnimationController!.reverse();
        }
      }
    });

    ever(callController.callState, (callback) {
      if (callController.callState.value != CallState.callIdle) {
        pageController.animateToPage(0,
            duration: const Duration(milliseconds: 200), curve: Curves.easeIn);
      }
    });
  }

  Future getToken() async {
    var token = await FirebaseMessaging.instance.getToken();
    if (token != null) log('token from home:$token');
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: currentPage == 0,
      onPopInvoked: (_) {
        pageController.animateToPage(0,
            duration: const Duration(milliseconds: 200), curve: Curves.easeIn);
      },
      child: Scaffold(
          appBar: currentPage != 0
              ? AppBar(
                  centerTitle: false,
                  title: const Text("Share Bits"),
                  elevation: 10,
                  actions: [
                    IconButton(
                        onPressed: () async {
                          await FirebaseAuth.instance.signOut();
                          Get.offAllNamed('/auth');
                        },
                        icon: const Icon(Icons.logout))
                  ],
                )
              : null,
          body: PageView(
            physics: const NeverScrollableScrollPhysics(),
            controller: pageController,
            onPageChanged: (index) {
              setState(() {
                currentPage = index;
              });
            },
            children: const [
              CallScreen(),
              ContactsScreen(),
              ProfileScreen(),
            ],
          ),
          floatingActionButtonLocation:
              FloatingActionButtonLocation.centerFloat,
          floatingActionButton: Obx(() {
            if (callController.callState.value != CallState.callIdle) {
              return const SizedBox.shrink();
            }

            return FloatingActionButton.extended(
              onPressed: () {
                if (currentPage == 0) {
                  pageController.animateToPage(1,
                      duration: const Duration(milliseconds: 200),
                      curve: Curves.easeIn);
                } else {
                  pageController.animateToPage(0,
                      duration: const Duration(milliseconds: 200),
                      curve: Curves.easeIn);
                }
              },
              label: Text(currentPage == 0 ? "Connect" : "Call"),
              icon: Icon(currentPage == 0 ? Icons.people : Icons.arrow_back),
            );
          }),
          bottomSheet: const CallActions()),
    );
  }
}
