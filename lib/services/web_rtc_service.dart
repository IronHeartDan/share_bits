import 'package:flutter_webrtc/flutter_webrtc.dart';
import 'package:get/get.dart';
import 'package:flutter_webrtc/flutter_webrtc.dart' as web_rtc;

class WebRtcService extends GetxService {
  Future<web_rtc.RTCPeerConnection> createPeerConnection() async {
    // Create a new peer connection
    final Map<String, dynamic> configuration = {
      'iceServers': [
        {
          'urls': [
            'stun:stun1.l.google.com:19302',
            'stun:stun2.l.google.com:19302',
          ]
        },
        {
          'urls': "stun:stun.relay.metered.ca:80",
        },
        {
          'urls': "turn:standard.relay.metered.ca:80",
          'username': "7272344174d7a51db3bf35e2",
          'credential': "RLYSUoobKq1TKZ2m",
        },
        {
          'urls': "turn:standard.relay.metered.ca:80?transport=tcp",
          'username': "7272344174d7a51db3bf35e2",
          'credential': "RLYSUoobKq1TKZ2m",
        },
        {
          'urls': "turn:standard.relay.metered.ca:443",
          'username': "7272344174d7a51db3bf35e2",
          'credential': "RLYSUoobKq1TKZ2m",
        },
        {
          'urls': "turn:standard.relay.metered.ca:443?transport=tcp",
          'username': "7272344174d7a51db3bf35e2",
          'credential': "RLYSUoobKq1TKZ2m",
        },
      ],
    };
    final web_rtc.RTCPeerConnection peerConnection =
        await web_rtc.createPeerConnection(configuration);
    // Return the peer connection
    return peerConnection;
  }

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

  Future<web_rtc.RTCSessionDescription> makeCallOffer(
      web_rtc.RTCPeerConnection peerConnection) async {
    // Create an offer
    final offer = await peerConnection.createOffer();
    // Set the offer as the local description
    await peerConnection.setLocalDescription(offer);
    // Return the offer
    return offer;
  }

  Future makeCallAnswer(web_rtc.RTCPeerConnection peerConnection) async {
    // Create an answer
    final answer = await peerConnection.createAnswer();
    // Set the answer as the local description
    await peerConnection.setLocalDescription(answer);
    // Return the answer
    return answer;
  }
}
