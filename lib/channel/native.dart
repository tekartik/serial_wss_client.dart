import 'dart:async';

import 'package:stream_channel/stream_channel.dart';
import 'package:tekartik_serial_wss_client/channel/web_socket_channel.dart';
import 'package:web_socket_channel/web_socket_channel.dart' as native;

class NativeWebSocketChannel extends StreamChannelMixin
    implements WebSocketChannel {
  StreamController streamController = new StreamController();

  final native.WebSocketChannel nativeChannel;

  Completer doneCompleter = new Completer();

  NativeWebSocketChannel(this.nativeChannel) {
    nativeChannel.stream.listen((data) {
      streamController.add(data);
    }, onDone: () {
      doneCompleter.complete();
      streamController.close();
    }, onError: (e, st) {
      streamController.addError(e, st);
    });
  }

  @override
  StreamSink get sink => nativeChannel.sink;

  @override
  Stream get stream => streamController.stream;

  // when the channel is done
  // used internally
  Future get done => doneCompleter.future;

  toString() => nativeChannel.toString();
}
