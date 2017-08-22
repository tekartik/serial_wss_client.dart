import 'package:tekartik_serial_wss_client/channel/client/io.dart';
import 'package:tekartik_serial_wss_client/serial_wss_client.dart';
import 'package:tekartik_serial_wss_client/service/serial_wss_client_service.dart';

main() async {
  SerialWssClientService service =
      new SerialWssClientService(ioWebSocketClientChannelFactory);
  service.start();

  service.onConnected.listen((bool connected) async {
    if (connected) {
      print("connected");

      List<DeviceInfo> deviceInfos = await service.serial.getDevices();

      print(deviceInfos);
      DeviceInfo deviceInfo = deviceInfos.first;
      SerialStreamChannel serialStreamChannel =
          await service.serial.createChannel(deviceInfo.path);

      serialStreamChannel.sink.add("hello\r".codeUnits);

      serialStreamChannel.stream.listen((List<int> data) {
        print('received ${data}');
      });

      await serialStreamChannel.close();
      await service.stop();
    } else {
      print("disconnected");
    }
  });
}
