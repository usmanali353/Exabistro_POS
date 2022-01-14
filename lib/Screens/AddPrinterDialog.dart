import 'package:esc_pos_bluetooth/esc_pos_bluetooth.dart';
import 'package:exabistro_pos/Utils/Utils.dart';
import 'package:exabistro_pos/components/constants.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bluetooth_basic/flutter_bluetooth_basic.dart';
import 'package:esc_pos_printer/esc_pos_printer.dart';

class AddPrinterDialog extends StatefulWidget {
 String printerType;

 AddPrinterDialog(this.printerType);

 @override
  _AddPrinterDialogState createState() => _AddPrinterDialogState();
}

class _AddPrinterDialogState extends State<AddPrinterDialog> {
  var allottedTo=["Cashier","Kitchen"];
  String selectedAllottedTo,selectedPrinterType;
  PrinterBluetoothManager printerManager = PrinterBluetoothManager();
  List<PrinterBluetooth> bluetoothPrinters=[];
  BluetoothManager bluetoothManager = BluetoothManager.instance;
  var selectedBluetoothPrinter;
  @override
  void initState() {
    if(widget.printerType=="Bluetooth"){
      printerManager.startScan(Duration(seconds: 2));
      printerManager.scanResults.listen((printers) {
        setState(() {
          this.bluetoothPrinters=printers;
        });
      });
    }

    super.initState();
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: 300,
        height: 400,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: DropdownButtonFormField<String>(
                decoration: InputDecoration(
                  labelText: "Printer Allotted to",
                  alignLabelWithHint: true,
                  labelStyle: TextStyle(fontWeight: FontWeight.bold,fontSize: 16, color:yellowColor),
                  enabledBorder: OutlineInputBorder(
                  ),
                  focusedBorder:  OutlineInputBorder(
                    borderSide: BorderSide(color:yellowColor),
                  ),
                ),

                value: selectedAllottedTo,
                onChanged: (Value) {

                },
                items: allottedTo.map((value) {
                  return  DropdownMenuItem<String>(
                    value: value,
                    child: Row(
                      children: <Widget>[
                        Text(
                          value,
                          style:  TextStyle(color: yellowColor,fontSize: 13),
                        ),
                        //user.icon,
                        //SizedBox(width: MediaQuery.of(context).size.width*0.71,),
                      ],
                    ),
                  );
                }).toList(),
              ),
            ),
            Expanded(
              child: ListView.builder(
                itemCount: bluetoothPrinters.length,
                  itemBuilder:(context,int index){
                  return Column(
                    children: [
                      RadioListTile(
                        title: Text(bluetoothPrinters[index].name),
                        subtitle: Text(bluetoothPrinters[index].address),
                        value: bluetoothPrinters[index],
                        groupValue: selectedBluetoothPrinter,
                        onChanged: (printer){
                          setState(() {
                            this.selectedBluetoothPrinter=printer;
                          });
                        },
                      ),
                      Divider()
                    ],
                  );
              }
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: MaterialButton(
                color: yellowColor,
                child: Center(child: Text("Add Printer",style: TextStyle(color: Colors.white),)),
                onPressed: (){
                  Utils.showError(context, selectedBluetoothPrinter["address"]);
                  print(selectedBluetoothPrinter["address"]);
                },
              ),
            )
          ],
        ),
      ),
    );
  }
}
