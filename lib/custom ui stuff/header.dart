import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:battery_plus/battery_plus.dart';


class PageTitle extends ChangeNotifier {
  String _title = 'QrShare';

  String get title => _title;

  void setTitle(String newTitle) {
    _title = newTitle;
    notifyListeners();
  }
}

class ConnectivityStatus extends ChangeNotifier {
  bool _isConnected = true;

  bool get isConnected => _isConnected;

  void setConnectivity(bool isConnected) {
    _isConnected = isConnected;
    notifyListeners();
  }
}

class Header extends StatefulWidget implements PreferredSizeWidget {
  final Function(int) onProfileTap;
  final String profilePhotoUrl;

  const Header({Key? key, required this.onProfileTap, required this.profilePhotoUrl}) : super(key: key);

  @override
  _HeaderState createState() => _HeaderState();

  @override
  Size get preferredSize => const Size.fromHeight(56.0);
}

class _HeaderState extends State<Header> {
  late ConnectivityStatus _connectivityStatus;

  @override
  void initState() {
    super.initState();
    _connectivityStatus = Provider.of<ConnectivityStatus>(context, listen: false);
    _checkConnectivity();
  }

  void _checkConnectivity() async {
    var connectivityResult = await (Connectivity().checkConnectivity());
    _connectivityStatus.setConnectivity(connectivityResult != ConnectivityResult.none);

    Connectivity().onConnectivityChanged.listen((ConnectivityResult result) {
      _connectivityStatus.setConnectivity(result != ConnectivityResult.none);
    });
  }

  @override
  Widget build(BuildContext context) {
    return AppBar(
      title: Padding(
        padding: const EdgeInsets.only(top: 10),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(Provider.of<PageTitle>(context).title),
            Row(
              children: [
                Consumer<ConnectivityStatus>(
                  builder: (context, connectivity, child) {
                    return Visibility(
                      visible: !connectivity.isConnected,
                      child: Padding(
                        padding: const EdgeInsets.only(right: 8.0),
                        child: Icon(Icons.cloud_off, color: Colors.white, size: 20),
                      ),
                    );
                  },
                ),
                // Battery Percentage Icon
                Consumer<BatteryStatus>(
                  builder: (context, batteryStatus, child) {
                    return Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 8.0),
                      child: Row(
                        children: [
                          Icon(Icons.battery_full, color: Colors.white, size: 20),
                          const SizedBox(width: 4),
                          Text(
                            '${batteryStatus.batteryLevel}%',
                            style: TextStyle(color: Colors.white, fontSize: 16),
                          ),
                        ],
                      ),
                    );
                  },
                ),
                GestureDetector(
                  onTap: () {
                    widget.onProfileTap(4);
                  },
                  child: CircleAvatar(
                    radius: 13,
                    backgroundImage: NetworkImage(widget.profilePhotoUrl),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
      centerTitle: true,
      toolbarHeight: 40,
      backgroundColor: const Color(0xFF40A578),
    );
  }
}

class BatteryStatus extends ChangeNotifier {
  int _batteryLevel = 100; // Default value

  int get batteryLevel => _batteryLevel;

  BatteryStatus() {
    _init();
  }

  Future<void> _init() async {
    final battery = Battery();
    _batteryLevel = await battery.batteryLevel;
    notifyListeners();

    // Listen for battery level changes
    battery.onBatteryStateChanged.listen((BatteryState state) {
      _updateBatteryLevel();
    });
  }

  Future<void> _updateBatteryLevel() async {
    _batteryLevel = await Battery().batteryLevel;
    notifyListeners();
  }
}