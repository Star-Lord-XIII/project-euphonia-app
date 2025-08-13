import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:web_socket_channel/web_socket_channel.dart';

final class WebsocketTranscriber extends ChangeNotifier {
  var isConnected = false;
  var _started = false;
  var errorMessage = '';
  var _text = '';
  WebSocketChannel? _channel;
  String get text => _text + (_started ? '...' : '');

  Future<void> initializeConnection(String websocketEndpoint) async {
    if (_channel != null) {
      return;
    }
    _channel = WebSocketChannel.connect(Uri.parse(websocketEndpoint));
    _started = true;
    await _initSocket();
  }

  Future<void> _initSocket() async {
    errorMessage = '';
    try {
      await _channel?.ready;
      isConnected = true;
      _channel?.stream.listen((data) {
        errorMessage = '';
        if (_text.isEmpty) {
          _text = data;
        } else {
          _text += ' $data';
        }
        _started = true;
        notifyListeners();
      }, onError: (e) {
        errorMessage = e.toString();
        notifyListeners();
      }, cancelOnError: false);
    } on SocketException catch (e) {
      errorMessage = e.message;
    } on WebSocketChannelException catch (e) {
      errorMessage = e.message ?? 'WebSocketChannelException occurred';
    }
    notifyListeners();
  }

  void startSendingDataToChannel() {
    _text = '';
    notifyListeners();
  }

  void sendDataToChannel(Uint8List data) {
    _channel?.sink.add(data);
  }

  void stopSendingDataToChannel() {
    _started = false;
    notifyListeners();
  }

  @override
  void dispose() {
    _channel?.sink.close();
    super.dispose();
  }
}
