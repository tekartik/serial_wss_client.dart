@TestOn("vm")
import 'package:tekartik_serial_wss_client/src/common_import.dart';
import 'dart:async';
import 'package:dev_test/test.dart';
import 'package:tekartik_common_utils/async_utils.dart';
import 'package:tekartik_serial_wss_client/constant.dart';
import 'package:tekartik_serial_wss_client/service/serial_stream_channel_service.dart';
import 'package:tekartik_serial_wss_sim/serial_wss_sim.dart';
import 'dart:core' hide Error;
import 'package:tekartik_serial_wss_client/service/io.dart';
import 'package:tekartik_serial_wss_client/message.dart' as swss;
import 'package:tekartik_serial_wss_client/constant.dart' as swss;
import 'package:tekartik_serial_wss_client/service/serial_wss_client_service.dart';

main() {
  group('serial_stream_channel_service', () {
    /*
    test('depends', () async {
      SerialWssClientService service = new SerialWssClientService(
          ioWebSocketChannelFactory,
          retryDelay: new Duration(milliseconds: 300));
      service.start();
      for (int i = 0; i < 100; i++) {
        await sleep(100);
        print("connected: ${service.isConnected}");
      }
      await service.stop();
      print("connected: ${service.isConnected}");
      await sleep(2000);
    });
    */

    test('connect_right_away', () async {
      //Serial.debug = true;
      var server = await SerialServer.start(port: 0);
      int port = server.port;

      SerialWssClientService wssService = new SerialWssClientService(
          ioWebSocketChannelFactory,
          retryDelay: new Duration(milliseconds: 100),
          url: getSerialWssUrl(port: port));
      wssService.start();

      SerialStreamChannelService service = new SerialStreamChannelService(
          wssService,
          path: serialWssSimMasterPortPath);
      service.start();
      await Future.wait([
        () async {
          for (int i = 0; i < 20; i++) {
            await sleep(50);
            print(
                "connected/opened: ${wssService.isConnected}/${service.isOpened}");
          }
        }(),
        () async {
          await sleep(300);
          expect(wssService.isConnected, isTrue);
          expect(service.isOpened, isTrue);
          await server.close();
          await sleep(300);
          expect(wssService.isConnected, isFalse);
          expect(service.isOpened, isFalse);

          server = await SerialServer.start(port: port);
          await sleep(300);
          expect(wssService.isConnected, isTrue);
          expect(service.isOpened, isTrue);

          await server.close();
          await sleep(300);
          expect(wssService.isConnected, isFalse);
          expect(service.isOpened, isFalse);
        }(),
      ]);
    });

    test('service', () async {
      var server = await SerialServer.start(port: 0);
      int port = server.port;
      await server.close();

      SerialWssClientService wssService = new SerialWssClientService(
          ioWebSocketChannelFactory,
          retryDelay: new Duration(milliseconds: 100),
          url: getSerialWssUrl(port: port));
      wssService.start();

      SerialStreamChannelService service = new SerialStreamChannelService(
          wssService,
          path: serialWssSimMasterPortPath);
      service.start();
      await Future.wait([
        () async {
          for (int i = 0; i < 50; i++) {
            await sleep(50);
            print(
                "connected/opened: ${wssService.isConnected}/${service.isOpened}");
          }
        }(),
        () async {
          await sleep(300);
          expect(wssService.isConnected, isFalse);
          expect(service.isOpened, isFalse);

          //devPrint('[starting server]');
          server = await SerialServer.start(port: port);
          await sleep(300);
          expect(wssService.isConnected, isTrue);
          expect(service.isOpened, isTrue);

          await server.close();
        }(),
      ]);
    });

    test('null_path', () async {
      //Serial.debug = true;
      var server = await SerialServer.start(port: 0);
      int port = server.port;

      SerialWssClientService wssService = new SerialWssClientService(
          ioWebSocketChannelFactory,
          retryDelay: new Duration(milliseconds: 100),
          url: getSerialWssUrl(port: port));
      wssService.start();

      SerialStreamChannelService service =
          new SerialStreamChannelService(wssService);
      service.start();
      await Future.wait([
        () async {
          for (int i = 0; i < 20; i++) {
            await sleep(50);
            print(
                "connected/opened: ${wssService.isConnected}/${service.isOpened}");
          }
        }(),
        () async {
          await sleep(300);
          expect(wssService.isConnected, isTrue);
          expect(service.isOpened, isFalse);
        }(),
      ]);
    });

    test('starting_server_after', () async {
      var server = await SerialServer.start(port: 0);
      int port = server.port;
      await server.close();

      SerialWssClientService wssService = new SerialWssClientService(
          ioWebSocketChannelFactory,
          retryDelay: new Duration(milliseconds: 100),
          url: getSerialWssUrl(port: port));
      wssService.start();

      SerialStreamChannelService service = new SerialStreamChannelService(
          wssService,
          path: serialWssSimMasterPortPath);
      service.start();
      await Future.wait([
        () async {
          for (int i = 0; i < 50; i++) {
            await sleep(50);
            print(
                "connected/opened: ${wssService.isConnected}/${service.isOpened}");
          }
        }(),
        () async {
          await sleep(300);
          expect(wssService.isConnected, isFalse);
          expect(service.isOpened, isFalse);

          //devPrint('[starting server]');
          server = await SerialServer.start(port: port);
          await sleep(300);
          expect(wssService.isConnected, isTrue);
          expect(service.isOpened, isTrue);

          await server.close();
        }(),
      ]);
    });

    test('change_path', () async {
      //SerialStreamChannelService.debug.on = true;
      //Serial.debug.on = true;
      var server = await SerialServer.start(port: 0);
      int port = server.port;

      SerialWssClientService wssService = new SerialWssClientService(
          ioWebSocketChannelFactory,
          retryDelay: new Duration(milliseconds: 100),
          url: getSerialWssUrl(port: port));
      wssService.start();

      SerialStreamChannelService service = new SerialStreamChannelService(
          wssService,
          path: serialWssSimMasterPortPath);
      service.start();
      await Future.wait([
        () async {
          for (int i = 0; i < 12; i++) {
            await sleep(50);
            print(
                "connected/opened: ${wssService.isConnected}/${service.isOpened}");
          }
        }(),
        () async {
          await sleep(300);
          expect(wssService.isConnected, isTrue);
          expect(service.isOpened, isTrue);
          expect(service.currentChannel.path, serialWssSimMasterPortPath);
          await service.changeConnection(serialWssSimSlavePortPath);
          await sleep(300);
          expect(service.isOpened, isTrue);
          expect(service.currentChannel.path, serialWssSimSlavePortPath);

          await server.close();
        }(),
      ]);
    });

    test('busy_error', () async {
      //SerialStreamChannelService.debug.on = true;
      //Serial.debug.on = true;
      var server = await SerialServer.start(port: 0);
      int port = server.port;

      SerialWssClientService wssService = new SerialWssClientService(
          ioWebSocketChannelFactory,
          retryDelay: new Duration(milliseconds: 100),
          url: getSerialWssUrl(port: port));
      wssService.start();

      SerialStreamChannelService service1 = new SerialStreamChannelService(
          wssService,
          path: serialWssSimMasterPortPath);
      service1.start();

      SerialStreamChannelService service2 = new SerialStreamChannelService(
          wssService,
          path: serialWssSimMasterPortPath);
      service2.start();

      Completer completer = new Completer();
      service2.onOpenError.listen((swss.Error error) {
        expect(error.code, swss.errorCodePortBusy);
        completer.complete();
      });

      await completer.future;
    });
  });
}
