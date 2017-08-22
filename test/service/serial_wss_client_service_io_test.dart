@TestOn("vm")
import 'dart:async';
import 'dart:core' hide Error;

import 'package:dev_test/test.dart';
import 'package:tekartik_common_utils/async_utils.dart';
import 'package:tekartik_serial_wss_client/channel/client/io.dart';
import 'package:tekartik_serial_wss_client/channel/io.dart';
import 'package:tekartik_serial_wss_client/constant.dart';
import 'package:tekartik_serial_wss_client/service/serial_wss_client_service.dart';
import 'package:tekartik_serial_wss_client/src/common_import.dart';
import 'package:tekartik_serial_wss_sim/serial_wss_sim.dart';
import 'serial_wss_client_service_test.dart';

// default is memory
//WebSocketChannelFactory factory =
main() {
  test_main(ioWebSocketChannelFactory);

  group('client_service_io', () {
    test('default', () async {
      SerialWssClientService service =
      new SerialWssClientService(ioWebSocketClientChannelFactory);
      expect(service.url, getSerialWssUrl());
      await service.changeUrl(null);
      expect(service.url, getSerialWssUrl());
    });


    test('invalid_url', () async {
      SerialWssClientService service =
      new SerialWssClientService(ioWebSocketClientChannelFactory, url: "dummy");
      await service.start();
      await service.changeUrl("another dummy");
      await service.stop();
    });
    // needed for url test
    test('start_stop', () async {
      var server = await SerialServer.start(
          ioWebSocketChannelFactory.server, port: 0);
      SerialWssClientService service = new SerialWssClientService(
          ioWebSocketClientChannelFactory,
          url: getSerialWssUrl(port: server.port));
      var completer = new Completer();
      expect(service.url, getSerialWssUrl(port: server.port));

      service.start();
      service.onConnected.listen((bool connected) async {
        if (connected) {
          expect(service.isConnected, isTrue);

          await service.stop();
          completer.complete();
        }
      });

      await completer.future;
      await server.close();
    });
  });
}
