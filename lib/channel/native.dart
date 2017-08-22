import 'dart:async';
import 'package:async/src/stream_sink_transformer.dart';
import 'package:stream_channel/src/stream_channel_transformer.dart';
import 'package:stream_channel/stream_channel.dart';
import 'package:tekartik_serial_wss_client/channel/web_socket_channel.dart';
import 'package:web_socket_channel/web_socket_channel.dart' as native;

class NativeWebSocketChannel extends StreamChannelMixin implements WebSocketChannel  {
  final native.WebSocketChannel nativeChannel;

  NativeWebSocketChannel(this.nativeChannel);

  @override
  StreamSink get sink => nativeChannel.sink;

  @override
  Stream get stream => nativeChannel.stream;

}