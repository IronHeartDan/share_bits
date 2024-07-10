import 'package:get/get.dart';
import 'package:socket_io_client/socket_io_client.dart' as IO;

import '../utils/constants.dart';

class SocketService extends GetxService {
  IO.Socket? socket;

  void connectSocket(phone) {
    socket = IO.io(
        getServer(),
        IO.OptionBuilder()
            .setTransports(['websocket']) // for Flutter or Dart VM
            .setExtraHeaders({'phone': phone}) // optional
            .build());
  }

  void disconnectSocket() {
    socket?.disconnect();
    socket = null;
  }
}
