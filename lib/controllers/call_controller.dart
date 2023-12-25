import 'package:get/get.dart';
import 'package:share_bits/controllers/socket_controller.dart';
import 'package:share_bits/services/web_rtc_service.dart';
import 'package:flutter_webrtc/flutter_webrtc.dart';

import '../services/socket_service.dart';

class CallState {
  static const String callIdle = 'IDLE';
  static const String callIncoming = 'INCOMING';
  static const String callOutgoing = 'OUTGOING';
  static const String callConnected = 'CONNECTED';
  static const String callEnded = 'ENDED';
}

class Callee {
  final String name;
  final String phone;

  Callee({required this.name, required this.phone});
}

class CallController extends GetxController {
  final WebRtcService webRtcService = Get.find<WebRtcService>();

  RxList<MediaDeviceInfo> videoDevices = RxList<MediaDeviceInfo>();
  Rx<MediaStream?> localStream = Rx<MediaStream?>(null);

  RxString callState = CallState.callIdle.obs;
  RxBool isFullScreen = false.obs;
  RxString currentFacingMode = 'user'.obs;
  RxBool isVideoEnabled = true.obs;
  RxBool isAudioEnabled = true.obs;
  Rx<Callee?> callee = Rx<Callee?>(null);

  @override
  void onInit() {
    super.onInit();
    getMediaDevices();
  }

  void testCall(to) {
    callState.value = CallState.callOutgoing;
    var socketService = Get.find<SocketController>();
    socketService.makeCall(to);
  }

  void answerCall() {
    callState.value = CallState.callConnected;
    var socketService = Get.find<SocketController>();
    socketService.acceptCall(callee.value!.phone);
  }

  void endCall() {
    callState.value = CallState.callEnded;
    var socketService = Get.find<SocketController>();
    socketService.declineCall(callee.value!.phone);
    Future.delayed(const Duration(seconds: 2), () {
      callState.value = CallState.callIdle;
    });
  }

  void getMediaDevices() async {
    List<MediaDeviceInfo> devices = await webRtcService.getMediaDevices();
    for (MediaDeviceInfo device in devices) {
      if (device.kind == 'videoinput') {
        videoDevices.add(device);
      }
    }
  }

  Future startLocalStream() async {
    isVideoEnabled.value = true;
    isAudioEnabled.value = true;
    localStream.value =
        await webRtcService.getLocalStream(facingMode: currentFacingMode.value);
  }

  Future switchCamera() async {
    endLocalStream();
    currentFacingMode.value =
        currentFacingMode.value == 'user' ? 'environment' : 'user';
    startLocalStream();
  }

  Future toggleVideo() async {
    isVideoEnabled.value = !isVideoEnabled.value;
    localStream.value?.getVideoTracks().forEach((track) {
      track.enabled = isVideoEnabled.value;
    });
  }

  Future toggleAudio() async {
    isAudioEnabled.value = !isAudioEnabled.value;
    localStream.value?.getAudioTracks().forEach((track) {
      track.enabled = isAudioEnabled.value;
    });
  }

  void endLocalStream() {
    localStream.value?.getTracks().forEach((track) {
      track.stop();
    });
  }
}
