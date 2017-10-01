import 'package:tekartik_common_utils/hex_utils.dart';

const methodInit = 'init'; // request optional params are name (client name)

const methodGetDevices = 'getDevices'; // request
const methodConnect = 'connect'; // request
const methodDisconnect = 'disconnect'; // request
const methodSend = 'send'; // request
const methodFlush = 'flush'; // request

const methodReceive = 'recv'; // notification
const methodError = 'error'; // notification
const methodDisconnected = 'disconnected'; // notification

const methodInfo = 'info'; // from server upon connection, notification

abstract class Message {
  Map<String, dynamic> toMap() {
    return {"jsonrpc": "2.0"};
  }

  // throw or return valid value
  static Message parseMap(Map<String, dynamic> map) {
    if (map['jsonrpc'] != "2.0") {
      throw new FormatException("missing 'jsonrpc=2.0' in $map");
    }

    if (map.containsKey('id')) {
      var id = map['id'];
      if (map['method'] == null) {
        // response
        if (map.containsKey('result')) {
          return new Response(id, map['result']);
        } else {
          Map errorMap = map['error'];
          if (errorMap == null) {
            throw new FormatException(
                "missing 'method', 'result' or 'error' in $map");
          }
          return new ErrorResponse(
              id,
              new Error(
                  errorMap['code'], errorMap['message'], errorMap['data']));
        }
      } else {
        return new Request(id, map['method'], map['params']);
      }
    } else {
      // notification
      if (map['method'] == null) {
        throw new FormatException("missing 'method' or 'id' in $map");
      }
      return new Notification(map['method'], map['params']);
    }
  }
}

abstract class _MessageWithId extends Message {
  final id;
  _MessageWithId(this.id);

  @override
  Map<String, dynamic> toMap() {
    var map = super.toMap();
    map['id'] = id;
    return map;
  }
}

class Notification extends Message with _RequestMixin {
  Notification(String method, [var params]) {
    _init(method, params);
  }

  @override
  Map<String, dynamic> toMap() {
    var map = super.toMap();
    _updateMap(map);
    return map;
  }
}

class _RequestMixin {
  var _params;
  String _method;
  get params => _params;
  String get method => _method;
  _init(String method, [var params]) {
    _method = method;
    _params = params;
  }

  _updateMap(Map map) {
    map['method'] = _method;
    if (_params != null) {
      map['params'] = _params;
    }
  }
}

class Request extends _MessageWithId with _RequestMixin {
  Request(id, String method, [var params]) : super(id) {
    _init(method, params);
  }

  @override
  Map<String, dynamic> toMap() {
    var map = super.toMap();
    _updateMap(map);
    return map;
  }
}

class DataRequest extends Request {
  int connectionId;
  List<int> data;
  DataRequest(id, String method, this.connectionId, this.data)
      : super(id, method) {
    _params = {"connectionId": connectionId, "data": toHexString(data)};
  }
}

class DataSendRequest extends DataRequest {
  DataSendRequest(id, int connectionId, List<int> data)
      : super(id, methodSend, connectionId, data);
}

class Response extends _MessageWithId {
  final result;
  Response(id, this.result) : super(id);

  @override
  Map<String, dynamic> toMap() {
    var map = super.toMap();
    map['result'] = result;
    return map;
  }
}

class Error {
  final int code;
  final String message;
  final data;

  Error(this.code, this.message, [this.data]);

  Map<String, dynamic> toMap() {
    var map = {"code": code, "message": message};
    if (data != null) {
      map['data'] = data;
    }
    return map;
  }

  // override
  String toString() {
    return "$code: $message${data != null ? " $data" : ""}";
  }
}

class ErrorResponse extends _MessageWithId {
  final Error error;
  ErrorResponse(id, this.error) : super(id);
  @override
  Map<String, dynamic> toMap() {
    var map = super.toMap();
    map['error'] = error.toMap();
    return map;
  }
}
