import 'dart:async';
import 'package:async/src/stream_sink_transformer.dart';
import 'package:stream_channel/src/stream_channel_transformer.dart';
import 'package:stream_channel/stream_channel.dart';
import 'package:tekartik_common_utils/dev_utils.dart';
import 'package:tekartik_common_utils/int_utils.dart';
import 'package:tekartik_serial_wss_client/channel/client/memory.dart';
import 'package:tekartik_serial_wss_client/channel/client/web_socket_channel.dart';
import 'package:tekartik_serial_wss_client/channel/server/web_socket_channel_server.dart';
import 'package:tekartik_serial_wss_client/channel/web_socket_channel.dart';
import 'package:web_socket_channel/web_socket_channel.dart' as native;

class MemoryWebSocket {
  int _lastPortId = 0;
  Map<int, WebSocketChannelServer> servers = {};
  Map<int, MemoryWebSocketChannel> channels = {}; // both server and client

  addServer(WebSocketChannelServer server) {
    servers[server.port] = server;
    devPrint("adding $server");
  }

  removeServer(WebSocketChannelServer server) {
    servers.remove(server.port);
    devPrint("removing $server");
  }

  int checkPort(int port) {
    if (servers.keys.contains(port)) {
      throw 'port $port used';
    }
    if (port == 0) {
      port = ++_lastPortId;
    }
    return port;
  }

}

final MemoryWebSocket memoryWebSocket = new MemoryWebSocket();
/*
class MemoryServer {
  List<WebSocketChannelServer> servers;

  MemoryWebSocketChannel server;
  MemoryWebSocketChannel slave;

  bool addChannel(MemoryWebSocketChannel channel) {
    if (channel.url == masterUrl) {
      master = channel;
      return true;
    } else if (channel.url ==slaveUrl) {
        slave = channel;
        return true;
    }
    return false;
  }

  MemoryWebSocketChannel getOppositeChannel(MemoryWebSocketChannel channel) {
    if (channel == master) {
      return slave;
    } else if (channel == slave) {
      return master;
    }
  }
}

final MemoryServer memoryServicer = new MemoryServer();
*/
class MemorySink implements StreamSink {
  final MemoryWebSocketChannel channel;

  MemorySink(this.channel);
  MemoryWebSocketChannel get link => channel.link;

  Completer doneCompleter = new Completer();
  @override
  void add(event) {
    if (link != null) {
      link.streamController.add(event);
    }
  }

  @override
  void addError(Object error, [StackTrace stackTrace]) {
    if (link != null) {
      link.streamController.addError(error, stackTrace);
    }
  }

  @override
  Future addStream(Stream stream) {
    if (link != null) {
      return link.streamController.addStream(stream);
    }
    return new Future.value();
  }

  @override
  Future close() {
    doneCompleter.complete();
  }

  @override
  Future get done => doneCompleter.future;
}
class MemoryWebSocketClientChannelFactory extends WebSocketClientChannelFactory {

  @override
  WebSocketChannel connect(String url) {
    return new MemoryWebSocketClientChannel.connect(url);
  }
}

class MemoryWebSocketServerChannel extends MemoryWebSocketChannel {
  // associated client
  MemoryWebSocketClientChannel client;
  MemoryWebSocketChannel get link => client;
}
class MemoryWebSocketClientChannel extends MemoryWebSocketChannel {
  MemoryWebSocketServerChannel server;
  MemoryWebSocketChannel get link => server;
  String url;
  MemoryWebSocketClientChannel.connect(this.url) {

    int port = parseInt(url.replaceFirst(webSocketUrlMemoryScheme + ":" ,""));
    devPrint("port $port");


    // Find server
    MemoryWebSocketChannelServer channelServer = memoryWebSocket.servers[port];
    if (channelServer != null) {
      // connect them
      MemoryWebSocketServerChannel serverChannel = new MemoryWebSocketServerChannel()..client = this;
      this.server = serverChannel;

      // notify
      channelServer.streamController.add(serverChannel);
    } else {
      throw "cannot connect ${this.url}";
    }
  }
}
abstract class MemoryWebSocketChannel extends StreamChannelMixin implements WebSocketChannel   {
  int id;

  StreamController streamController;
  String url;

  MemoryWebSocketChannel get link;
  MemoryWebSocketChannel() {
    streamController = new StreamController();
    sink = new MemorySink(this);
  }

  @override
  StreamSink sink;

  @override
  Stream get stream => streamController.stream;
}

class MergedWebSocketChannelClientFactory extends WebSocketClientChannelFactory {
  WebSocketClientChannelFactory defaultFactory;

  MergedWebSocketChannelClientFactory(this.defaultFactory);
  @override
  WebSocketChannel connect(String url) {
    if (url.startsWith("memory:")) {
      return new MemoryWebSocketClientChannel.connect(url);
    }
    return defaultFactory.connect(url);
  }
}


class MemoryWebSocketChannelServer implements WebSocketChannelServer {

  StreamController<MemoryWebSocketServerChannel> streamController;
  Stream<WebSocketChannel> get stream => streamController.stream;

  final int port;
  MemoryWebSocketChannelServer(this.port) {
    streamController = new StreamController();

  }

  close() async {
    streamController.close();

    // remove from our table
    memoryWebSocket.removeServer(this);

  }

  @override
  String get url => "${webSocketUrlMemoryScheme}:${port}";

  toString() => "server $url";

}