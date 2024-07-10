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

  late final RTCVideoRenderer _rtcVideoRendererLocal;
  late final RTCVideoRenderer _rtcVideoRendererRemote;

  @override
  void initState() {
    super.initState();
    // _initializeRTCVideoRenderer();
  }

  void _initializeRTCVideoRenderer() async {
    _rtcVideoRendererLocal = RTCVideoRenderer();
    _rtcVideoRendererRemote = RTCVideoRenderer();
    await _rtcVideoRendererLocal.initialize();
    await _rtcVideoRendererRemote.initialize();
    await callController.startLocalStream();

    setState(() {
      _rtcVideoRendererLocal.srcObject = callController.localStream.value!;
    });

    ever(callController.remoteStream, (callback){
      setState(() {
        _rtcVideoRendererRemote.srcObject = callback!;
      });
    });
  }

  @override
  void dispose() {
    _rtcVideoRendererLocal.dispose();
    callController.endLocalStream();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return Obx(() {
      return Column(
        children: [
          if (callController.localStream.value != null)
            Expanded(
              child: RTCVideoView(_rtcVideoRendererLocal,
                  mirror: true,
                  objectFit: RTCVideoViewObjectFit.RTCVideoViewObjectFitCover,
                  placeholderBuilder: (context) => const Center(
                        child: CircularProgressIndicator(),
                      )),
            ),
          if (callController.remoteStream.value != null)
            Expanded(
              child: RTCVideoView(_rtcVideoRendererRemote,
                  mirror: true,
                  objectFit: RTCVideoViewObjectFit.RTCVideoViewObjectFitCover,
                  placeholderBuilder: (context) => const Center(
                        child: CircularProgressIndicator(),
                      )),
            ),
        ],
      );
    });
  }

  @override
  bool get wantKeepAlive => true;
}
