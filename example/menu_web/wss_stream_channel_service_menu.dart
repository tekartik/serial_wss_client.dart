import 'package:tekartik_common_utils/list_utils.dart';
import 'package:tekartik_serial_wss_client/channel/client/web_socket_channel.dart';
import 'package:tekartik_serial_wss_client/serial_wss_client.dart';
import 'package:tekartik_serial_wss_client/service/serial_stream_channel_service.dart';
import 'package:tekartik_serial_wss_client/service/serial_wss_client_service.dart';
import 'package:tekartik_test_menu_browser/test_menu_mdl_browser.dart';

wssStreamChannelServiceMenu(
    WebSocketClientChannelFactory clientChannelFactory) {
  String path;

  // ignore: deprecated_member_use
  Serial.debug.on = true;
  // ignore: deprecated_member_use
  SerialWssClientService.debug.on = true;
  // ignore: deprecated_member_use
  SerialStreamChannelService.debug.on = true;
  SerialWssClientService wssClientService = new SerialWssClientService(
      clientChannelFactory); //, url: serialWssUrlDefault);
  SerialStreamChannelService service =
      new SerialStreamChannelService(wssClientService);

  wssClientService.onConnected.listen((bool connected) async {
    write("connected $connected");
    if (connected) {
      List<DeviceInfo> deviceInfos = await wssClientService.serial.getDevices();
      write(deviceInfos);
      if (path == null) {
        path = listFirst(deviceInfos)?.path;
        await service.changeConnection(path);
      }
    }
  });

  service.onOpened.listen((bool opened) {
    write("opened  $opened");
  });

  item("wss client service start", () {
    wssClientService.start();
  });

  item("wss client service stop", () {
    wssClientService.stop();
  });

  item("select path", () async {
    path = await prompt("path");
    await service.changeConnection(path);
  });

  item("service start", () {
    service.start();
  });

  item("service stop", () {
    service.stop();
  });

  item("start all services", () {
    wssClientService.start();
    service.start();
  });
}
