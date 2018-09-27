import 'package:tekartik_web_socket/web_socket.dart';
import 'package:tekartik_serial_wss_client/service/serial_wss_client_service.dart';
import 'package:tekartik_test_menu_browser/test_menu_mdl_browser.dart';

wssClientServiceMenu(WebSocketChannelClientFactory clientChannelFactory) {
  // ignore: deprecated_member_use
  SerialWssClientService.debug.on = true;
  SerialWssClientService service = new SerialWssClientService(
      clientChannelFactory); //, url: serialWssUrlDefault);

  service.onConnected.listen((bool connected) {
    write("connected $connected");
  });
  item("start", () {
    service.start();
  });

  item("stop", () {
    service.stop();
  });
}
