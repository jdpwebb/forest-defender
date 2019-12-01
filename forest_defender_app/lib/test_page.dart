import 'package:forest_defender_app/azure_iot_hub.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class TestPage extends StatefulWidget {
  final Future<List> devicesList;
  final AzureIoTHub iotHub;
  TestPage({
    @required this.devicesList,
    @required this.iotHub,
  });

  @override
  State<TestPage> createState() => TestPageState();
}

class TestPageState extends State<TestPage> {
  String currentDevice;

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List>(
      future: widget.devicesList,
      builder: (BuildContext context, AsyncSnapshot<List> snapshot) {
        Color disabledColor = Theme.of(context).disabledColor;
        bool isConnected = false;
        bool isHealthy = false;
        Map<String, dynamic> devices = <String, dynamic>{};
        Widget connectionStatus;
        String connectionStatusTitle = "Device Connection Status";
        Widget healthStatus;
        String healthStatusTitle = "Device Health Status";
        String lastUpdateTitle = "Last Device Update";
        Widget lastUpdateTime;
        Widget testDescription = Text("Loading...");
        List<Widget> deviceData;
        switch (snapshot.connectionState) {
          case ConnectionState.none:
          case ConnectionState.active:
          case ConnectionState.waiting:
            connectionStatus = ControlItem(
              title: connectionStatusTitle,
              icon: Icon(Icons.offline_bolt,
                  color: isConnected
                      ? Theme.of(context).accentIconTheme.color
                      : Theme.of(context).disabledColor),
            );
            healthStatus = ControlItem(
              title: healthStatusTitle,
              icon: Icon(Icons.spa, color: disabledColor),
            );
            lastUpdateTime = ControlItem(title: lastUpdateTitle);

            deviceData = [
              connectionStatus,
              SizedBox(height: 25),
              healthStatus,
              SizedBox(height: 25),
              lastUpdateTime,
              SizedBox(height: 0.12 * MediaQuery.of(context).size.height),
              testDescription,
            ];
            break;
          case ConnectionState.done:
            if (snapshot.hasError) {
              connectionStatus = ControlItem(
                title: connectionStatusTitle,
                icon: Icon(Icons.offline_bolt, color: disabledColor),
                status: Text('Unknown'),
              );
              healthStatus = ControlItem(
                title: healthStatusTitle,
                icon: Icon(Icons.spa, color: disabledColor),
                status: Text('Unknown'),
              );
              lastUpdateTime = ControlItem(
                title: lastUpdateTitle,
                status: Text('Unknown'),
              );
              testDescription =
                  Text("Error retrieving device list info: ${snapshot.error}");

              deviceData = [
                connectionStatus,
                SizedBox(height: 25),
                healthStatus,
                SizedBox(height: 25),
                lastUpdateTime,
                SizedBox(height: 0.12 * MediaQuery.of(context).size.height),
                testDescription,
              ];
            } else if (snapshot.data.isNotEmpty) {
              devices = Map.fromIterable(snapshot.data,
                  key: (v) => v["deviceId"], value: (v) => v);
              currentDevice ??= snapshot.data[0]["deviceId"];
              var chosenDeviceData = devices[currentDevice];
              isConnected = true;
              bool isDeviceConnected =
                  chosenDeviceData["connectionState"] == "Connected";
              connectionStatus = ControlItem(
                title: connectionStatusTitle,
                icon: Icon(
                  Icons.offline_bolt,
                  color: isDeviceConnected ? Colors.green : Colors.red,
                ),
                status: Text(chosenDeviceData['connectionState']),
              );
              testDescription = FractionallySizedBox(
                widthFactor: 0.7,
                child: Text(
                  "Testing a device will simulate a fire event.",
                  textAlign: TextAlign.center,
                ),
              );
              String timeString = chosenDeviceData["lastActivityTime"];
              timeString = timeString.substring(0, timeString.length - 2);
              DateTime lastUpdate = DateTime.tryParse(timeString);
              var formatter = new DateFormat.jms().add_yMd();
              String lastUpdateStatus = lastUpdate == null
                  ? "Unknown"
                  : formatter.format(lastUpdate.toLocal());
              lastUpdateTime = ControlItem(
                  title: lastUpdateTitle, status: Text(lastUpdateStatus));
              isHealthy = lastUpdate
                  .isAfter(DateTime.now().subtract(Duration(days: 1)));
              healthStatus = ControlItem(
                title: healthStatusTitle,
                icon: Icon(
                  Icons.spa,
                  color: isHealthy ? Colors.green : Colors.red,
                ),
                status: Text(isHealthy ? 'Healthy' : 'Sick'),
              );
              deviceData = [
                connectionStatus,
                SizedBox(height: 25),
                healthStatus,
                SizedBox(height: 25),
                lastUpdateTime,
                SizedBox(height: 0.1 * MediaQuery.of(context).size.height),
                testDescription,
              ];
            } else {
              deviceData = [
                Center(
                  child: Text("No devices found"),
                ),
              ];
            }
        }

        return Container(
          padding: EdgeInsets.all(30),
          child: Column(
            children: <Widget>[
              DropdownButton<String>(
                value: currentDevice,
                icon: Icon(Icons.keyboard_arrow_down),
                iconSize: 24,
                elevation: 16,
                underline: Container(
                  height: 2,
                  color: Theme.of(context).accentColor,
                ),
                disabledHint: Text("Loading..."),
                onChanged: devices == null
                    ? null
                    : (String newValue) {
                        setState(() {
                          currentDevice = newValue;
                        });
                      },
                items:
                    devices.keys.map<DropdownMenuItem<String>>((String value) {
                  return DropdownMenuItem<String>(
                    value: value,
                    child: Text(value.substring(value.length - 30)),
                  );
                }).toList(),
              ),
              SizedBox(height: 30),
              ...deviceData,
              SizedBox(height: 35),
              RaisedButton(
                child: Text("Test Device"),
                onPressed:
                    !isConnected ? null : () => requestSimulation(context),
              ),
            ],
          ),
        );
      },
    );
  }

  void requestSimulation(BuildContext context) async {
    try {
      await widget.iotHub.callDirectMethod(
          deviceID: currentDevice, methodName: "simulateEvent");
    } catch (e) {
      Scaffold.of(context).showSnackBar(SnackBar(content: Text(e.toString())));
    }
  }
}

class ControlItem extends StatelessWidget {
  final String title;
  final Icon icon;
  final Widget status;
  ControlItem({
    this.title = "",
    this.icon,
    this.status = const Text("Loading..."),
  });
  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        Text(title, style: Theme.of(context).textTheme.subhead),
        SizedBox(height: 5),
        Row(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            if (icon != null)
              Padding(
                padding: EdgeInsets.only(right: 12),
                child: icon,
              ),
            status,
          ],
        ),
      ],
    );
  }
}
