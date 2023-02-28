import 'package:flutter/services.dart';
import 'package:flutter/material.dart';
import 'dart:async';

import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:sliding_up_panel/sliding_up_panel.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Uber',
      home: HomePage(),
    );
  }
}

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  static final CameraPosition initialPosition = CameraPosition(
    target: LatLng(40.785091, -73.968285),
    tilt: 0,
    bearing: 0,
    zoom: 15,
  );

  static final CameraPosition endPosition = CameraPosition(
    target: LatLng(40.780091, -73.962185),
    tilt: 0,
    bearing: 0,
    zoom: 15,
  );

  final Completer<String> googleMapStyle = Completer();
  final Completer<GoogleMapController> googleMapController = Completer();
  final Set<Marker> markers = {};
  final Set<Polyline> polylines = {};

  @override
  void initState() {
    super.initState();
    rootBundle
        .loadString("assets/googlemaps.json")
        .then((style) => googleMapStyle.complete(style));
    setupMap();
  }

  void setupMap() async {
    final googlemap = await googleMapController.future;
    final style = await googleMapStyle.future;

    googlemap.setMapStyle(style);

    setState(() {
      markers.add(Marker(
        markerId: MarkerId(initialPosition.target.toString()),
        position: initialPosition.target,
        infoWindow: InfoWindow(title: 'Starting Point'),
      ));

      markers.add(Marker(
        markerId: MarkerId(endPosition.target.toString()),
        position: endPosition.target,
        infoWindow: InfoWindow(title: 'Starting Point'),
      ));

      polylines.add(
        Polyline(
          polylineId: PolylineId(initialPosition.target.toString() +
              endPosition.target.toString()),
          points: [initialPosition.target, endPosition.target],
          width: 4,
        ),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SlidingUpPanel(
        minHeight: 100,
        maxHeight: 280,
        panel: panel(),
        body: map(),
      ),
    );
  }

  Widget panel() => Column(
        children: [
          Container(
            width: 60,
            height: 4,
            margin: EdgeInsets.symmetric(vertical: 10),
            decoration: BoxDecoration(
              color: Colors.grey.shade400,
              borderRadius: BorderRadius.circular(4),
            ),
          ),
          transportMedium(
              icon: Icons.car_crash,
              name: 'UberX',
              time: '12:05',
              price: '\$10.50'),
          transportMedium(
              icon: Icons.car_rental,
              name: 'Pool',
              time: '12:15',
              price: '\$8.50'),
          Divider(
            thickness: 1,
          ),
          Text("Book it now!"),
          Padding(
              padding: EdgeInsets.all(16),
              child: MaterialButton(
                  onPressed: () {},
                  minWidth: double.infinity,
                  color: Colors.black,
                  textColor: Colors.white,
                  child: Text("Book Ride")))
        ],
      );

  Widget transportMedium({
    required IconData icon,
    required String name,
    required String time,
    required String price,
  }) =>
      ListTile(
        leading: Icon(
          icon,
          size: 50,
        ),
        title: Text(name, style: TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Text(time),
        trailing: Text(price),
      );

  Widget map() => GoogleMap(
        initialCameraPosition: initialPosition,
        zoomControlsEnabled: false,
        markers: markers,
        polylines: polylines,
        onMapCreated: (GoogleMapController controller) {
          this.googleMapController.complete(controller);
        },
      );
}
