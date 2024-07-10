import 'dart:developer';

import 'package:flutter_webrtc/flutter_webrtc.dart';
import 'package:get/get.dart';
import 'package:share_bits/controllers/socket_controller.dart';
import 'package:share_bits/services/web_rtc_service.dart';

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
  final SocketController socketController = Get.find<SocketController>();

  late RxList<MediaDeviceInfo> videoDevices = RxList<MediaDeviceInfo>([]);
  Rx<MediaStream?> localStream = Rx<MediaStream?>(null);
  Rx<MediaStream?> remoteStream = Rx<MediaStream?>(null);
  late RTCPeerConnection peerConnection;

  RxString callState = CallState.callIdle.obs;
  RxBool isFullScreen = false.obs;
  RxString currentFacingMode = 'user'.obs;
  RxBool isVideoEnabled = true.obs;
  RxBool isAudioEnabled = true.obs;
  Rx<Callee?> callee = Callee(name: '', phone: '9998082351').obs;

  Future initPeerConnection() async {
    peerConnection = await webRtcService.createPeerConnection();
    localStream.value!.getTracks().forEach((element) {
      peerConnection.addTrack(element, localStream.value!);
    });
  }

  void initializeWebRTC(String type) async {
    SocketController socketController = Get.find<SocketController>();
    peerConnection.onIceCandidate = (candidate) {
      socketController.sendIceCandidate({
        'candidate': candidate.toMap(),
        'to': callee.value!.phone,
      });
    };
    peerConnection.onTrack = (event) {
      log('//////////////////////////////////');
      print('WEBRTC : onTrack');
      log('//////////////////////////////////');
    };
    peerConnection.onAddStream = (stream) {
      log('//////////////////////////////////');
      print('WEBRTC : onAddStream');
      log('//////////////////////////////////');
      remoteStream.value = stream;
    };
    peerConnection.onRemoveStream = (stream) {
      print('WEBRTC : onRemoveStream');
    };
    peerConnection.onIceConnectionState = (state) {
      print('WEBRTC : onIceConnectionState : $state');
    };
    peerConnection.onIceGatheringState = (state) {
      log('//////////////////////////////////');
      print('WEBRTC : onIceGatheringState: $state');
      log('//////////////////////////////////');
    };
    peerConnection.onSignalingState = (state) {
      print('WEBRTC : onSignalingState : $state');
    };
    peerConnection.onConnectionState = (state) {
      print('WEBRTC : onConnectionState : $state');
    };
    peerConnection.onDataChannel = (channel) {
      print('WEBRTC : onDataChannel');
    };
    peerConnection.onRenegotiationNeeded = () {
      print('WEBRTC : onRenegotiationNeeded');
    };

    if (type == SocketEvents.rtcOffer) {
      var offer = await webRtcService.makeCallOffer(peerConnection);
      socketController.sendOffer({
        'offer': offer.toMap(),
        'to': callee.value!.phone,
      });
    }

    if (type == SocketEvents.rtcAnswer) {
      var answer = await webRtcService.makeCallAnswer(peerConnection);
      socketController.sendAnswer({
        'answer': answer.toMap(),
        'to': callee.value!.phone,
      });
    }
  }

  void addRemoteOffer(RTCSessionDescription offer) {
    peerConnection.setRemoteDescription(offer);
  }

  void addRemoteAnswer(RTCSessionDescription answer) {
    peerConnection.setRemoteDescription(answer);
  }

  void addRemoteCandidate(RTCIceCandidate candidate) {
    peerConnection.addCandidate(candidate);
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

  void makeCall(to) async {
    callState.value = CallState.callOutgoing;
    await initPeerConnection();
    socketController.makeCall(to);
  }

  void answerCall() async {
    callState.value = CallState.callConnected;
    await initPeerConnection();
    socketController.acceptCall(callee.value!.phone);
  }

  void endCall() {
    callState.value = CallState.callEnded;
    socketController.declineCall(callee.value!.phone);
    Future.delayed(const Duration(seconds: 2), () {
      callState.value = CallState.callIdle;
    });
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
