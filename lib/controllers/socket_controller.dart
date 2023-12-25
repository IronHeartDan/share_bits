import 'dart:convert';

import 'package:get/get.dart';
import '../services/socket_service.dart';
import 'package:socket_io_client/socket_io_client.dart' as IO;

import 'call_controller.dart';

JsonDecoder decoder = const JsonDecoder();

class SocketEvents {
  static const String call = 'call';
  static const String callDeclined = 'callDeclined';
  static const String callAccepted = 'callAccepted';
}

class SocketController extends GetxController {
  final socketService = Get.find<SocketService>();
  final RxBool socketConnected = false.obs;

  void connectSocket(phone) {
    socketService.connectSocket(phone);
    socketService.socket.onConnect((_) {
      socketConnected.value = true;
    });

    // Listen for incoming calls
    socketService.socket.on(SocketEvents.call, (data) {
      final callController = Get.find<CallController>();
      Map<String, dynamic> decodedData = decoder.convert(data);
      callController.callee.value =
          Callee(name: '', phone: decodedData['from']);
      callController.callState.value = CallState.callIncoming;
    });

    // Listen for call declined
    socketService.socket.on(SocketEvents.callAccepted, (data) {
      final callController = Get.find<CallController>();
      callController.callState.value = CallState.callConnected;
    });

    // Listen for call declined
    socketService.socket.on(SocketEvents.callDeclined, (data) {
      final callController = Get.find<CallController>();
      callController.callState.value = CallState.callEnded;
      Future.delayed(const Duration(seconds: 2), () {
        callController.callState.value = CallState.callIdle;
      });
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

  void disconnectSocket() {
    socketService.socket.disconnect();
  }
}
