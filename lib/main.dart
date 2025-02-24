import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'dart:async';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'GPS Offline',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: HomeScreen(),
    );
  }
}

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  String _locationMessage = "Presiona el botón para iniciar el seguimiento GPS";
  bool _isTracking = false;
  StreamSubscription<Position>? _positionStreamSubscription;

  Future<void> _checkPermissions() async {
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      setState(() {
        _locationMessage = "El servicio de ubicación está desactivado.";
      });
      return;
    }

    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        setState(() {
          _locationMessage = "Permisos de ubicación denegados.";
        });
        return;
      }
    }

    if (permission == LocationPermission.deniedForever) {
      setState(() {
        _locationMessage = "Permisos de ubicación denegados permanentemente.";
      });
      return;
    }
  }

  void _startTracking() async {
    await _checkPermissions();

    setState(() {
      _isTracking = true;
      _locationMessage = "Seguimiento GPS activado...";
    });

    _positionStreamSubscription = Geolocator.getPositionStream(
      locationSettings: LocationSettings(
        accuracy: LocationAccuracy.high,
        distanceFilter: 1,
      ),
    ).listen((Position position) {
      print("Latitud: ${position.latitude}, Longitud: ${position.longitude}");
      setState(() {
        _locationMessage = "Latitud: ${position.latitude}, Longitud: ${position.longitude}";
      });
    });
  }

  void _stopTracking() {
    _positionStreamSubscription?.cancel();
    setState(() {
      _isTracking = false;
      _locationMessage = "Seguimiento GPS detenido.";
    });
  }

  @override
  void dispose() {
    _positionStreamSubscription?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('GPS Offline'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(_locationMessage),
            SizedBox(height: 20),
            _isTracking
                ? ElevatedButton(
              onPressed: _stopTracking,
              child: Text('Detener Seguimiento'),
            )
                : ElevatedButton(
              onPressed: _startTracking,
              child: Text('Iniciar Seguimiento'),
            ),
          ],
        ),
      ),
    );
  }
}
