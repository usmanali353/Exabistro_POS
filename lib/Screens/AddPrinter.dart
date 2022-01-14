import 'dart:io';
import 'package:exabistro_pos/Screens/AddPrinterDialog.dart';
import 'package:exabistro_pos/Utils/Utils.dart';
import 'package:flutter_bluetooth_basic/flutter_bluetooth_basic.dart';
import 'package:esc_pos_bluetooth/esc_pos_bluetooth.dart';
import 'package:exabistro_pos/components/constants.dart';
import 'package:flutter/material.dart';
import 'package:simple_speed_dial/simple_speed_dial.dart';


class AddPrinter extends StatefulWidget {

  @override
  _AddPrinterState createState() => _AddPrinterState();
}

class _AddPrinterState extends State<AddPrinter> with SingleTickerProviderStateMixin{
  PrinterBluetoothManager printerManager = PrinterBluetoothManager();
  List<PrinterBluetooth> printer=[];
  BluetoothManager bluetoothManager = BluetoothManager.instance;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
       appBar: AppBar(
          automaticallyImplyLeading: false,
          title: Text(
            'Printers',
            style: TextStyle(
                color: yellowColor,
                fontWeight: FontWeight.bold,
                fontSize: 30),
          ),
          centerTitle: true,
          backgroundColor: BackgroundColor,
        ),
      floatingActionButton: SpeedDial(
        child: const Icon(Icons.add),
        speedDialChildren: <SpeedDialChild>[
          SpeedDialChild(
            child: const Icon(Icons.usb),
            foregroundColor: Colors.white,
            backgroundColor: Colors.red,
            label: 'Add USB Printer',
            onPressed: () {

            },
          ),
          SpeedDialChild(
            child: const Icon(Icons.bluetooth),
            foregroundColor: Colors.white,
            backgroundColor: Colors.blue,
            label: 'Add Bluetooth Printer',
            onPressed: () {
              if (Platform.isAndroid) {
                bluetoothManager.state.listen((val) {
                  print('state = $val');
                  if (!mounted) return;
                  if (val == 12) {
                    print('on');

                    showDialog(
                        context: context,
                        builder: (context){
                          return Dialog(
                            backgroundColor: Colors.transparent,
                            child: Container(
                              width: 300,
                              height: 400,
                              child: AddPrinterDialog("Bluetooth"),
                            ),
                          );
                        }
                    );
                  } else if (val == 10) {
                    Utils.showError(context,"BlueTooth is Off Turn it On");
                  }
                });
              } else {
                printerManager.startScan(Duration(seconds: 2));
                printerManager.scanResults.listen((printers) {
                  setState(() {
                    this.printer=printers;
                  });
                });
              }
            },
          ),
          SpeedDialChild(
            child: const Icon(Icons.wifi),
            foregroundColor: Colors.white,
            backgroundColor: Colors.green,
            label: 'Add WIFI Printer',
            onPressed: () {

            },
          ),
        ],
        closedForegroundColor: Colors.white,
        openForegroundColor: Colors.white,
        closedBackgroundColor: yellowColor,
        openBackgroundColor: blueColor,
      ),
      body: Container(
        height: MediaQuery.of(context).size.height,
       width: MediaQuery.of(context).size.width,
       decoration: BoxDecoration(
       image: DecorationImage(
       fit: BoxFit.cover,
    //colorFilter: new ColorFilter.mode(Colors.white.withOpacity(0.7), BlendMode.dstATop),
       image: AssetImage('assets/bb.jpg'),
      ),
    ),
     // child: ,
      )
    );
  }

}
