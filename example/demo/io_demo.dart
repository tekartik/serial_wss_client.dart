import 'package:tekartik_serial_wss_client/service/serial_wss_client_service.dart';
import 'package:tekartik_web_socket_io/web_socket_io.dart';

Future main() async {
  var service = SerialWssClientService(webSocketChannelClientFactoryIo);
  service.start();

  service.onConnected.listen((bool connected) async {
    if (connected) {
      print('connected');

      var deviceInfos = await service.serial.getDevices();

      print(deviceInfos);
      var deviceInfo = deviceInfos.first;
      var serialStreamChannel =
          await service.serial.createChannel(deviceInfo.path);

      serialStreamChannel.sink.add('hello\r'.codeUnits);

      serialStreamChannel.stream.listen((List<int> data) {
        print('received ${data}');
      });

      await serialStreamChannel.close();
      await service.stop();
    } else {
      print('disconnected');
    }
  });
}
