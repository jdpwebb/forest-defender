import 'dart:async';

import 'package:flutter/material.dart';
import 'package:forest_defender_app/azure_iot_hub.dart';
import 'test_page.dart';
import 'devices_page.dart';
import 'config_page.dart';

const String sharedAccessKey = "XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX";
const String iotHubEndpoint = "Daedalus.azure-devices.net";

void main() => runApp(AppMain());

class AppMain extends StatelessWidget {
  // This widget is the root of the application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Forest Defender',
      theme: ThemeData(
        primarySwatch: Colors.teal,
        cardColor: Colors.teal[50],
        accentIconTheme: IconThemeData(color: Colors.lightGreen),
        textTheme: TextTheme(
          body1: TextStyle(fontSize: 16.7, height: 1.7),
          subhead: TextStyle(fontSize: 18.5, fontWeight: FontWeight.w500),
          button: TextStyle(fontSize: 17.7),
        ),
        buttonTheme: ButtonThemeData(
          height: 50,
          minWidth: 175,
        ),
      ),
      home: AppConfig(
        child: MainPage(),
      ),
    );
  }
}

class AppConfig extends StatefulWidget {
  AppConfig({
    Key key,
    this.child,
  }) : super(key: key);

  final Widget child;

  @override
  AppConfigState createState() => AppConfigState();

  static AppConfigState of(BuildContext context) {
    return (context.inheritFromWidgetOfExactType(_InheritedConfig)
            as _InheritedConfig)
        .data;
  }
}

class AppConfigState extends State<AppConfig> {
  DateTime _lastUpdateTime;

  DateTime get lastUpdateTime => _lastUpdateTime;

  void updateLastUpdateTime() {
    _lastUpdateTime = DateTime.now();
  }

  @override
  Widget build(BuildContext context) {
    return _InheritedConfig(
      data: this,
      child: widget.child,
    );
  }
}

class _InheritedConfig extends InheritedWidget {
  static _InheritedConfig of(BuildContext context) =>
      context.inheritFromWidgetOfExactType(_InheritedConfig);

  _InheritedConfig({Key key, Widget child, this.data})
      : super(key: key, child: child);

  final AppConfigState data;

  @override
  bool updateShouldNotify(_InheritedConfig oldWidget) {
    return oldWidget.data.lastUpdateTime != this.data.lastUpdateTime;
  }
}

typedef void UpdateTwinCB(Map<String, dynamic> update);

class MainPage extends StatefulWidget {
  MainPage({Key key}) : super(key: key);

  @override
  _MainPageState createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  static const pageNames = const ["Devices", "Test", "Configure"];
  int _tabIndex;
  AzureIoTHub iotHub = AzureIoTHub(
    iotHubEndpoint: iotHubEndpoint,
    sharedAccessKey: sharedAccessKey,
    policy: "iothubowner",
  );
  static Future<List<Map<String, dynamic>>> devicesList;

  @override
  void initState() {
    super.initState();
    _tabIndex = 1; // Show control page by default
    _updateDevicesList();
  }

  @override
  Widget build(BuildContext context) {
    Widget page;
    switch (_tabIndex) {
      case 0:
        page = DevicesPage(
          devicesList: devicesList,
          updateDevicesCB: _updateDevicesList,
        );
        break;
      case 1:
        page = TestPage(
          devicesList: devicesList,
          iotHub: iotHub,
        );
        break;
      case 2:
        page = ConfigPage(
          devicesList: devicesList,
          iotHub: iotHub,
        );
        break;
    }
    return Scaffold(
      appBar: AppBar(
        title: Text(pageNames[_tabIndex]),
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.bottomRight,
            end: Alignment.topLeft,
            stops: [0.08, 0.75],
            colors: [
              Colors.lightGreen[200].withOpacity(0.3),
              Colors.white,
            ],
          ),
        ),
        child: Center(
          child: page,
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        iconSize: 30.0,
        unselectedFontSize: 13.5,
        selectedFontSize: 14.5,
        currentIndex: _tabIndex,
        onTap: _onTabTapped,
        items: <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.devices),
            title: Text(pageNames[0]),
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.description),
            title: Text(pageNames[1]),
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.settings),
            title: Text(pageNames[2]),
          ),
        ],
      ),
    );
  }

  void _onTabTapped(int index) {
    setState(() {
      _tabIndex = index;
    });
  }

  void _updateDevicesList() {
    devicesList = iotHub.retrieveDevicesList().then((data) {
      print("Received devices list");
      // add the time that the future completed to the app state
      AppConfig.of(context).updateLastUpdateTime();
      return data;
    }).catchError((e) {
      Scaffold.of(context).showSnackBar(SnackBar(content: Text(e.toString())));
      print("error communicating with hub");
    });
  }
}
