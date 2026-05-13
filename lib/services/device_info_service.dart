import 'package:device_info_plus/device_info_plus.dart';

class DeviceInfoService {
  final DeviceInfoPlugin _plugin = DeviceInfoPlugin();

  Future<String> getDeviceId() async {
    final info = await _plugin.androidInfo;
    return info.id;
  }

  Future<String> getDeviceName() async {
    final info = await _plugin.androidInfo;
    return '${info.manufacturer} ${info.model}';
  }

  Future<int> getSdkVersion() async {
    final info = await _plugin.androidInfo;
    return info.version.sdkInt;
  }

  Future<bool> isPhysicalDevice() async {
    final info = await _plugin.androidInfo;
    return info.isPhysicalDevice;
  }
}
