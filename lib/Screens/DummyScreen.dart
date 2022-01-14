import 'dart:async';
import 'dart:typed_data';
import 'package:exabistro_pos/Utils/Utils.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_usb_write/flutter_usb_write.dart';
import 'package:esc_pos_utils/esc_pos_utils.dart';
import 'package:intl/intl.dart';


class DummyScreen extends StatefulWidget {
  @override
  _DummyScreenState createState() => new _DummyScreenState();
}

class _DummyScreenState extends State<DummyScreen> {
  FlutterUsbWrite _flutterUsbWrite = FlutterUsbWrite();
  FUWEvent _lastEvent;
  StreamSubscription<FUWEvent> _usbStateSubscription;
  List<FUWDevice> _devices = [];
  int _connectedDeviceId;
  TextEditingController _textController =
  TextEditingController(text: "Hello world");
  final _scaffoldKey = GlobalKey<ScaffoldState>();
  bool didInit = false;

  @override
  void initState() {
    super.initState();
    createUsbListener();
  }

  @override
  Future didChangeDependencies() async {
    super.didChangeDependencies();
    if (!didInit) {
      didInit = true;
      await _getPorts();
    }
  }

  // Platform messages are asynchronous, so we initialize in an async method.
  Future<void> createUsbListener() async {
    // If the widget was removed from the tree while the asynchronous platform
    // message was in flight, we want to discard the reply rather than calling
    // setState to update our non-existent appearance.
    if (!mounted) return;

    setState(() {
      _usbStateSubscription =
          _flutterUsbWrite.usbEventStream.listen((FUWEvent event) async {
            setState(() {
              _lastEvent = event;
            });
            await _getPorts();
            if (event.event.endsWith("USB_DEVICE_DETACHED")) {
              //check if connected device was detached
              if (event.device.deviceId == _connectedDeviceId) {
                _disconnect();
              }
            }
          });
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        key: _scaffoldKey,
        appBar: AppBar(
          title: const Text('USB Device Example'),
        ),
        body: Center(
          child: Column(
            children: <Widget>[
              Padding(
                padding: const EdgeInsets.only(top: 15, bottom: 15),
                child: Text(
                    _devices.isNotEmpty
                        ? "Available USB Devices"
                        : "No USB devices available",
                    style: Theme.of(context).textTheme.subtitle1),
              ),
              ..._portList(),
              getInputTextBox(),
              Padding(
                padding: const EdgeInsets.only(top: 15, bottom: 15),
                child: getEventInfo(),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget getEventInfo() {
    if (_lastEvent == null) return SizedBox.shrink();
    if (_lastEvent.event.endsWith('USB_DEVICE_ATTACHED')) {
      return Text(
        _lastEvent.device.manufacturerName + ' ATTACHED',
        style: TextStyle(
          color: Colors.green,
          fontWeight: FontWeight.bold,
        ),
      );
    }
    return Text(
      _lastEvent.device.manufacturerName + ' DETACHED',
      style: TextStyle(
        color: Colors.red,
        fontWeight: FontWeight.bold,
      ),
    );
  }

  Widget getInputTextBox() {
    return Padding(
      padding: const EdgeInsets.only(top: 15, bottom: 15),
      child: ListTile(
        title: TextField(
          controller: _textController,
          decoration: InputDecoration(
            border: OutlineInputBorder(),
            labelText: 'Text To Send',
          ),
        ),
        trailing: RaisedButton(
          child: Text("Send"),
          onPressed: _connectedDeviceId == null
              ? null
              : () async {
            if (_connectedDeviceId == null) {
              return;
            }
            String data = _textController.text + "\r\n";
            const PaperSize paper = PaperSize.mm58;
            final profile = await CapabilityProfile.load();
            demoReceipt(paper, profile).then((value){

              _flutterUsbWrite.write(Uint8List.fromList(value)).then((value){
                Utils.showError(context,value.toString());
              });
            });

          },
        ),
      ),
    );
  }

  Future _getPorts() async {
    try {
      List<FUWDevice> devices = await _flutterUsbWrite.listDevices();
      setState(() {
        _devices = devices;
      });
    } on PlatformException catch (e) {
      showSnackBar(e.message);
      print(e.message);
    }
  }

  List<Widget> _portList() {
    List<Widget> ports = [];
    _devices.forEach((device) {
      ports.add(
        ListTile(
          leading: Icon(Icons.usb),
          title: Text(device.productName),
          subtitle: Text(device.manufacturerName),
          trailing: RaisedButton(
            child: Text(_connectedDeviceId == device.deviceId
                ? "Disconnect"
                : "Connect"),
            onPressed: () async {
              if (_connectedDeviceId == device.deviceId) {
                await _disconnect();
              } else {
                await _connect(device);
              }
            },
          ),
        ),
      );
    });
    if (ports.isEmpty) {
      ports.add(SizedBox.shrink());
    }
    return ports;
  }

  Future<FUWDevice> _connect(FUWDevice device) async {
    try {
      var result = await _flutterUsbWrite.open(
        vendorId: device.vid,
        productId: device.pid,
      );
      setState(() {
        _connectedDeviceId = result.deviceId;
      });
      return result;
    } on PermissionException {
      showSnackBar("Not allowed to do that");
      return null;
    } on PlatformException catch (e) {
      showSnackBar(e.message);
      return null;
    }
  }

  Future _disconnect() async {
    try {
      await _flutterUsbWrite.close();
      setState(() {
        _connectedDeviceId = null;
      });
    } on PlatformException catch (e) {
      showSnackBar(e.message);
    }
  }

  void showSnackBar(String message) {
    final snackBar = SnackBar(
      content: Text(message),
    );
    _scaffoldKey.currentState.showSnackBar(snackBar);
  }

  @override
  void dispose() {
    super.dispose();
    if (_usbStateSubscription != null) {
      _usbStateSubscription.cancel();
    }
  }
  Future<List<int>> demoReceipt(PaperSize paper, CapabilityProfile profile) async {
    final Generator ticket = Generator(paper, profile);
    List<int> bytes = [];

    // // Print image
    // final ByteData data = await rootBundle.load('assets/chineseSoup.jpg');
    // final Uint8List imageBytes = data.buffer.asUint8List();
    // final image = decodeImage(imageBytes);
    // bytes += ticket.image(image);

    bytes += ticket.text('ExaBistro',
        styles: PosStyles(
          align: PosAlign.center,
          height: PosTextSize.size2,
          width: PosTextSize.size2,
        ),
        linesAfter: 1);

    bytes += ticket.text('889  Watson Lane',
        styles: PosStyles(align: PosAlign.center));
    bytes += ticket.text('New Braunfels, TX',
        styles: PosStyles(align: PosAlign.center));
    bytes += ticket.text('Tel: 830-221-1234',
        styles: PosStyles(align: PosAlign.center));
    bytes += ticket.text('Web: www.example.com',
        styles: PosStyles(align: PosAlign.center), linesAfter: 1);

    bytes += ticket.hr();
    bytes += ticket.row([
      PosColumn(text: 'Qty', width: 1),
      PosColumn(text: 'Item', width: 7),
      PosColumn(
          text: 'Price', width: 2, styles: PosStyles(align: PosAlign.right)),
      PosColumn(
          text: 'Total', width: 2, styles: PosStyles(align: PosAlign.right)),
    ]);

    bytes += ticket.row([
      PosColumn(text: '2', width: 1),
      PosColumn(text: 'ONION RINGS', width: 7),
      PosColumn(
          text: '0.99', width: 2, styles: PosStyles(align: PosAlign.right)),
      PosColumn(
          text: '1.98', width: 2, styles: PosStyles(align: PosAlign.right)),
    ]);
    bytes += ticket.row([
      PosColumn(text: '1', width: 1),
      PosColumn(text: 'PIZZA', width: 7),
      PosColumn(
          text: '3.45', width: 2, styles: PosStyles(align: PosAlign.right)),
      PosColumn(
          text: '3.45', width: 2, styles: PosStyles(align: PosAlign.right)),
    ]);
    bytes += ticket.row([
      PosColumn(text: '1', width: 1),
      PosColumn(text: 'SPRING ROLLS', width: 7),
      PosColumn(
          text: '2.99', width: 2, styles: PosStyles(align: PosAlign.right)),
      PosColumn(
          text: '2.99', width: 2, styles: PosStyles(align: PosAlign.right)),
    ]);
    bytes += ticket.row([
      PosColumn(text: '3', width: 1),
      PosColumn(text: 'CRUNCHY STICKS', width: 7),
      PosColumn(
          text: '0.85', width: 2, styles: PosStyles(align: PosAlign.right)),
      PosColumn(
          text: '2.55', width: 2, styles: PosStyles(align: PosAlign.right)),
    ]);
    bytes += ticket.hr();

    bytes += ticket.row([
      PosColumn(
          text: 'TOTAL',
          width: 6,
          styles: PosStyles(
            height: PosTextSize.size2,
            width: PosTextSize.size2,
          )),
      PosColumn(
          text: '\$10.97',
          width: 6,
          styles: PosStyles(
            align: PosAlign.right,
            height: PosTextSize.size2,
            width: PosTextSize.size2,
          )),
    ]);

    bytes += ticket.hr(ch: '=', linesAfter: 1);

    bytes += ticket.row([
      PosColumn(
          text: 'Cash',
          width: 7,
          styles: PosStyles(align: PosAlign.right, width: PosTextSize.size2)),
      PosColumn(
          text: '\$15.00',
          width: 5,
          styles: PosStyles(align: PosAlign.right, width: PosTextSize.size2)),
    ]);
    bytes += ticket.row([
      PosColumn(
          text: 'Change',
          width: 7,
          styles: PosStyles(align: PosAlign.right, width: PosTextSize.size2)),
      PosColumn(
          text: '\$4.03',
          width: 5,
          styles: PosStyles(align: PosAlign.right, width: PosTextSize.size2)),
    ]);

    bytes += ticket.feed(2);
    bytes += ticket.text('Thank you!',
        styles: PosStyles(align: PosAlign.center, bold: true));

    final now = DateTime.now();
    final formatter = DateFormat('MM/dd/yyyy H:m');
    final String timestamp = formatter.format(now);
    bytes += ticket.text(timestamp,
        styles: PosStyles(align: PosAlign.center), linesAfter: 2);

    // Print QR Code from image
    // try {
    //   const String qrData = 'example.com';
    //   const double qrSize = 200;
    //   final uiImg = await QrPainter(
    //     data: qrData,
    //     version: QrVersions.auto,
    //     gapless: false,
    //   ).toImageData(qrSize);
    //   final dir = await getTemporaryDirectory();
    //   final pathName = '${dir.path}/qr_tmp.png';
    //   final qrFile = File(pathName);
    //   final imgFile = await qrFile.writeAsBytes(uiImg.buffer.asUint8List());
    //   final img = decodeImage(imgFile.readAsBytesSync());

    //   bytes += ticket.image(img);
    // } catch (e) {
    //   print(e);
    // }

    // Print QR Code using native function
    // bytes += ticket.qrcode('example.com');

    ticket.feed(2);
    ticket.cut();
    return bytes;
  }
}