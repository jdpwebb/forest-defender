import 'dart:async';
import 'package:forest_defender_app/azure_iot_hub.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class ConfigPage extends StatefulWidget {
  final Future<List<Map<String, dynamic>>> devicesList;
  final AzureIoTHub iotHub;
  ConfigPage({
    @required this.devicesList,
    @required this.iotHub,
  });

  @override
  State<ConfigPage> createState() => ConfigPageState();
}

class ConfigPageState extends State<ConfigPage> {
  static const defaultDebounceTime = Duration(seconds: 5);
  Timer _debounceTimer;
  Map<String, dynamic> _propertyUpdates = <String, dynamic>{};
  List<Map<String, dynamic>> devices;

  @override
  Widget build(BuildContext context) {
    return Container(
      child: FutureBuilder<List<Map<String, dynamic>>>(
        future: widget.devicesList,
        builder: (BuildContext context,
            AsyncSnapshot<List<Map<String, dynamic>>> snapshot) {
          ConfigItem cooldownTime;
          String cooldownTimeLabel = "Event cooldown period (sec)";

          switch (snapshot.connectionState) {
            case ConnectionState.none:
            case ConnectionState.active:
            case ConnectionState.waiting:
              cooldownTime = ConfigItem(
                label: cooldownTimeLabel,
                setting: Text("Loading..."),
              );
              break;
            case ConnectionState.done:
              if (snapshot.hasError) {
                cooldownTime = ConfigItem(
                  label: cooldownTimeLabel,
                  setting: Text("Error retrieving data."),
                );
              } else if (snapshot.data.isNotEmpty) {
                devices = snapshot.data;
                num cooldownSecs =
                    devices[0]['properties']['desired']['eventCooldown'];
                if (cooldownSecs == null) {
                  cooldownSecs = 5;
                }
                cooldownTime = ConfigItem(
                  label: cooldownTimeLabel,
                  setting: ConstrainedBox(
                    constraints: BoxConstraints(maxWidth: 45),
                    child: TextField(
                      controller: TextEditingController(
                        text: cooldownSecs.toStringAsFixed(0),
                      ),
                      textAlignVertical: TextAlignVertical.center,
                      decoration: InputDecoration(
                        border: UnderlineInputBorder(),
                      ),
                      inputFormatters: [
                        WhitelistingTextInputFormatter.digitsOnly
                      ],
                      keyboardType: TextInputType.number,
                      onSubmitted: updateCooldownTime,
                    ),
                  ),
                );
              }
          }
          return Container(
            padding: EdgeInsets.symmetric(vertical: 30, horizontal: 40),
            child: Column(
              children: <Widget>[
                Text(
                  "Settings for All Devices",
                  style: Theme.of(context).textTheme.subhead,
                ),
                SizedBox(height: 15),
                if (devices != null && devices.isNotEmpty)
                  cooldownTime
                else
                  Center(
                    child: Text("No devices found"),
                  ),
              ],
            ),
          );
        },
      ),
    );
  }

  void updateCooldownTime(String newNum) {
    _propertyUpdates['eventCooldown'] = int.tryParse(newNum);
    _debounceTimer?.cancel();
    _debounceTimer = Timer(defaultDebounceTime, () {
      sendUpdates();
    });
  }

  void sendUpdates() async {
    for (var device in devices) {
      device = await widget.iotHub.updateDeviceTwin(
          deviceID: device["deviceId"], updates: _propertyUpdates);
    }
    setState(() {});
  }

  @override
  void dispose() {
    if (_debounceTimer != null && _debounceTimer.isActive) {
      _debounceTimer.cancel();
      sendUpdates();
    }
    super.dispose();
  }
}

class ConfigItem extends StatelessWidget {
  final String label;
  final Widget setting;
  ConfigItem({
    this.label,
    this.setting,
  });
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Padding(
            padding: EdgeInsets.only(right: 18),
            child: Text(
              label,
              style: TextStyle(
                fontSize: 17.5,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          ConstrainedBox(
            constraints: BoxConstraints(maxHeight: 35),
            child: setting,
          ),
        ],
      ),
    );
  }
}
