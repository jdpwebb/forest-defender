import 'package:flutter/widgets.dart';
import 'package:flutter/material.dart';

class DevicesPage extends StatelessWidget {
  final Future<List<Map<String, dynamic>>> devicesList;
  final Function updateDevicesCB;
  const DevicesPage({
    @required this.updateDevicesCB,
    @required this.devicesList,
  });

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<Map<String, dynamic>>>(
      future: this.devicesList,
      builder: (BuildContext context,
          AsyncSnapshot<List<Map<String, dynamic>>> snapshot) {
        var devicesWidgetList = <Widget>[];
        Widget devices;

        switch (snapshot.connectionState) {
          case ConnectionState.none:
          case ConnectionState.active:
          case ConnectionState.waiting:
            devices = Text("Loading...");
            break;
          case ConnectionState.done:
            if (snapshot.hasError) {
              devices = Text("Error retrieving data.");
            } else {
              devices = Text("No devices found");
              for (var device in snapshot.data) {
                bool isConnected = device["connectionState"] == "Connected";
                String deviceID = device["deviceId"];
                devicesWidgetList.add(
                  DeviceItem(
                    deviceID: deviceID.substring(deviceID.length - 30),
                    icon: Icon(Icons.offline_bolt,
                        color: isConnected
                            ? Theme.of(context).accentIconTheme.color
                            : Theme.of(context).disabledColor),
                  ),
                );
              }

              if (devicesWidgetList.isNotEmpty) {
                devices = ListView(
                  itemExtent: 63,
                  children: devicesWidgetList,
                );
              }
            }
        }
        return Column(
          children: <Widget>[
            Expanded(
              child: Container(
                margin: EdgeInsets.symmetric(
                  horizontal: 42,
                  vertical: 30,
                ),
                padding: EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 10,
                ),
                decoration: BoxDecoration(
                    border: Border.all(),
                    borderRadius: BorderRadius.circular(5.0)),
                alignment: Alignment.center,
                child: devices,
              ),
            ),
            RaisedButton(
              child: Text("Refresh Devices"),
              onPressed:
                  devicesWidgetList.isEmpty ? null : this.updateDevicesCB,
            ),
            SizedBox(height: 50),
          ],
        );
      },
    );
  }
}

class DeviceItem extends StatelessWidget {
  final String deviceID;
  final Icon icon;
  DeviceItem({
    this.icon,
    @required this.deviceID,
  });
  @override
  Widget build(BuildContext context) {
    return Card(
      color: Theme.of(context).cardColor,
      margin: EdgeInsets.symmetric(vertical: 6),
      child: Center(
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            if (icon != null)
              Padding(
                padding: EdgeInsets.only(right: 12),
                child: icon,
              ),
            Text(deviceID, style: Theme.of(context).textTheme.subhead),
          ],
        ),
      ),
    );
  }
}
