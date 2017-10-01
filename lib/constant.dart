const int serialWssPortDefault = 8988;

const String _localhost = "127.0.0.1";
String getSerialWssUrl({int port}) {
  port ??= serialWssPortDefault;
  return "ws://${_localhost}:${port}";
}

const String serialWssUrlDefault = "ws://${_localhost}:${serialWssPortDefault}";

const String serialWssSimMasterPortPath = "_master";
const String serialWssSimSlavePortPath = "_slave";

const errorCodeInvalidPath = 1;
const errorCodePortBusy = 2;
const errorCodeNotConnected = 3;
const errorCodeInvalidId = 4;
const errorCodeMethodNotSupported = 5;

const dataBitsEight = "eight";
const dataBitsSeven = "seven";
const parityBitNo = "no";
const parityBitOdd = "odd";
const parityBitEven = "even";
const stopBitsOne = "one";
const stopBitsTwo = "two";

const int bitRate115200 = 115200;
const int bitRate57600 = 57600;
const int bitRate38400 = 38400;
const int bitRate19200 = 19200;
const int bitRate14400 = 14400;
const int bitRate9600 = 9600;
const int bitRate4800 = 4800;
const int bitRate2400 = 2400;
const int bitRate1200 = 1200;
const int bitRate300 = 300;
const int bitRate110 = 110;

const String serialWssPackagePrefix = 'com.tekartik.serial_wss';
