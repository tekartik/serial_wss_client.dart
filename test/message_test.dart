import 'dart:core' hide Error;

import 'package:dev_test/test.dart';
import 'package:tekartik_serial_wss_client/message.dart';

void main() {
  group('message', () {
    group('create', () {
      test('request', () {
        var request = Request(1, 'test', ['value']);
        expect(request.toMap(), {
          'jsonrpc': '2.0',
          'id': 1,
          'method': 'test',
          'params': ['value']
        });

        request = Request(1, 'test');
        expect(request.toMap(), {'jsonrpc': '2.0', 'id': 1, 'method': 'test'});
      });

      test('notification', () {
        var notification = Notification('test', ['value']);
        expect(notification.toMap(), {
          'jsonrpc': '2.0',
          'method': 'test',
          'params': ['value']
        });
        notification = Notification('test');
        expect(notification.toMap(), {'jsonrpc': '2.0', 'method': 'test'});
      });

      test('response', () {
        var response = Response(1, ['value']);
        expect(response.toMap(), {
          'jsonrpc': '2.0',
          'id': 1,
          'result': ['value']
        });
        response = Response(1, null);
        expect(response.toMap(), {'jsonrpc': '2.0', 'id': 1, 'result': null});
      });

      test('response_error', () {
        var response = ErrorResponse(1, Error(2, 'msg', 'err_data'));
        expect(response.toMap(), {
          'jsonrpc': '2.0',
          'id': 1,
          'error': {'code': 2, 'message': 'msg', 'data': 'err_data'}
        });
        response = ErrorResponse(1, Error(2, 'msg'));
        expect(response.toMap(), {
          'jsonrpc': '2.0',
          'id': 1,
          'error': {'code': 2, 'message': 'msg'}
        });
      });
    });
    group('parse', () {
      test('request', () {
        final request = Message.parseMap({
          'jsonrpc': '2.0',
          'id': 1,
          'method': 'test',
          'params': ['value']
        }) as Request;

        expect(request.id, 1);
        expect(request.method, 'test');
        expect(request.params, ['value']);
      });
      test('notification', () {
        final notification = Message.parseMap({
          'jsonrpc': '2.0',
          'method': 'test',
          'params': ['value']
        }) as Notification;

        expect(notification.method, 'test');
        expect(notification.params, ['value']);
      });
      test('response', () {
        final response = Message.parseMap({
          'jsonrpc': '2.0',
          'id': 1,
          'result': ['value']
        }) as Response;

        expect(response.id, 1);
        expect(response.result, ['value']);
      });
      test('error_response', () {
        final response = Message.parseMap({
          'jsonrpc': '2.0',
          'id': 1,
          'error': {'code': 2, 'message': 'msg', 'data': 'err_data'}
        }) as ErrorResponse;

        expect(response.id, 1);
        expect(response.error.code, 2);
        expect(response.error.message, 'msg');
        expect(response.error.data, 'err_data');
      });
    });
  });
}
