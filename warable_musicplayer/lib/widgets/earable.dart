import 'dart:async';

import 'package:esense_flutter/esense.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';

class EarableControler extends StatefulWidget{


  const EarableControler({Key? key, required this.onNod, required this.onLeft, required this.onRight}) : super(key: key);
  final void Function() onNod;
  final void Function() onLeft;
  final void Function() onRight;
  @override
  State<StatefulWidget> createState() => EarableControlerState();
}
class EarableControlerState extends State<EarableControler> {
  // create an ESenseManager by specifying the name of the device
  ESenseManager eSenseManager = ESenseManager('eSense-0390');
  late String deviceName = '';
  @override
  void initState(){
    super.initState();
    // first listen to connection events before trying to connect
    eSenseManager.connectionEvents.listen((event) {
      print(Permission.bluetoothConnect.status.toString());
      print('CONNECTION event: $event');
      Timer(Duration(seconds: 2), () async =>  print('Connected?: '+(eSenseManager.connected).toString()));
      ;
    });
    eSenseManager.setSamplingRate(5);
    if(eSenseManager.connected){
      StreamSubscription subscription = eSenseManager.sensorEvents.listen((event) {
        print('SENSOR event: $event');
      });

      // set up a event listener
      eSenseManager.eSenseEvents.listen((event) {
        print('ESENSE event: $event');
      });
      //Timer(Duration(seconds: 2), () async => await eSenseManager.getDeviceName());
      // now invoke read operations on the manager
      eSenseManager.getDeviceName();
    }

  }

  void  connect() async{
    // try to connect to the eSense device
    bool connecting = await eSenseManager.connect();
  }



  @override
  Widget build(BuildContext context) {
    return Row(
        mainAxisAlignment: MainAxisAlignment.center,
      children: [
        CircleAvatar(
          radius: 20,
          child: IconButton(
            icon: Icon(
              Icons.headphones
            ),
            iconSize: 25,
            onPressed: () async{
              connect();
            },
          )
        ),
    const SizedBox(width: 5),
    Text(
    'Connected device: '+deviceName,
    style: TextStyle(fontSize: 20),
    ),
      ],
    );
  }

}
