import 'dart:async';

import 'package:dev_test/test.dart';
import 'package:tekartik_common_utils/common_utils_import.dart';
import 'package:tekartik_serial_wss_client/channel/memory.dart';
import 'package:tekartik_serial_wss_client/channel/server/web_socket_channel_server.dart';
import 'package:tekartik_serial_wss_client/channel/web_socket_channel.dart';
//import 'package:func/func.dart';

//import 'package:tekartik_serial_wss_client/channel/channel.dart';

main() {
  channel_test_main(memoryWebSocketChannelFactory);
}

channel_test_main(WebSocketChannelFactory channelFactory) {
  group("channel", () {
    group("simple", () {
      WebSocketChannelServer server;
      WebSocketChannel wsClient;
      WebSocketChannel wsServer;

      Future simpleTest(Function close) async {
        server = await channelFactory.server.serve();
        wsClient = channelFactory.client.connect(server.url);
        wsServer = await server.stream.first;

        //wsClient.stream.listen(onData)

        Completer serverDoneCompleter = new Completer();
        Completer clientDoneCompleter = new Completer();
        Completer masterReceiveCompleter = new Completer();
        Completer slaveReceiveCompleter = new Completer();

        wsServer.sink.add([1, 2, 3, 4]);
        wsClient.sink.add([5, 6, 7, 8]);

        wsServer.stream.listen((List<int> data) {
          expect(data, [5, 6, 7, 8]);
          //devPrint(data);
          masterReceiveCompleter.complete();
        }, onDone: () {
          //devPrint("server.onDone");
          serverDoneCompleter.complete();
        }, onError: (e) {
          print('server.onError $e');
        });

        wsClient.stream.listen((List<int> data) {
          expect(data, [1, 2, 3, 4]);
          //devPrint(data);
          slaveReceiveCompleter.complete();
        }, onDone: () {
          //devPrint("client.onDone");
          clientDoneCompleter.complete();
        }, onError: (e) {
          print('client.onError $e');
        });

        await masterReceiveCompleter.future;
        await slaveReceiveCompleter.future;

        // close server
        await close();
        await serverDoneCompleter.future;
        await clientDoneCompleter.future;
      }

      test("close_server", () async {
        await simpleTest(() async {
          await await server.close();
        });
      });

      test("close_ws_server", () async {
        await simpleTest(() async {
          await await wsServer.sink.close();
        });
      });

      test("close_ws_client", () async {
        await simpleTest(() async {
          await await wsServer.sink.close();
        });
      });
    });

    test("failure_right_away", () async {
      bool failed = false;
      try {
        channelFactory.client.connect("dummy");
      } catch (_) {
        failed = true;
      }

      expect(failed, isTrue);
    });

    test("failure_on_done", () async {
      WebSocketChannel wsClient;
      wsClient =
          channelFactory.client.connect("${channelFactory.scheme}://dummy");

      bool failed = false;
      try {
        await wsClient.stream.toList();
      } catch (e) {
        //devPrint("Err: $e");
        failed = true;
      }

      expect(failed, isTrue);
    });
  });
}
