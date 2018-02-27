import 'dart:async';

import 'package:tekartik_serial_wss_client/channel/server/web_socket_channel_server.dart';
import 'package:tekartik_serial_wss_client/channel/src/memory/memory_web_socket_channel.dart';

class _MemoryWebSocketChannelServerFactory
    implements WebSocketChannelServerFactory {
  Future<WebSocketChannelServer> serve({address, int port}) async {
    port ??= 0;
    // We don't care about the address
    //address ??= InternetAddress.ANY_IP_V6;

    port = memoryWebSocket.checkPort(port);

    WebSocketChannelServer server = new MemoryWebSocketChannelServer(port);

    // Add in our global table
    memoryWebSocket.addServer(server);

    return server;
    /*
    port ??= serialWssPortDefault;
    address ??= InternetAddress.ANY_IP_V6;
    HttpServer httpServer;

    _IoWebSocketChannelServer serialServer;

    var handler = webSocketHandler((native.WebSocketChannel webSocketChannel) {
      SerialServerConnection serverChannel = new SerialServerConnection(
          serialServer, ++serialServer.lastId, webSocketChannel);

      serialServer.channels.add(serverChannel);
      if (SerialServer.debug) {
        print("[SerialServer] adding channel: ${serialServer.channels}");
      }
    });

    httpServer = await shelf_io.serve(handler, address, port);
    serialServer =
    //new SerialServer(await shelf_io.serve(handler, 'localhost', 8988));
    new IoSerialServer(httpServer);
    if (SerialServer.debug) {
      print(
          'Serving at ws://${serialServer.httpServer.address
              .host}:${serialServer
              .httpServer.port}');
    }
    return serialServer;
    */
  }
}

// bool _debug = true;

WebSocketChannelServerFactory memoryWebSocketChannelServerFactory =
    new _MemoryWebSocketChannelServerFactory();
