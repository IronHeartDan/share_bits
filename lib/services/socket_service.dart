import 'dart:io';
import 'package:get/get.dart';
import 'package:socket_io_client/socket_io_client.dart' as IO;

class SocketEvents {
  static const String call = 'call';
  static const String callDeclined = 'callDeclined';
  static const String callAccepted = 'callAccepted';
  static const String rtcOffer = 'rtcOffer';
  static const String rtcAnswer = 'rtcAnswer';
  static const String iceCandidate = 'iceCandidate';
}

class SocketService extends GetxService {
  late IO.Socket socket;

  String? getServer() {
    if (Platform.isAndroid) {
      return 'http://10.0.2.2:3000';
    }
    return 'http://localhost:3000';
  }

  void connectSocket(phone) {
    socket = IO.io(
        getServer(),
        IO.OptionBuilder()
            .setTransports(['websocket']) // for Flutter or Dart VM
            .setExtraHeaders({'phone': phone}) // optional
            .build());
  }

  void makeCall(String to) {
    socket.emit(SocketEvents.call, to);
  }

  void acceptCall(String to) {
    socket.emit(SocketEvents.callAccepted, to);
  }

  void declineCall(String to) {
    socket.emit(SocketEvents.callDeclined, to);
  }

  void sendOffer(String to, offer) {
    socket.emit(SocketEvents.rtcOffer, offer);
  }

  void sendAnswer(String to, answer) {
    socket.emit(SocketEvents.rtcAnswer, answer);
  }

  void sendIceCandidate(String to, candidate) {
    socket.emit(SocketEvents.iceCandidate, candidate);
  }

  void disconnectSocket() {
    socket.disconnect();
  }
}
