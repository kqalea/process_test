import 'dart:io';
import 'dart:isolate';

import 'package:process_test/process_test.dart' as process_test;

Future createIsolate() async {
  void isolateFunction(SendPort mainSendPort) async {
    ReceivePort childReceivePort = ReceivePort();
    mainSendPort.send(childReceivePort.sendPort);
    var mList = List<String>.filled(0, "", growable: true);
    await for (var message in childReceivePort) {
      mList.add(message[0]);
      mList.add(message[1]);
      SendPort replyPort = message[2];
      var process = await Process.run(mList[0], [mList[1]]);
      replyPort.send(process.toString());
    }
  }

  ReceivePort receivePort = ReceivePort();
  Isolate.spawn(isolateFunction, receivePort.sendPort);
  SendPort childSendPort = await receivePort.first;

  ReceivePort responsePort = ReceivePort();
  childSendPort.send([
    "c:\\Users\\kqale\\Downloads\\ffmpeg-4.4.1-full_build\\bin\\ffplay.exe",
    "c:\\Users\\kqale\\Downloads\\pro1.1644922280051.flv",
    responsePort.sendPort
  ]);

  var response = await responsePort.first;
  print(response);
}

void main(List<String> arguments) async {
  print('Hello world: ${process_test.calculate()}!');
  createIsolate();
  print('Hello world: ${process_test.calculate()}!');
  createIsolate();
}
