import 'package:flutter/material.dart';

import 'Manage Parking Spaces/manage_parking_spaces_page.dart';

class AdminPanel extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Admin Panel'),
      ),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: ListView(
          children: <Widget>[
            SizedBox(height: 20),
            ElevatedButton.icon(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => ManageParkingSpacesPage()),
                );
                // Navigate to manage parking spaces page
              },
              icon: Icon(Icons.local_parking_outlined),
              label: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Text(
                  'Manage Parking Spaces',
                  style: TextStyle(fontSize: 18),
                ),
              ),
            ),
            SizedBox(height: 20),
            ElevatedButton.icon(
              onPressed: () {
                // Navigate to view bookings page
              },
              icon: Icon(Icons.event_note),
              label: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Text(
                  'View Bookings',
                  style: TextStyle(fontSize: 18),
                ),
              ),
            ),
            SizedBox(height: 20),
            ElevatedButton.icon(
              onPressed: () {
                // Navigate to user management page
              },
              icon: Icon(Icons.person),
              label: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Text(
                  'User Management',
                  style: TextStyle(fontSize: 18),
                ),
              ),
            ),
            SizedBox(height: 20),
            ElevatedButton.icon(
              onPressed: () {
                // Navigate to analytics and reports page
              },
              icon: Icon(Icons.analytics),
              label: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Text(
                  'Analytics and Reports',
                  style: TextStyle(fontSize: 18),
                ),
              ),
            ),
            SizedBox(height: 20),
            ElevatedButton.icon(
              onPressed: () {
                // Navigate to settings page
              },
              icon: Icon(Icons.settings),
              label: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Text(
                  'Settings',
                  style: TextStyle(fontSize: 18),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
