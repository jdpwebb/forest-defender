# Forest Defender App

The companion App for the Forest Defender device allows viewing a list of all devices attached to the associated Azure IoT Hub, testing each device by simulating a fire event, and configuring device settings.

# Setup

This app is built with Flutter. Additionally, it requires access to the Azure IoT Hub that the Forest Defender device is connected to. To configure this, paste the Azure IoT Hub endpoint and IoT Hub shared access key with 'iothubowner' permissions into the respective variables in main.dart. Then build the app following the official Flutter documentation for [Android](https://flutter.dev/docs/deployment/android), or [iOS](https://flutter.dev/docs/deployment/ios).

For more information about Flutter, view the
[online documentation](https://flutter.dev/docs), which offers tutorials,
samples, guidance on mobile development, and a full API reference.
