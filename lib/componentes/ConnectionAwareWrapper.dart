

//WIDGET QUE PERMITE ENVOLVER A OTROS WIDGETS
//PARA DETERMINAR QUE MOSTRAR EN LA APP
//EN EL MOMENTO QUE NO HAYA CONEXION A INTERNET

/*

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
class ConnectionAwareWrapper extends StatefulWidget {
  final Widget connectedChild;
  final Widget disconnectedChild;

  const ConnectionAwareWrapper({super.key, 
    required this.connectedChild,
    required this.disconnectedChild,
  });

  @override
  _ConnectionAwareWrapperState createState() => _ConnectionAwareWrapperState();
}

class _ConnectionAwareWrapperState extends State<ConnectionAwareWrapper> {
  List<ConnectivityResult> _connectionStatus = [];
  final Connectivity _connectivity = Connectivity();
  late StreamSubscription<List<ConnectivityResult>> _subscription;

  @override
  void initState() {
    super.initState();
    initConnectivity();
    _subscription = _connectivity.onConnectivityChanged
        .listen((List<ConnectivityResult> result) {
      setState(() {
        _connectionStatus = result;
      });
    });
  }

  Future<void> initConnectivity() async {
    List<ConnectivityResult> result;
    try {
      result = await _connectivity.checkConnectivity();
    } catch (e) {
      result = [ConnectivityResult.none];
    }
    if (!mounted) return;
    setState(() {
      _connectionStatus = result;
    });
  }

  @override
  void dispose() {
    _subscription.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    bool hasConnection = _connectionStatus.isNotEmpty &&
        _connectionStatus.any((result) => result != ConnectivityResult.none);

    return hasConnection ? widget.connectedChild : widget.disconnectedChild;
  }
}



*/
