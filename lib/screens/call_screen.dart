import 'package:flutter/material.dart';
import 'package:flutter_webrtc/flutter_webrtc.dart';
import 'package:get/get.dart';

import '../controllers/call_controller.dart';

class CallScreen extends StatefulWidget {
  const CallScreen({Key? key}) : super(key: key);

  @override
  State<CallScreen> createState() => _CallScreenState();
}

class _CallScreenState extends State<CallScreen>
    with AutomaticKeepAliveClientMixin {
  final callController = Get.find<CallController>();
  late final RTCVideoRenderer _rtcVideoRenderer;
  bool streamStarted = false;

  @override
  void initState() {
    super.initState();
    _initializeRTCVideoRenderer();
  }

  void _initializeRTCVideoRenderer() async {
    _rtcVideoRenderer = RTCVideoRenderer();
    await callController.startLocalStream();
    await _rtcVideoRenderer.initialize();
    _rtcVideoRenderer.srcObject = callController.localStream.value!;
    setState(() {
      streamStarted = true;
    });
  }

  @override
  void dispose() {
    _rtcVideoRenderer.dispose();
    callController.endLocalStream();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return Stack(
      children: [
        if (streamStarted)
          GestureDetector(
            onTap: () {
              callController.isFullScreen.value =
                  !callController.isFullScreen.value;
            },
            child: SizedBox(
              width: double.infinity,
              height: double.infinity,
              child: RTCVideoView(_rtcVideoRenderer,
                  mirror: true,
                  objectFit: RTCVideoViewObjectFit.RTCVideoViewObjectFitCover,
                  placeholderBuilder: (context) => const Center(
                        child: CircularProgressIndicator(),
                      )),
            ),
          ),
      ],
    );
  }

  @override
  bool get wantKeepAlive => true;
}
