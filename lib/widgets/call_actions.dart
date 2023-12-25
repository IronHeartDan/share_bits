import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../controllers/call_controller.dart';

class CallActions extends StatefulWidget {
  const CallActions({super.key});

  @override
  State<CallActions> createState() => _CallActionsState();
}

class _CallActionsState extends State<CallActions> {
  final callController = Get.find<CallController>();

  @override
  void initState() {
    super.initState();
    ever(callController.callState, (callback) => setState(() {}));
  }

  @override
  Widget build(BuildContext context) {
    if (callController.callState.value == CallState.callConnected) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 20.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            FloatingActionButton(
                onPressed: () => callController.toggleVideo(),
                child: Obx(() => Icon(
                      callController.isVideoEnabled.value
                          ? Icons.videocam
                          : Icons.videocam_off,
                    ))),
            FloatingActionButton(
              onPressed: () => callController.endCall(),
              backgroundColor: Colors.redAccent,
              child: const Icon(Icons.call_end),
            ),
            FloatingActionButton(
                onPressed: () => callController.toggleAudio(),
                child: Obx(() => Icon(
                      callController.isAudioEnabled.value
                          ? Icons.mic
                          : Icons.mic_off,
                    ))),
          ],
        ),
      );
    }

    if (callController.callState.value == CallState.callIncoming) {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 50),
        child: Column(
          children: [
            const Text(
              'Incoming Call',
              style: TextStyle(
                fontSize: 24,
              ),
            ),
            Text(
              callController.callee.value!.phone,
              style: const TextStyle(
                fontSize: 32,
              ),
            ),
            const Expanded(child: SizedBox.shrink()),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                FloatingActionButton(
                  onPressed: () => callController.endCall(),
                  backgroundColor: Colors.red,
                  child: const Icon(Icons.call_end),
                ),
                FloatingActionButton(
                  onPressed: () => callController.answerCall(),
                  backgroundColor: Colors.green,
                  child: const Icon(Icons.call),
                ),
              ],
            ),
          ],
        ),
      );
    }

    if (callController.callState.value == CallState.callOutgoing) {
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 50),
        child: Column(
          children: [
            const Text(
              'Outgoing Call',
              style: TextStyle(
                fontSize: 24,
              ),
            ),
            const Text(
              '7016783094',
              style: TextStyle(
                fontSize: 32,
              ),
            ),
            const Expanded(child: SizedBox.shrink()),
            FloatingActionButton(
              onPressed: () => callController.endCall(),
              backgroundColor: Colors.red,
              child: const Icon(Icons.call_end),
            ),
          ],
        ),
      );
    }

    if (callController.callState.value == CallState.callEnded) {
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.all(20),
        child: const Text(
          'Call Ended',
          style: TextStyle(
            fontSize: 24,
          ),
          textAlign: TextAlign.center,
        ),
      );
    }

    return const SizedBox.shrink();
  }
}
