import 'package:get/get.dart';
import 'package:flutter_webrtc/flutter_webrtc.dart' as web_rtc;

class WebRtcService extends GetxService {
  Future<List<web_rtc.MediaDeviceInfo>> getMediaDevices() async {
    return await web_rtc.navigator.mediaDevices.enumerateDevices();
  }

  Future<web_rtc.MediaStream> getLocalStream({facingMode = 'user'}) async {
    // Initialize and obtain the local media stream
    return await web_rtc.navigator.mediaDevices.getUserMedia({
      'audio': true,
      'video': {
        'mandatory': {
          'minWidth': '1280',
          'minHeight': '720',
          'minFrameRate': '30',
        },
        'facingMode': facingMode,
        'optional': [],
      }
    });
  }
}
