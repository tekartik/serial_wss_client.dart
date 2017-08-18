const int serialWssPortDefault = 8988;

String getSerialWssUrl({int port}) {
  port ??= serialWssPortDefault;
  return "ws://localhost:${port}";
}

const String serialWssUrlDefault = "ws://localhost:${serialWssPortDefault}";

const String serialWssSimMasterPortPath = "_master";
const String serialWssSimSlavePortPath = "_slave";

const errorCodeInvalidPath = 1;
const errorCodePortBusy = 2;
const errorCodeNotConnected = 3;
const errorCodeInvalidId = 4;
const errorCodeMethodNotSupported = 5;
