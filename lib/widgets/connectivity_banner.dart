import 'package:flutter/material.dart';
import 'package:connectivity_plus/connectivity_plus.dart';

class ConnectivityBanner extends StatefulWidget {
  final Widget child;
  const ConnectivityBanner({super.key, required this.child});

  @override
  State<ConnectivityBanner> createState() => _ConnectivityBannerState();
}

class _ConnectivityBannerState extends State<ConnectivityBanner> {
  bool _isConnected = true;

  @override
  void initState() {
    super.initState();
    Connectivity().onConnectivityChanged.listen((List<ConnectivityResult> results) {
      if (!mounted) return;
      setState(() {
        _isConnected = !results.contains(ConnectivityResult.none);
      });
    });
    _checkInitialConnection();
  }

  Future<void> _checkInitialConnection() async {
    final results = await Connectivity().checkConnectivity();
    if (!mounted) return;
    setState(() {
      _isConnected = !results.contains(ConnectivityResult.none);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Expanded(child: widget.child),
        AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          height: _isConnected ? 0 : 30,
          color: Colors.redAccent,
          alignment: Alignment.center,
          child: const Text(
            'No internet connection',
            style: TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.bold),
          ),
        ),
      ],
    );
  }
}
