const int serialWssPortDefault = 8988;

String getSerialWssUrl({int port}) {
  port ??= serialWssPortDefault;
  return "ws://localhost:${port}";
}

const String serialWssUrlDefault = "ws://localhost:${serialWssPortDefault}";

const String serialWssSimMasterPortPath = "_master";
const String serialWssSimSlavePortPath = "_slave";
