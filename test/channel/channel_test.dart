import 'dart:async';
import 'package:dev_test/test.dart';
import 'package:tekartik_common_utils/common_utils_import.dart';
import 'package:tekartik_serial_wss_client/channel/client/memory.dart';
import 'package:tekartik_serial_wss_client/channel/server/memory.dart';
import 'package:tekartik_serial_wss_client/channel/server/web_socket_channel_server.dart';
import 'package:tekartik_serial_wss_client/channel/web_socket_channel.dart';
//import 'package:tekartik_serial_wss_client/channel/channel.dart';


main() {
  group("channel", () {
    test("memory", () async {
      WebSocketChannelServer server = await memoryWebSocketChannelServerFactory.serve();
      WebSocketChannel wsSlave = memoryWebSocketClientChannelFactory.connect(server.url);
      WebSocketChannel wsMaster = await server.stream.first;

      Completer masterReceiveCompleter = new Completer();
      Completer slaveReceiveCompleter = new Completer();

      wsMaster.sink.add([1, 2, 3, 4]);
      wsSlave.sink.add([5, 6, 7, 8]);

      wsMaster.stream.listen((List<int> data) {
        expect(data, [5, 6, 7, 8]);
        devPrint(data);
        masterReceiveCompleter.complete();
      });

      wsSlave.stream.listen((List<int> data) {
        expect(data, [1, 2, 3, 4]);
        devPrint(data);
        slaveReceiveCompleter.complete();
      });

      await masterReceiveCompleter.future;
      await slaveReceiveCompleter.future;
      //await wsMaster.close();
      /*
      DevNullChannel channel = new DevNullChannel();
      Future closed = channel.onClose;
      channel.close();
      expect(await closed, isNull);
      */
    });
  });
}
