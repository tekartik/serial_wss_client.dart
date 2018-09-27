@TestOn("vm")
import 'dart:async';
import 'dart:core' hide Error;

import 'package:dev_test/test.dart';
import 'package:tekartik_web_socket_io/web_socket_io.dart';
import 'package:tekartik_web_socket/src/web_socket_memory.dart';
import 'package:tekartik_serial_wss_client/constant.dart';
import 'package:tekartik_serial_wss_client/service/serial_wss_client_service.dart';
import 'package:tekartik_serial_wss_client/src/common_import.dart';
import 'package:tekartik_serial_wss_sim/serial_wss_sim.dart';

import 'serial_wss_client_service_test.dart';

// default is memory
//WebSocketChannelFactory factory =
main() {
  test_main(webSocketChannelFactoryIo);

  group('client_service_io', () {
    test('default', () async {
      SerialWssClientService service =
          new SerialWssClientService(webSocketChannelClientFactoryIo);
      expect(service.url, getSerialWssUrl());
      await service.changeUrl(null);
      expect(service.url, getSerialWssUrl());
    });

    test('invalid_url', () async {
      SerialWssClientService service = new SerialWssClientService(
          webSocketChannelClientFactoryIo,
          url: "dummy");
      await service.start();
      await service.changeUrl("another dummy");
      await service.stop();
    });
    // needed for url test
    test('start_stop', () async {
      var server =
          await SerialServer.start(webSocketChannelFactoryIo.server, port: 0);
      SerialWssClientService service = new SerialWssClientService(
          webSocketChannelClientFactoryIo,
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

    test('change_scheme', () async {
      var server1 =
          await SerialServer.start(webSocketChannelFactoryIo.server, port: 0);
      var server2 =
          await SerialServer.start(webSocketChannelFactoryIo.server, port: 0);

      var clientChannelFactory =
          smartWebSocketChannelClientFactory(webSocketChannelFactoryIo.client);
      SerialWssClientService service =
          new SerialWssClientService(clientChannelFactory, url: server1.url);
      service.start();

      await service.waitForConnected(true);
      expect(service.connectedUrl, server1.url);
      await server1.close();
      await service.waitForConnected(false);
      await service.changeUrl(server2.url);
      await service.waitForConnected(true);
      expect(service.connectedUrl, server2.url);
      await server2.close();

      server1 =
          await SerialServer.start(webSocketChannelFactoryIo.server, port: 0);
      await service.changeUrl(server1.url);
      await service.waitForConnected(true);
      expect(service.connectedUrl, server1.url);
      await server1.close();
    });
  });
}
