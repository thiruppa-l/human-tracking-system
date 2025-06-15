import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:firebase_database/firebase_database.dart';

class ManageParkingSpacesPage extends StatelessWidget {
  final DatabaseReference _database = FirebaseDatabase.instance.reference();

  Future<void> _showAddSpotDialog(BuildContext context) async {
    String spotName = '';
    String spotNumber = '';
    LatLng spotLocation = LatLng(0, 0); // Initialize spotLocation

    Completer<GoogleMapController> _controller = Completer();
    Set<Marker> _markers = {}; // Set to store markers

    return showDialog<void>(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: Text('Add Parking Spot'),
              contentPadding: EdgeInsets.all(2.0),
              content: SingleChildScrollView( // Wrap content with SingleChildScrollView
                child: SizedBox(
                  width: double.maxFinite,
                  height: 550, // Adjust as needed
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(12.0),
                          border: Border.all(color: Colors.grey),
                        ),
                        clipBehavior: Clip.hardEdge,
                        child: SizedBox(
                          width: double.maxFinite,
                          height: 300, // Adjust as needed
                          child: GoogleMap(
                            onMapCreated: (GoogleMapController controller) {
                              _controller.complete(controller);
                            },
                            initialCameraPosition: CameraPosition(
                              target: LatLng(11.398, 79.078), // Initial location
                              zoom: 15, // Initial zoom level
                            ),
                            onTap: (LatLng position) {
                              setState(() {
                                _markers.clear(); // Clear existing markers
                                _markers.add(
                                  Marker(
                                    markerId: MarkerId('spot'),
                                    position: position,
                                  ),
                                );
                                spotLocation = position; // Update spot location
                              });
                            },
                            markers: _markers,
                          ),
                        ),
                      ),
                      SizedBox(height: 12.0),
                      Text(
                        'Latitude: ${spotLocation.latitude}',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      SizedBox(height: 4.0),
                      Text(
                        'Longitude: ${spotLocation.longitude}',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      SizedBox(height: 16.0),
                      TextField(
                        decoration: InputDecoration(
                          labelText: 'Spot Name',
                          border: OutlineInputBorder(),
                        ),
                        onChanged: (value) {
                          spotName = value;
                        },
                      ),
                      SizedBox(height: 12.0),
                      TextField(
                        decoration: InputDecoration(
                          labelText: 'Spot Number',
                          border: OutlineInputBorder(),
                        ),
                        onChanged: (value) {
                          spotNumber = value;
                        },
                      ),
                    ],
                  ),
                ),
              ),
              actions: <Widget>[
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  child: Text('Cancel'),
                ),
                ElevatedButton(
                  onPressed: () {
                    // Save spot details to Firebase
                    if (spotName.isNotEmpty && spotNumber.isNotEmpty) {
                      _saveSpotDetails(spotName, spotNumber, spotLocation);
                      Navigator.of(context).pop();
                    } else {
                      // Show error message if any field is empty
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('Please enter all fields.'),
                        ),
                      );
                    }
                  },
                  child: Text('Save'),
                ),
              ],
            );
          },
        );
      },
    );
  }


  void _saveSpotDetails(String name, String number, LatLng location) {
    FirebaseFirestore.instance.collection('Admin').doc(name).set({
      'Parking_name': name,
      'Number_of_slots': number,
      'latitude': location.latitude,
      'longitude': location.longitude,
    }).then((value) {
      // Successfully saved to Firestore
      print('Spot details saved to Firestore');
    }).catchError((error) {
      // Handle error
      print('Failed to save spot details: $error');
    });
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Manage Parking Spaces'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'This is the Manage Parking Spaces page',
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                _showAddSpotDialog(context);
              },
              child: Text('Add Spot'),
            ),
          ],
        ),
      ),
    );
  }
}
