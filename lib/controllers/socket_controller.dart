import 'dart:convert';
import 'dart:developer';

import 'package:flutter_webrtc/flutter_webrtc.dart';
import 'package:get/get.dart';
import '../services/socket_service.dart';
import 'package:socket_io_client/socket_io_client.dart' as IO;

import 'call_controller.dart';

const JsonEncoder encoder = JsonEncoder();
const JsonDecoder decoder = JsonDecoder();

class SocketEvents {
  static const String call = 'call';
  static const String callDeclined = 'callDeclined';
  static const String callAccepted = 'callAccepted';
  static const String rtcOffer = 'rtcOffer';
  static const String rtcAnswer = 'rtcAnswer';
  static const String iceCandidate = 'iceCandidate';
}

class SocketController extends GetxController {
  final socketService = Get.find<SocketService>();
  final RxBool socketConnected = false.obs;

  late CallController callController;

  void connectSocket(phone, CallController callController) {
    this.callController = callController;

    socketService.connectSocket(phone);
    socketService.socket.onConnect((_) {
      socketConnected.value = true;
    });

    // Listen for incoming calls
    socketService.socket.on(SocketEvents.call, (data) {
      Map<String, dynamic> decodedData = decoder.convert(data);
      callController.callee.value =
          Callee(name: '', phone: decodedData['from']);
      callController.callState.value = CallState.callIncoming;
    });

    // Listen for call accepted
    socketService.socket.on(SocketEvents.callAccepted, (data) {
      callController.callState.value = CallState.callConnected;
      callController.initializeWebRTC(SocketEvents.rtcOffer);
    });

    // Listen for call declined
    socketService.socket.on(SocketEvents.callDeclined, (data) {
      callController.callState.value = CallState.callEnded;
      Future.delayed(const Duration(seconds: 2), () {
        callController.callState.value = CallState.callIdle;
      });
    });

    // Listen for rtc offer
    socketService.socket.on(SocketEvents.rtcOffer, (data) {
      log('WEBRTC : rtcOffer Received');
      Map<String, dynamic> decodedData = decoder.convert(data);
      Map<String, dynamic> offer = decodedData['offer'];
      callController
          .addRemoteOffer(RTCSessionDescription(offer['sdp'], offer['type']));
      callController.initializeWebRTC(SocketEvents.rtcAnswer);
    });

    // Listen for rtc answer
    socketService.socket.on(SocketEvents.rtcAnswer, (data) {
      log('WEBRTC : rtcAnswer Received');
      Map<String, dynamic> decodedData = decoder.convert(data);
      Map<String, dynamic> answer = decodedData['answer'];
      callController.addRemoteAnswer(
          RTCSessionDescription(answer['sdp'], answer['type']));
    });

    // Listen for ice candidate
    socketService.socket.on(SocketEvents.iceCandidate, (data) {
      log('WEBRTC : iceCandidate Received');
      Map<String, dynamic> decodedData = decoder.convert(data);
      Map<String, dynamic> candidate = decodedData['candidate'];
      callController.addRemoteCandidate(RTCIceCandidate(candidate['candidate'],
          candidate['sdpMid'], candidate['sdpMLineIndex']));
    });

    socketService.socket.onDisconnect((_) {
      socketConnected.value = false;
    });
  }

  void makeCall(String to) {
    socketService.socket.emit(SocketEvents.call, to);
  }

  void acceptCall(String to) {
    socketService.socket.emit(SocketEvents.callAccepted, to);
  }

  void declineCall(String to) {
    socketService.socket.emit(SocketEvents.callDeclined, to);
  }

  void sendOffer(data) {
    socketService.socket.emit(SocketEvents.rtcOffer, encoder.convert(data));
  }

  void sendAnswer(data) {
    socketService.socket.emit(SocketEvents.rtcAnswer, encoder.convert(data));
  }

  void sendIceCandidate(data) {
    socketService.socket.emit(SocketEvents.iceCandidate, encoder.convert(data));
  }

  void disconnectSocket() {
    socketService.socket.disconnect();
  }
}
