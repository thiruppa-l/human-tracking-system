import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:parkdup/User/payment.dart';

class ParkingDurationDialog extends StatefulWidget {
  final int index;
  final String parkingName;

  ParkingDurationDialog({required this.index, required this.parkingName});

  @override
  _ParkingDurationDialogState createState() => _ParkingDurationDialogState();
}

class _ParkingDurationDialogState extends State<ParkingDurationDialog> {
  double _currentValue = 1.0; // Initial value for the slider
  TimeOfDay _selectedTime = TimeOfDay.now(); // Initial value for the selected time
  DateTime _selectedDate = DateTime.now(); // Initial value for the selected date
  Timer? _timer; // Timer to track the remaining time
  Duration _remainingDuration = Duration(); // Variable to hold the remaining duration
  double _rate = 0.0; // Parking rate

  @override
  void initState() {
    super.initState();
    // Calculate rate initially
    _calculateRate();
  }

  @override
  void dispose() {
    _timer?.cancel(); // Cancel the timer when disposing the dialog
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Calculate the time after the selected duration
    final int totalMinutes = (_currentValue * 60).toInt();
    final int hoursToAdd = totalMinutes ~/ 60;
    final int minutesToAdd = totalMinutes % 60;
    final TimeOfDay timeAfterDuration = TimeOfDay(
      hour: (_selectedTime.hour + hoursToAdd) % 24,
      minute: (_selectedTime.minute + minutesToAdd) % 60,
    );

    // Start the timer
    _startTimer();

    return AlertDialog(
      title: Text('Slot Confirmation'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              Text('From:'),
              TextButton(
                onPressed: () async {
                  final pickedTime = await showTimePicker(
                    context: context,
                    initialTime: _selectedTime,
                  );
                  if (pickedTime != null) {
                    setState(() {
                      _selectedTime = pickedTime;
                    });
                  }
                },
                child: Text(_selectedTime.format(context)),
              ),
              Text('To: ${_formatTimeOfDay(timeAfterDuration)}'),
            ],
          ),
          SizedBox(height: 8),
          Row(
            children: [
              Text('Date:'),
              TextButton(
                onPressed: () async {
                  final pickedDate = await showDatePicker(
                    context: context,
                    initialDate: _selectedDate,
                    firstDate: DateTime.now(),
                    lastDate: DateTime.now().add(Duration(days: 1)),
                  );
                  if (pickedDate != null) {
                    setState(() {
                      _selectedDate = pickedDate;
                    });
                  }
                },
                child: Text(DateFormat('d, EEE MMM').format(_selectedDate)),
              ),
            ],
          ),
          SizedBox(height: 16),
          Text('Please select the parking duration:'),
          Slider(
            value: _currentValue,
            min: 0.5,
            max: 4,
            divisions: 70,
            label: _currentValue == 1
                ? '${_currentValue.round()} hr'
                : '${_currentValue.floor()} hr ${((_currentValue - _currentValue.floor()) * 60).toInt()} min',
            onChanged: (double value) {
              setState(() {
                _currentValue = value;
                // Recalculate rate when duration changes
                _calculateRate();
              });
            },
          ),
          SizedBox(height: 16),
          Text('Parking Rate: ₹${_rate.toStringAsFixed(2)}'), // Display rate in rupees
          SizedBox(height: 16),
          Text('Time remaining: ${_formatTimeRemaining()}'),
        ],
      ),
      actions: <Widget>[
        TextButton(
          onPressed: () {
            Navigator.of(context).pop(); // Close the dialog
          },
          child: Text('Cancel'),
        ),
        TextButton(
          onPressed: () async {

            // Open the payment screen
            RazorpayPayment.openPayment(
                context,
                _rate,
                onSuccess: () async {


                  // Perform the action when payment is successful
                  await FirebaseFirestore.instance
                      .collection('parking_slots')
                      .doc(widget.parkingName)
                      .collection('slots')
                      .doc('slot_${widget.index}')
                      .set(
                    {
                      'isOccupied': true,
                      'parkingDuration': _currentValue.round(), // Store the selected duration
                      'date': DateFormat('yyyy-MM-dd').format(_selectedDate), // Store the selected date
                      'fromTime': '${_selectedTime.hour.toString().padLeft(2, '0')}:${_selectedTime.minute.toString().padLeft(2, '0')}', // Store the selected from time
                      'toTime': '${timeAfterDuration.hour.toString().padLeft(2, '0')}:${timeAfterDuration.minute.toString().padLeft(2, '0')}', // Store the selected to time
                      'rate': _rate,
                    },
                    SetOptions(merge: true),
                  );


                },
                onFailure: () {

                  // Display a message when payment fails
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Payment failed. Please try again.'),
                      backgroundColor: Colors.red,
                    ),
                  );
                  Navigator.of(context).pop();
                });
          },
          child: Text('Yes'),
        ),
      ],
    );
  }

  String _formatTimeOfDay(TimeOfDay timeOfDay) {
    final hour = timeOfDay.hourOfPeriod;
    final minute = timeOfDay.minute.toString().padLeft(2, '0');
    final period = timeOfDay.period == DayPeriod.am ? 'AM' : 'PM';
    return '$hour:$minute $period';
  }

  // Start the timer
  void _startTimer() {
    final totalMinutes = (_currentValue * 60).toInt();
    final duration = Duration(minutes: totalMinutes);
    _remainingDuration = duration; // Initialize the remaining duration
    _timer = Timer.periodic(Duration(seconds: 1), (timer) {
      setState(() {
        if (_remainingDuration.inSeconds <= 0) {
          timer.cancel(); // Stop the timer when duration is over
        } else {
          _remainingDuration -= Duration(seconds: 1); // Update the remaining duration
        }
      });
    });
  }

  // Format the remaining time
  String _formatTimeRemaining() {
    final hours = _remainingDuration.inHours;
    final minutes = _remainingDuration.inMinutes.remainder(60);
    return '$hours hr ${minutes} min';
  }

  // Method to calculate parking rate based on duration
  void _calculateRate() {
    // Your rate calculation logic goes here
    // For example, you can have a fixed rate per hour
    final double ratePerHour = 50.0; // Adjust this value according to your pricing
    _rate = _currentValue * ratePerHour;
  }
}
