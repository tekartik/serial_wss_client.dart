import 'dart:async';
import 'dart:core' hide Error;

import 'package:dev_test/test.dart';
import 'package:tekartik_common_utils/async_utils.dart';
import 'package:tekartik_web_socket/web_socket.dart';
import 'package:tekartik_serial_wss_client/constant.dart';
import 'package:tekartik_serial_wss_client/service/serial_wss_client_service.dart';
import 'package:tekartik_serial_wss_client/src/common_import.dart';
import 'package:tekartik_serial_wss_sim/serial_wss_sim.dart';

main() {
  group('client_service_memory', () {
    test('default', () async {
      SerialWssClientService service =
          new SerialWssClientService(webSocketChannelClientFactoryMemory);
      expect(service.url, getSerialWssUrl());
      await service.changeUrl(null);
      expect(service.url, getSerialWssUrl());
    });
  });
  test_main(webSocketChannelFactoryMemory);
}

test_main(WebSocketChannelFactory channelFactory) {
  group('client_service', () {
    test('default', () async {
      SerialWssClientService service =
          new SerialWssClientService(channelFactory.client);
      expect(service.url, getSerialWssUrl());
      await service.changeUrl(null);
      expect(service.url, getSerialWssUrl());
    });

    test('invalid_url', () async {
      SerialWssClientService service =
          new SerialWssClientService(channelFactory.client, url: "dummy");
      await service.start();
      await service.changeUrl("another dummy");
      await service.stop();
    });
    test('start_stop', () async {
      var server = await SerialServer.start(channelFactory.server, port: 0);
      SerialWssClientService service =
          new SerialWssClientService(channelFactory.client, url: server.url);
      var completer = new Completer();
      //expect(service.url, getSerialWssUrl(port: server.port));

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

    test('start_stop_start', () async {
      //SerialWssClientService.debug.on = true;
      var server = await SerialServer.start(channelFactory.server, port: 0);
      SerialWssClientService service =
          new SerialWssClientService(channelFactory.client, url: server.url);

      service.start();
      await service.waitForConnected(true);
      await service.stop();
      expect(service.isConnected, isFalse);
      await service.start();
      await service.waitForConnected(true);
      await service.stop();
      expect(service.isConnected, isFalse);

      await server.close();
    });

    test('service', () async {
      //SerialServer.debug.on = true;
      //SerialWssClientService.debug.on = true;
      //Serial.debug.on = true;
      var server = await SerialServer.start(channelFactory.server, port: 0);
      int port = server.port;
      await server.close();

      SerialWssClientService service = new SerialWssClientService(
          channelFactory.client,
          retryDelay: new Duration(milliseconds: 100),
          url: server.url);
      service.start();

      await sleep(100);
      await service.waitForConnected(false);

      server = await SerialServer.start(channelFactory.server, port: port);
      await service.waitForConnected(true);
      expect(service.isConnected, isTrue);
      await server.close();
      await service.waitForConnected(false);
      expect(service.isConnected, isFalse);
      server = await SerialServer.start(channelFactory.server, port: port);
      await service.waitForConnected(true);
      expect(service.isConnected, isTrue);
      await server.close();
      await service.waitForConnected(false);
      expect(service.isConnected, isFalse);
    });

    test('change_port', () async {
      var server1 = await SerialServer.start(channelFactory.server, port: 0);
      var server2 = await SerialServer.start(channelFactory.server, port: 0);

      SerialWssClientService service =
          new SerialWssClientService(channelFactory.client,
              //retryDelay: new Duration(milliseconds: timeScale * 2),
              url: server1.url);
      service.start();

      await service.waitForConnected(true);
      expect(service.connectedUrl, server1.url);
      await server1.close();
      await service.waitForConnected(false);
      await service.changeUrl(server2.url);
      await service.waitForConnected(true);
      expect(service.connectedUrl, server2.url);
      await server2.close();

      server1 = await SerialServer.start(channelFactory.server, port: 0);
      await service.changeUrl(server1.url);
      await service.waitForConnected(true);
      expect(service.connectedUrl, server1.url);
      await server1.close();
    });

    test('on_connect_error', () async {
      //SerialStreamChannelService.debug.on = true;
      //Serial.debug.on = true;
      var server = await SerialServer.start(channelFactory.server, port: 0);
      await server.close();

      SerialWssClientService wssService = new SerialWssClientService(
          channelFactory.client,
          retryDelay: new Duration(milliseconds: 100),
          url: server.url);
      wssService.start();

      Completer completer = new Completer();
      wssService.onConnectError.listen((error) {
        if (!completer.isCompleted) {
          completer.complete();
        }
      });

      await completer.future;
      await wssService.stop();
    });
  });
}
