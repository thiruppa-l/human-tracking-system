import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import 'ParkingDurationDialog.dart';

class ParkingSpotDetails extends StatelessWidget {
  final String parkingName;
  final int numberOfSlots;

  ParkingSpotDetails({required this.parkingName, required this.numberOfSlots});

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              parkingName,
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 4),
            Text(
              'Number of Slots: $numberOfSlots',
              style: TextStyle(fontSize: 14),
            ),
          ],
        ),
        backgroundColor: Colors.blue,
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  ParkingSpotSlots(
                    numberOfSlots: numberOfSlots,
                    parkingName: parkingName,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class ParkingSpotSlots extends StatelessWidget {
  final int numberOfSlots;
  final String parkingName;

  ParkingSpotSlots({required this.numberOfSlots, required this.parkingName});

  // Define a method to check slot occupancy
  Future<Map<String, dynamic>?>? isSlotOccupied(int index) async {
    final docSnapshot = await FirebaseFirestore.instance
        .collection('parking_slots')
        .doc(parkingName)
        .collection('slots')
        .doc('slot_$index')
        .get();
    final data = docSnapshot.data();
    return data != null ? data as Map<String, dynamic> : null;
  }


  @override
  Widget build(BuildContext context) {
    final double slotSize = 30; // Reduce the size of the slot
    final double containerHeight =
        numberOfSlots * (slotSize + 5); // Calculate container height based on the number of slots

    return GridView.builder(
      shrinkWrap: true,
      physics: NeverScrollableScrollPhysics(),
      itemCount: numberOfSlots,
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 5,
        mainAxisSpacing: 5,
        childAspectRatio: 1,
      ),
      itemBuilder: (BuildContext context, int index) {
        return FutureBuilder<Map<String, dynamic>?>(
          future: isSlotOccupied(index),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return Container(
                width: slotSize,
                height: slotSize,
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Center(
                  child: CircularProgressIndicator(),
                ),
              );
            } else {
              if (snapshot.hasData) {
                final Map<String, dynamic>? data = snapshot.data;
                if (data != null) {
                  final bool isOccupied = data['isOccupied'];
                  if (isOccupied) {

                    final String fromTime = data['fromTime'];
                    final String toTime = data['toTime'];

                    // Format the fromTime and toTime with AM/PM
                    final DateFormat timeFormat = DateFormat.jm(); // j = hour (1-12), m = minute, A = AM/PM
                    final DateTime fromTimeDateTime = DateTime.parse("2022-01-01 ${fromTime}"); // Add a dummy date to parse the time string
                    final DateTime toTimeDateTime = DateTime.parse("2022-01-01 ${toTime}");
                    final String formattedFromTime = timeFormat.format(fromTimeDateTime);
                    final String formattedToTime = timeFormat.format(toTimeDateTime);
                    return Container(
                      width: slotSize,
                      height: slotSize,
                      decoration: BoxDecoration(
                        color: Colors.grey, // Change color for occupied slot
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Center(
                        child: Text(
                          '$formattedFromTime - $formattedToTime',
                          style: TextStyle(fontSize: 12, color: Colors.white),
                        ),
                      ),
                    );
                  }
                }
              }

              // Handle unoccupied slot
              return GestureDetector(
                onTap: () async {
                  // Show dialog for confirmation
                  showDialog(
                    context: context,
                    builder: (BuildContext context) {
                      return ParkingDurationDialog(index: index, parkingName: parkingName);
                    },
                  );
                },
                child: Container(
                  width: slotSize,
                  height: slotSize,
                  decoration: BoxDecoration(
                    color: Colors.blue[200], // Change color for unoccupied slot
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Center(
                    child: Text(
                      (index + 1).toString(),
                      style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
              );
            }
          },
        );


      },
    );
  }
}




