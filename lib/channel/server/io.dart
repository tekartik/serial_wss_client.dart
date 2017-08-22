import 'dart:async';
import 'dart:io' hide sleep;

import 'package:shelf_web_socket/shelf_web_socket.dart';
import 'package:tekartik_serial_wss_client/channel/native.dart';
import 'package:tekartik_serial_wss_client/channel/server/web_socket_channel_server.dart';
import 'package:tekartik_serial_wss_client/channel/web_socket_channel.dart';
import 'package:web_socket_channel/web_socket_channel.dart' as native;
import 'package:tekartik_serial_wss_client/constant.dart';
import 'package:tekartik_serial_wss_sim/serial_wss_sim.dart';
import 'package:shelf/shelf_io.dart' as shelf_io;

class _IoWebSocketChannelServerFactory implements WebSocketChannelServerFactory {

  Future<WebSocketChannelServer> serve({address, int port}) async {
    port ??= 0;
    address ??= InternetAddress.ANY_IP_V6;
    _IoWebSocketChannelServer server = new _IoWebSocketChannelServer(address, port);
    await server.serve();
    return server;
  }
}

bool _debug = true;

WebSocketChannelServerFactory ioWebSocketChannelServerFactory = new _IoWebSocketChannelServerFactory();

class _IoWebSocketChannelServer implements WebSocketChannelServer {

  //static DevFlag debug = new DevFlag("debug");
  var address;

  // Port will changed when serving
  int port;
  HttpServer httpServer;
  _IoWebSocketChannelServer(this.address, this.port) {
    streamController = new StreamController();

  }
  Future serve() async {

    var handler = webSocketHandler((native.WebSocketChannel nativeWebSocketChannel) {
      WebSocketChannel webSocketChannel = new NativeWebSocketChannel(nativeWebSocketChannel);
      streamController.add(webSocketChannel);
      if (_debug) {
        print("[_IoWebSocketChannelServer] adding channel: ${webSocketChannel}");
      }
    });

    this.httpServer = await shelf_io.serve(handler, address, port);
    port = httpServer.port;
    if (_debug) {
      print(httpServer.address);
      print(
          'Serving at $url');
    }

  }

  StreamController<WebSocketChannel> streamController;
  Stream<WebSocketChannel> get stream => streamController.stream;

  close() async {
    await httpServer.close(force: true);
  }

  @override
  String get url =>
     "ws://localhost:${port}";
  // "ws://${httpServer.address.host}:${port}"; not working
}
