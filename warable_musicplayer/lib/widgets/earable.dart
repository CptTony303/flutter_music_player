import 'dart:async';
import 'dart:io';

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
  String _deviceName = 'Unknown';
  double _voltage = -1;
  String _deviceStatus = '';
  bool sampling = false;
  String _event = '';
  String _button = 'not pressed';
  bool connected = false;
  bool breaked = false;

  ESenseConfig? conf;

  // create an ESenseManager by specifying the name of the device
  static const String eSenseDeviceName = 'eSense-0390';
  ESenseManager eSenseManager = ESenseManager(eSenseDeviceName);
  @override
  void initState() {
    super.initState();
    _listenToESense();
  }
  Future<void> _askForPermissions() async {
    if (!(await Permission.bluetooth.request().isGranted)) {
      print(
          'WARNING - no permission to use Bluetooth granted. Cannot access eSense device.');
    }
    if (!(await Permission.locationWhenInUse.request().isGranted)) {
      print(
          'WARNING - no permission to access location granted. Cannot access eSense device.');
    }
  }

  Future<void> _listenToESense() async {
    // for some strange reason, Android requires permission to location for the eSense to work????
    if (Platform.isAndroid) await _askForPermissions();

    // if you want to get the connection events when connecting,
    // set up the listener BEFORE connecting...
    eSenseManager.connectionEvents.listen((event) {
      print('CONNECTION event: $event');

      // when we're connected to the eSense device, we can start listening to events from it
      //if (event.type == ConnectionType.connected) _listenToESenseEvents();

      setState(() {
        connected = false;
        switch (event.type) {
          case ConnectionType.connected:
            _deviceStatus = 'connected';
            connected = true;
            _startListenToSensorEvents();
            //_listenToESenseEvents();
            break;
          case ConnectionType.unknown:
            _deviceStatus = 'unknown';
            break;
          case ConnectionType.disconnected:
            _deviceStatus = 'disconnected';
            break;
          case ConnectionType.device_found:
            _deviceStatus = 'device_found';
            break;
          case ConnectionType.device_not_found:
            _deviceStatus = 'device_not_found';
            break;
        }
      });
    });
  }

  Future<void> _connectToESense() async {
    if (!connected) {
      print('connecting...');
      connected = await eSenseManager.connect();

      setState(() {
        _deviceStatus = connected ? 'connecting...' : 'connection failed';
      });
    }
  }

  void _listenToESenseEvents() async {
    eSenseManager.eSenseEvents.listen((event) {
      print('ESENSE event: $event');

      setState(() {
        switch (event.runtimeType) {
          case DeviceNameRead:
            _deviceName = (event as DeviceNameRead).deviceName ?? 'Unknown';
            break;
          case BatteryRead:
            _voltage = (event as BatteryRead).voltage ?? -1;
            break;
          case ButtonEventChanged:
            break;
          case AccelerometerOffsetRead:
            // TODO
            break;
          case AdvertisementAndConnectionIntervalRead:
          // TODO
            break;
          case SensorConfigRead:
            conf = (event as SensorConfigRead).config;
            print(conf.toString());
            break;
        }
      });
    });
  }

  void _getESenseProperties() async {
    // get the battery level every 10 secs
    Timer(
      const Duration(seconds: 1),
          () async =>
      (connected) ? await eSenseManager.getBatteryVoltage() : null,
    );

    // wait 2, 3, 4, 5, ... secs before getting the name, offset, etc.
    // it seems like the eSense BTLE interface does NOT like to get called
    // several times in a row -- hence, delays are added in the following calls
    Timer(const Duration(seconds: 2),
            () async => await eSenseManager.getDeviceName());
    Timer(const Duration(seconds: 3),
            () async => await eSenseManager.getAccelerometerOffset());
    Timer(
        const Duration(seconds: 4),
            () async =>
        await eSenseManager.getAdvertisementAndConnectionInterval());
    Timer(const Duration(seconds: 5),
            () async => await eSenseManager.getSensorConfig());
  }

  StreamSubscription? subscription;
  void _startListenToSensorEvents() async {

    // any changes to the sampling frequency.l must be done BEFORE listening to sensor events
    //_pauseListenToSensorEvents();
    print('setting sampling frequency...');
    await eSenseManager.setSamplingRate(75);

    // subscribe to sensor event from the eSense device

    print('start listening to sensor events');
    subscription = eSenseManager.sensorEvents.listen((event) {
      //print('SENSOR event: $event');
      /*print('Accel:');
      print('y: '+((event.accel![0] / 8192 )).toString());
      print('x: '+((event.accel![1] / 8192 )).toString());
      print('z: '+((event.accel![2] / 8192 )).toString());*/


      /*print('Gyro roll: '+((event.gyro![0] / 65.5 )).toString()
          +'| pitch: '+((event.gyro![1] / 65.5 )).toString()
          + '| yar: '+((event.gyro![2] / 65.5 )).toString()
      );*/
      double scaleFactor = 65.5;
      double gyro_x = event.gyro![0]/scaleFactor; //left <-> right
      double gyro_y = event.gyro![1]/scaleFactor; // tilt
      double gyro_z = event.gyro![2]/scaleFactor; //up <-> down
      checkNodDir(gyro_x, gyro_y, gyro_z);
      setState(() {
        _event = event.toString();
      });
    });

    setState(() {
      sampling = true;
    });
    //subscription?.resume();
  }

  void checkNodDir(double x, double y, double z){
    if(breaked) return;
    if(z > 200 || z < -200) {
      print('detected Nod');
      widget.onNod();
      _inputBreak();
    }
      if(x > 250) {
        print('detected Right');
        widget.onRight();
        _inputBreak();
      }
      if(x < -250) {
        print('detected Left');
        widget.onLeft();
        _inputBreak();
      }
    }
    void _inputBreak(){
      breaked = true;
      Timer(const Duration(seconds: 2),
              () async =>  breaked = false);
    }

  void _pauseListenToSensorEvents() async {
    subscription?.cancel();
    setState(() {
      sampling = false;
    });
  }

  @override
  void dispose() {
    print('dispose');
    _pauseListenToSensorEvents();
    eSenseManager.disconnect();
    super.dispose();
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
              _connectToESense();
            },
          )
        ),
    const SizedBox(width: 5),
    Text(
    'Connected device: '+_deviceName,
    style: TextStyle(fontSize: 20),
    ),
      ],
    );
  }

}
