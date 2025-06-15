import 'dart:math' show atan2, cos, pi, pow, sin, sqrt;
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:location/location.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Google Map Demo',
      theme: ThemeData(
        primarySwatch: Colors.green, // Initial color for AppBar3
      ),
      home: MapScreen(),
    );
  }
}

class MapScreen extends StatefulWidget {
  @override
  _MapScreenState createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  late GoogleMapController mapController;
  late LocationData currentLocation;
  final Location location = Location();
  bool isInsideCircle = false; // Track user's location status
  bool isDialogOpen = false; // Track if the dialog box is open

  // Constants for the marked location
  LatLng markedLocation = LatLng(11.76634, 79.74019); // Center of the marked location
  double markedRadius = 500.0; // Radius of the marked location in meters

  @override
  void initState() {
    super.initState();
    location.onLocationChanged.listen((LocationData cLocation) {
      setState(() {
        currentLocation = cLocation;
        isInsideCircle = _checkLocation(cLocation);
        if (isInsideCircle) {
          // Close the dialog box if the user is inside the circle
          isDialogOpen = false;
        }
      });
    });
  }

  // Check if user is inside the marked location radius
  bool _checkLocation(LocationData cLocation) {
    if (cLocation == null) return false;

    // Calculate the distance between the user's current location and the center of the marked circle
    final double distance = _calculateDistance(cLocation.latitude!, cLocation.longitude!, markedLocation.latitude, markedLocation.longitude);

    // If the distance is less than or equal to the radius of the circle, user is inside the circle
    return distance <= markedRadius;
  }

  // Calculate distance between two points using Haversine formula
  double _calculateDistance(double lat1, double lon1, double lat2, double lon2) {
    const double earthRadius = 6371000; // Radius of the Earth in meters

    double dLat = (lat2 - lat1) * (pi / 180);
    double dLon = (lon2 - lon1) * (pi / 180);
    double a = sin(dLat / 2) * sin(dLat / 2) +
        cos(lat1 * (pi / 180)) *
            cos(lat2 * (pi / 180)) *
            sin(dLon / 2) *
            sin(dLon / 2);
    double c = 2 * atan2(sqrt(a), sqrt(1 - a));
    double distance = earthRadius * c;

    return distance;
  }

  // Function to handle map tap
  void _handleMapTap(LatLng tappedLocation) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        isDialogOpen = true; // Dialog box is opened
        return AlertDialog(
          title: Text('Confirm Location'),
          content: Text('Set the circle location here?'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                isDialogOpen = false; // Dialog box is closed
              },
              child: Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                _updateCircle(tappedLocation);
                isDialogOpen = false; // Dialog box is closed
              },
              child: Text('Confirm'),
            ),
          ],
        );
      },
    );
  }

  // Function to update the circle with new location
  void _updateCircle(LatLng newLocation) {
    setState(() {
      markedLocation = newLocation;
      isInsideCircle = _checkLocation(currentLocation);
    });
  }

  // Function to show input dialog for changing radius
  void _showRadiusInputDialog() {
    TextEditingController _controller = TextEditingController();

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Change Radius'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: _controller,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(labelText: 'Enter new radius (meters)'),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                double newRadius = double.tryParse(_controller.text) ?? markedRadius;
                _updateRadius(newRadius);
                Navigator.of(context).pop();
              },
              child: Text('Confirm'),
            ),
          ],
        );
      },
    );
  }

  // Function to update the radius of the circle
  void _updateRadius(double newRadius) {
    setState(() {
      markedRadius = newRadius;
    });
  }

  @override
  Widget build(BuildContext context) {
    Color appBarColor = isInsideCircle ? Colors.green : Colors.red; // Determine AppBar color based on user's location

    return Scaffold(
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(70), // Set preferred height for curved AppBar
        child: AppBar(
          title: Text(
            'Mini Project👩🏼‍💻',
            textAlign: TextAlign.center, // Align text to center
          ),
          backgroundColor: appBarColor, // Set AppBar color dynamically
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.vertical(
              bottom: Radius.circular(30), // Set curve radius
            ),
          ),
        ),
      ),
      body: Stack(
        children: [
          GoogleMap(
            onMapCreated: (controller) {
              setState(() {
                mapController = controller;
              });
            },
            initialCameraPosition: CameraPosition(
              target: markedLocation, // Center the map on the marked location
              zoom: 15.0,
            ),
            myLocationEnabled: true,
            myLocationButtonEnabled: true,
            circles: _createCircles(),
            onTap: _handleMapTap, // Add this line to handle map tap
          ),
          if (!isInsideCircle && !isDialogOpen) // Display dialog box only if user is outside the circle and dialog box is not already open
            Positioned(
              left: 0,
              right: 0,
              bottom: 0,
              child: Container(
                padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                color: Colors.red, // Color of the dialog box
                child: Text(
                  'You have exited the marked location radius.',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.white),
                ),
              ),
            ),
          Positioned(
            left: 16, // Position the floating button to the left
            bottom: 60,
            child: FloatingActionButton(
              onPressed: _showRadiusInputDialog, // Show input dialog to change radius
              child: Icon(Icons.edit),
            ),
          ),
        ],
      ),
    );
  }

  Set<Circle> _createCircles() {
    // Create and return the circle for the marked location
    return Set.from([
      Circle(
        circleId: CircleId("radius"),
        center: markedLocation,
        radius: markedRadius,
        fillColor: Colors.redAccent.withOpacity(0.3),
        strokeWidth: 0,
      ),
    ]);
  }
}
