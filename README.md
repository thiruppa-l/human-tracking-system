# 👣 Human Tracking System

This project implements a real-time human tracking system using GPS and ESP8266, with a Flutter-based mobile app to display location data on a map.

---

## 📦 Features

- 🔄 Real-time GPS location updates  
- 🌐 Data transfer using ESP8266 and Firebase  
- 🗺️ Live tracking on Google Maps via Flutter app  
- 🔔 Alert system for out-of-bound or idle locations (optional)

---

## 🧰 Components Used

### Hardware
- ESP8266 (NodeMCU)
- GPS Module (e.g., NEO-6M)
- Power source (battery/USB)

### Software
- Arduino IDE (for ESP8266 code)
- Flutter SDK
- Firebase (Realtime Database)
- Google Maps API

---

## 📁 Project Structure

human_tracking_system/
├── esp_code/ # Arduino code for ESP8266 + GPS
│ └── main.ino
├── flutter_app/ # Flutter app for UI and tracking
│ └── lib/
│ └── main.dart
└── README.md




---

## ⚙️ Setup Instructions

### ESP8266 + GPS

1. Open `esp_code/main.ino` in Arduino IDE.  
2. Install required libraries:
   - `TinyGPS++`
   - `FirebaseESP8266`
   - `ESP8266WiFi`
3. Replace your Wi-Fi and Firebase credentials.  
4. Upload code to ESP8266.

### Flutter App

1. Open `flutter_app/` in Android Studio or VS Code.  
2. Run `flutter pub get`.  
3. Add your Firebase configuration (`google-services.json`) and Google Maps API key.  
4. Run the app on your mobile device/emulator.

---

## 📷 Screenshot Preview

![Human Tracking Preview](https://upload.wikimedia.org/wikipedia/commons/thumb/9/94/Map_tracking_icon.svg/800px-Map_tracking_icon.svg.png)

---

## 📌 Use Cases

- Student or employee monitoring  
- Fleet tracking  
- Personal GPS safety tracker

---

## ⚠️ Disclaimer

This project is for educational purposes. Accuracy may vary depending on GPS module quality and internet availability.

---

## 📜 License

This project is open-source under the MIT License.

---

## 🙌 Contributions Welcome

Feel free to fork and improve the system with more features like:
- Geofencing
- History logging
- Multiple tracker support
