@TestOn("vm")
import 'dart:async';
import 'dart:core' hide Error;

import 'package:dev_test/test.dart';
import 'package:pedantic/pedantic.dart';
import 'package:tekartik_common_utils/async_utils.dart';
import 'package:tekartik_serial_wss_client/constant.dart';
import 'package:tekartik_serial_wss_client/constant.dart' as swss;
import 'package:tekartik_serial_wss_client/message.dart' as swss;
import 'package:tekartik_serial_wss_client/service/serial_stream_channel_service.dart';
import 'package:tekartik_serial_wss_client/service/serial_wss_client_service.dart';
import 'package:tekartik_serial_wss_client/src/common_import.dart';
import 'package:tekartik_serial_wss_sim/serial_wss_sim.dart';
import 'package:tekartik_web_socket/web_socket.dart';

class EchoSlaveService {}

void main() {
  group('client_service_memory', () {
    test('default', () async {
      SerialWssClientService service =
          SerialWssClientService(webSocketChannelClientFactoryMemory);
      expect(service.url, getSerialWssUrl());
      await service.changeUrl(null);
      expect(service.url, getSerialWssUrl());
    });
  });
  testMain(webSocketChannelFactoryMemory);
}

void testMain(WebSocketChannelFactory channelFactory) {
  group('serial_stream_channel_service', () {
    test('basics', () async {
      var server = await SerialServer.start(channelFactory.server, port: 0);

      SerialWssClientService wssService = SerialWssClientService(
          channelFactory.client,
          retryDelay: const Duration(milliseconds: 100),
          url: server.url);
      wssService.start();

      SerialStreamChannelService service = SerialStreamChannelService(
          wssService,
          path: serialWssSimMasterPortPath);
      expect(service.connectionOptions, isNull);
      expect(service.connectionInfo, isNull);
      expect(service.path, serialWssSimMasterPortPath);
      service.start();

      await service.waitForOpen(true);
      expect(service.connectionOptions, isNull);
      expect(service.connectionInfo.connectionId, isNotNull);
      expect(service.path, serialWssSimMasterPortPath);
      await server.close();
      await service.waitForOpen(false);
    });

    test('restart_server', () async {
      //Serial.debug = true;
      //SerialStreamChannelService.debug.on = true;
      var server = await SerialServer.start(channelFactory.server, port: 0);
      int port = server.port;

      SerialWssClientService wssService = SerialWssClientService(
          channelFactory.client,
          retryDelay: const Duration(milliseconds: 100),
          url: server.url);
      wssService.start();

      SerialStreamChannelService service = SerialStreamChannelService(
          wssService,
          path: serialWssSimMasterPortPath);
      service.start();

      unawaited(() async {
        for (int i = 0; i < 20; i++) {
          await sleep(50);
          print(
              "connected/opened: ${wssService.isConnected}/${service.isOpened}");
        }
      }());

      await service.waitForOpen(true);
      await server.close();
      await service.waitForOpen(false);
      server = await SerialServer.start(channelFactory.server, port: port);
      await service.waitForOpen(true);
      await server.close();
      await service.waitForOpen(false);
    });

    test('start_stop_start_service', () async {
      //SerialWssClientService.debug.on = true;
      //SerialStreamChannelService.debug.on = true;
      var server = await SerialServer.start(channelFactory.server, port: 0);
      SerialWssClientService wssService =
          SerialWssClientService(channelFactory.client, url: server.url);
      wssService.start();
      SerialStreamChannelService service = SerialStreamChannelService(
          wssService,
          path: serialWssSimMasterPortPath);
      service.start();

      await service.waitForOpen(true);
      await service.stop();
      await service.waitForOpen(false);
      service.start();
      await service.waitForOpen(true);
      await service.stop();
      await service.waitForOpen(false);

      await server.close();
    });

    test('start_stop_start_wss_client_service', () async {
      //SerialWssClientService.debug.on = true;
      //SerialStreamChannelService.debug.on = true;
      var server = await SerialServer.start(channelFactory.server, port: 0);
      SerialWssClientService wssService =
          SerialWssClientService(channelFactory.client, url: server.url);
      SerialStreamChannelService service = SerialStreamChannelService(
          wssService,
          path: serialWssSimMasterPortPath);
      service.start();

      wssService.start();
      await service.waitForOpen(true);
      await wssService.stop();
      await service.waitForOpen(false);
      wssService.start();
      await service.waitForOpen(true);
      await wssService.stop();
      await service.waitForOpen(false);

      await server.close();
    });

    test('start_stop_start_both_services', () async {
      //SerialWssClientService.debug.on = true;
      //SerialStreamChannelService.debug.on = true;
      var server = await SerialServer.start(channelFactory.server, port: 0);
      SerialWssClientService wssService =
          SerialWssClientService(channelFactory.client, url: server.url);
      wssService.start();
      SerialStreamChannelService service = SerialStreamChannelService(
          wssService,
          path: serialWssSimMasterPortPath);
      service.start();

      await service.waitForOpen(true);
      await service.stop();
      await wssService.stop();
      await service.waitForOpen(false);
      service.start();
      wssService.start();
      await service.waitForOpen(true);
      await service.stop();
      await wssService.stop();
      await service.waitForOpen(false);
      wssService.start();
      service.start();
      await service.waitForOpen(true);
      await wssService.stop();
      await service.stop();
      await service.waitForOpen(false);

      await server.close();
    });

    test('null_path', () async {
      //Serial.debug = true;
      var server = await SerialServer.start(channelFactory.server, port: 0);

      SerialWssClientService wssService = SerialWssClientService(
          channelFactory.client,
          retryDelay: const Duration(milliseconds: 100),
          url: server.url);
      wssService.start();

      SerialStreamChannelService service =
          SerialStreamChannelService(wssService);
      service.start();

      await wssService.waitForConnected(true);
      await sleep(100);
      expect(wssService.isConnected, isTrue);
      expect(service.isOpened, isFalse);
    });

    test('starting_server_after', () async {
      var server = await SerialServer.start(channelFactory.server, port: 0);
      int port = server.port;
      await server.close();

      SerialWssClientService wssService = SerialWssClientService(
          channelFactory.client,
          retryDelay: const Duration(milliseconds: 100),
          url: server.url);
      wssService.start();

      SerialStreamChannelService service = SerialStreamChannelService(
          wssService,
          path: serialWssSimMasterPortPath);
      service.start();

      await sleep(100);
      expect(wssService.isConnected, isFalse);
      expect(service.isOpened, isFalse);
      server = await SerialServer.start(channelFactory.server, port: port);
      await service.waitForOpen(true);
      await server.close();
    });

    test('change_path', () async {
      //SerialStreamChannelService.debug.on = true;
      //Serial.debug.on = true;
      var server = await SerialServer.start(channelFactory.server, port: 0);

      SerialWssClientService wssService = SerialWssClientService(
          channelFactory.client,
          retryDelay: const Duration(milliseconds: 100),
          url: server.url);
      wssService.start();

      SerialStreamChannelService service = SerialStreamChannelService(
          wssService,
          path: serialWssSimMasterPortPath);
      service.start();

      await service.waitForOpen(true);
      expect(service.currentChannel.path, serialWssSimMasterPortPath);
      await service.changeConnection(serialWssSimSlavePortPath);
      await service.waitForOpen(true);
      expect(service.currentChannel.path, serialWssSimSlavePortPath);
    });

    test('busy_error', () async {
      //SerialStreamChannelService.debug.on = true;
      //Serial.debug.on = true;
      var server = await SerialServer.start(channelFactory.server, port: 0);

      SerialWssClientService wssService = SerialWssClientService(
          channelFactory.client,
          retryDelay: const Duration(milliseconds: 100),
          url: server.url);
      wssService.start();

      SerialStreamChannelService service1 = SerialStreamChannelService(
          wssService,
          path: serialWssSimMasterPortPath);
      service1.start();

      SerialStreamChannelService service2 = SerialStreamChannelService(
          wssService,
          path: serialWssSimMasterPortPath);
      service2.start();

      Completer completer = Completer();
      service2.onOpenError.listen((swss.Error error) {
        expect(error.code, swss.errorCodePortBusy);
        if (!completer.isCompleted) {
          completer.complete();
        }
      });

      await completer.future;
    });

    test('service_channel', () async {
      var server = await SerialServer.start(channelFactory.server, port: 0);

      SerialWssClientService wssService =
          SerialWssClientService(channelFactory.client, url: server.url);
      wssService.start();

      SerialStreamChannelService master = SerialStreamChannelService(wssService,
          path: serialWssSimMasterPortPath);
      master.start();

      SerialStreamChannelService slave = SerialStreamChannelService(wssService,
          path: serialWssSimSlavePortPath);
      slave.start();

      await master.waitForOpen(true);
      await slave.waitForOpen(true);

      Completer masterReceiveCompleter = Completer();
      Completer slaveReceiveCompleter = Completer();
      Completer masterAnotherStreamReceiveCompleter = Completer();
      Completer masterSinkStreamReceiveCompleter = Completer();

      slave.channel.sink.add([5, 6, 7, 8]);

      // make sure we can listen multiple times to the stream
      master.stream.listen((List<int> data) {
        expect(data, [5, 6, 7, 8]);
        print(data);
        masterAnotherStreamReceiveCompleter.complete();
      });
      // this does not work if data was added before...
      master.sinkStream.listen((List<int> data) {
        expect(data, [1, 2, 3, 4]);
        print(data);
        masterSinkStreamReceiveCompleter.complete();
      });

      master.channel.sink.add([1, 2, 3, 4]);

      master.channel.stream.listen((List<int> data) {
        expect(data, [5, 6, 7, 8]);
        //print(data);
        masterReceiveCompleter.complete();
      });

      slave.channel.stream.listen((List<int> data) {
        expect(data, [1, 2, 3, 4]);
        //print(data);
        slaveReceiveCompleter.complete();
      });

      await Future.wait([
        masterAnotherStreamReceiveCompleter.future,
        masterSinkStreamReceiveCompleter.future,
        masterReceiveCompleter.future,
        slaveReceiveCompleter.future
      ]);
      //await service.stop();
      await server.close();
    });
  });
}
