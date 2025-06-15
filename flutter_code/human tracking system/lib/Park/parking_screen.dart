
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:razorpay_flutter/razorpay_flutter.dart';
import 'package:parkdup/payment_screen.dart';
import 'package:parkdup/setting_screen.dart';

import 'login_screen.dart';

class CarParkingApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Car Parking System',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      routes: {
        '/payment': (context) => PaymentScreen(),
        '/settings': (context) => SettingsScreen(),
      },
      home: ParkingSpotReservationPage(
        parkingSpots: [
          'Parking Spot 1',
          'Parking Spot 2',
          'Parking Spot 3',
          'Parking Spot 4',
          'Parking Spot 5',
          'Parking Spot 6',
          'Parking Spot 7',
          'Parking Spot 8',
        ],
      ),
    );
  }
}

class ParkingSpotReservationPage extends StatefulWidget {
  final List<String> parkingSpots;
  final List<String> parkingSpotImages = [
    'assets/images/car.png',
    'assets/images/car.png',
    'assets/images/car.png',
    'assets/images/car.png',
    'assets/images/car.png',
    'assets/images/car.png',
    'assets/images/car.png',
    'assets/images/car.png',
  ];
  final Set<int> bookedSpots = {}; // Track the booked parking spots
  int selectedSpotIndex = -1;

  ParkingSpotReservationPage({required this.parkingSpots});

  @override
  _ParkingSpotReservationPageState createState() =>
      _ParkingSpotReservationPageState();
}

class _ParkingSpotReservationPageState
    extends State<ParkingSpotReservationPage> {
  final DatabaseReference databaseRef = FirebaseDatabase.instance.reference();

  void bookSpot(int index) {
    setState(() {
      widget.bookedSpots.add(index);
      widget.selectedSpotIndex = index;

      // Update the boolean value in Firebase
      databaseRef
          .child('parkingSpots/$index/booked')
          .set(true)
          .then((_) {
        print('Spot $index is booked.');
      }).catchError((error) {
        print('Failed to book spot: $error');
      });
    });
  }

  bool isSpotBooked(int index) {
    return widget.bookedSpots.contains(index);
  }

  double getRotationAngle(int index) {
    if (index % 2 == 0) {
      // Rotate images in even-indexed columns by 0 degrees
      return 1.5708;
    } else {
      // Rotate images in odd-indexed columns by 180 degrees
      return -1.5708;
    }
  }

  @override
  Widget build(BuildContext context) {
    int reservedSlots = widget.bookedSpots.length;
    int availableSlots = widget.parkingSpots.length - reservedSlots;

    return Scaffold(
      appBar: AppBar(
        title: Text('Reserve Parking Spot'),
      ),
      drawer: Drawer(
        child: FutureBuilder<User?>(
          future: FirebaseAuth.instance.authStateChanges().first,
          builder: (BuildContext context, AsyncSnapshot<User?> snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return CircularProgressIndicator();
            } else if (snapshot.hasError) {
              return Text('Error: ${snapshot.error}');
            } else {
              User? user = snapshot.data;
              return ListView(
                children: [
                  UserAccountsDrawerHeader(
                    accountName: Text(user?.displayName ?? ''),
                    accountEmail: Text(user?.email ?? ''),
                    currentAccountPicture: CircleAvatar(
                      child: Icon(Icons.person),
                    ),
                  ),
                  ListTile(
                    leading: Icon(Icons.settings),
                    title: Text('Settings'),
                    onTap: () {
                      Navigator.pushNamed(context, '/settings');
                    },
                  ),
                  ListTile(
                    leading: Icon(
                      Icons.logout,
                      color: Colors.red,
                    ),
                    title: Text(
                      'Logout',
                      style: TextStyle(
                        color: Colors.red,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    onTap: () {
                      FirebaseAuth.instance.signOut().then((_) {
                        // Navigate to the login page or any other desired page
                        Navigator.pushReplacementNamed(context, '/login');
                      }).catchError((error) {
                        // Handle logout errors
                        print('Logout Error: $error');
                      });
                    },
                  ),
                ],
              );
            }
          },
        ),
      ),
      body: Column(
        children: [
          SizedBox(height: 16.0),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                'Reserved Slots: $reservedSlots',
                style: TextStyle(
                  fontSize: 18.0,
                  fontWeight: FontWeight.bold,
                  color: Colors.red,
                ),
              ),
              SizedBox(width: 16.0),
              Text(
                'Available Slots: $availableSlots',
                style: TextStyle(
                  fontSize: 18.0,
                  fontWeight: FontWeight.bold,
                  color: Colors.green,
                ),
              ),
            ],
          ),
          Expanded(
            child: Center(
              child: GridView.count(
                crossAxisCount: 2, // 2 columns
                padding: EdgeInsets.all(38),
                mainAxisSpacing: 38,
                crossAxisSpacing: 40,
                children: [
                  for (int i = 0; i < widget.parkingSpots.length; i++)
                    ElevatedButton(
                      onPressed: isSpotBooked(i)
                          ? null
                          : () async {
                        final result = await Navigator.pushNamed(
                          context,
                          '/payment',
                          arguments: widget.parkingSpots[i],
                        );

                        if (result != null && result is bool && result) {
                          // Payment was successful
                          setState(() {
                            widget.bookedSpots.add(i);
                          });

                          // Update Firebase when payment is successful
                          _updateFirebaseOnSuccessfulPayment(i);
                        }
                      },
                      style: ButtonStyle(
                        backgroundColor:
                        MaterialStateProperty.resolveWith<Color>(
                              (Set<MaterialState> states) {
                            if (isSpotBooked(i)) {
                              return Colors.blue; // Change color for booked and paid slots
                            } else if (states.contains(MaterialState.disabled)) {
                              return Colors.red; // Reserved slot color
                            }
                            return Colors.green; // Available slot color
                          },
                        ),
                        shape: MaterialStateProperty.resolveWith<OutlinedBorder>(
                              (Set<MaterialState> states) {
                            return RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(20.0),
                            );
                          },
                        ),
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Transform.rotate(
                            angle: getRotationAngle(i),
                            child: Opacity(
                              opacity: isSpotBooked(i) ? 1 : 1,
                              child: widget.selectedSpotIndex == i
                                  ? Image.asset(
                                'assets/images/car.png',
                                width: 120,
                                height: 120,
                              )
                                  : isSpotBooked(i)
                                  ? Image.asset(
                                'assets/images/car.png',
                                width: 120,
                                height: 120,
                              )
                                  : Image.asset(
                                'assets/images/car_available.png',
                                width: 120,
                                height: 120,
                              ),
                            ),
                          ),
                          SizedBox(height: 8),
                          Text(
                            widget.parkingSpots[i],
                            style: TextStyle(fontSize: 10),
                          ),
                        ],
                      ),
                    )
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _updateFirebaseOnSuccessfulPayment(int index) {
    // Update the boolean value in Firebase for the booked spot
    databaseRef
        .child('parkingSpots/$index/booked')
        .set(true)
        .then((_) {
      print('Spot $index updated as booked in Firebase.');
    }).catchError((error) {
      print('Failed to update Firebase for spot $index: $error');
    });
  }
}

class PaymentPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final String parkingSpot =
    ModalRoute.of(context)!.settings.arguments as String;

    return Scaffold(
      appBar: AppBar(
        title: Text('Payment'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'Selected Parking Spot:',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 16),
            Text(
              parkingSpot,
              style: TextStyle(fontSize: 20),
            ),
            SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context, true);
              },
              child: Text('Go Back'),
            ),
          ],
        ),
      ),
    );
  }
}