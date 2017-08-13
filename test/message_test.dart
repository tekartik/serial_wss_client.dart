import 'package:dev_test/test.dart';
import 'package:tekartik_serial_wss_client/message.dart';
import 'dart:core' hide Error;

main() {
  group('message', () {
    group('create', () {
      test('request', () {
        Request request = new Request(1, "test", ["value"]);
        expect(request.toMap(), {
          "jsonrpc": "2.0",
          "id": 1,
          "method": "test",
          "params": ["value"]
        });

        request = new Request(1, "test");
        expect(request.toMap(), {"jsonrpc": "2.0", "id": 1, "method": "test"});
      });

      test('notification', () {
        Notification notification = new Notification("test", ["value"]);
        expect(notification.toMap(), {
          "jsonrpc": "2.0",
          "method": "test",
          "params": ["value"]
        });
        notification = new Notification("test");
        expect(notification.toMap(), {"jsonrpc": "2.0", "method": "test"});
      });

      test('response', () {
        Response response = new Response(1, ["value"]);
        expect(response.toMap(), {
          "jsonrpc": "2.0",
          "id": 1,
          "result": ["value"]
        });
        response = new Response(1, null);
        expect(response.toMap(), {"jsonrpc": "2.0", "id": 1, "result": null});
      });

      test('response_error', () {
        ErrorResponse response =
            new ErrorResponse(1, new Error(2, "msg", "err_data"));
        expect(response.toMap(), {
          "jsonrpc": "2.0",
          "id": 1,
          "error": {"code": 2, "message": "msg", "data": "err_data"}
        });
        response = new ErrorResponse(1, new Error(2, "msg"));
        expect(response.toMap(), {
          "jsonrpc": "2.0",
          "id": 1,
          "error": {"code": 2, "message": "msg"}
        });
      });
    });
    group('parse', () {
      test('request', () {
        Request request = Message.parseMap({
          "jsonrpc": "2.0",
          "id": 1,
          "method": "test",
          "params": ["value"]
        });

        expect(request.id, 1);
        expect(request.method, "test");
        expect(request.params, ["value"]);
      });
      test('notification', () {
        Notification notification = Message.parseMap({
          "jsonrpc": "2.0",
          "method": "test",
          "params": ["value"]
        });

        expect(notification.method, "test");
        expect(notification.params, ["value"]);
      });
      test('response', () {
        Response response = Message.parseMap({
          "jsonrpc": "2.0",
          "id": 1,
          "result": ["value"]
        });

        expect(response.id, 1);
        expect(response.result, ["value"]);
      });
      test('error_response', () {
        ErrorResponse response = Message.parseMap({
          "jsonrpc": "2.0",
          "id": 1,
          "error": {"code": 2, "message": "msg", "data": "err_data"}
        });

        expect(response.id, 1);
        expect(response.error.code, 2);
        expect(response.error.message, "msg");
        expect(response.error.data, "err_data");
      });
    });
  });
}
