  #include <TinyGPS++.h>
  #include <SoftwareSerial.h>
  #include <ESP8266WiFi.h>
  #include <ESP8266WebServer.h>
  #include <FirebaseESP8266.h>
  #define BUZZER_PIN D0

  #define FIREBASE_HOST "flutter-canteen-default-rtdb.firebaseio.com"
  #define FIREBASE_AUTH "AIzaSyA-b2jotmxZw45SeQZn_UcogZJXbTdMXMg"

  TinyGPSPlus gps;  // The TinyGPS++ object
  SoftwareSerial ss(4, 5); // The serial connection to the GPS device

  const char* ssid = "THIRU";
  const char* password = "11111111";

  float latitude, longitude;
  int year, month,  date, hour, minute, second;
  String date_str, time_str, lat_str, lng_str;
  int pm;
  float circleCenterLatitude = 0.0;
  float circleCenterLongitude = 0.0;
  float circleRadius = 0.0;
  FirebaseData firebaseData;
  ESP8266WebServer server(80);

  void setup()
  {
    Serial.begin(115200);
    ss.begin(9600);
    Serial.println();
    Serial.print("Connecting to ");
    Serial.println(ssid);
    WiFi.begin(ssid, password);
    
    while (WiFi.status() != WL_CONNECTED)
    {
      delay(500);
      Serial.print(".");
    }
    
    Serial.println("");
    Serial.println("WiFi connected");
    Serial.print("IP Address: ");
    Serial.println(WiFi.localIP());
    pinMode(BUZZER_PIN, OUTPUT);
    
    // Initialize Firebase
    Firebase.begin(FIREBASE_HOST, FIREBASE_AUTH);
    
    // Start the server
    server.on("/", handleRoot);
    server.begin();
    Serial.println("HTTP server started");
  }

  void loop()

  {
     

        if (Firebase.getString(firebaseData, "/buzzer")) {
      String buzzerState = firebaseData.stringData();
      if (buzzerState == "true") {
        // Trigger the buzzer
        digitalWrite(BUZZER_PIN, HIGH);
        delay(500);
        digitalWrite(BUZZER_PIN, LOW);
      } else {
        digitalWrite(BUZZER_PIN, LOW);
      }
    }

    while (ss.available() > 0)
    {
      if (gps.encode(ss.read()))
      {
        if (gps.location.isValid())
        {
          latitude = gps.location.lat();
          longitude = gps.location.lng();
          
          // Save latitude and longitude to Firebase
          Firebase.setFloat(firebaseData, "/location/latitude", latitude);
          Firebase.setFloat(firebaseData, "/location/longitude", longitude);
          Serial.println(latitude);
          Serial.println(longitude);
          
          if (firebaseData.dataAvailable())
          {
            Serial.println("Data saved to Firebase");
          }
          else
          {
            Serial.println("Error saving data to Firebase");
            Serial.println(firebaseData.errorReason());
          }
        }
        
        if (gps.date.isValid())
        {
          date_str = "";
          date = gps.date.day();
          month = gps.date.month();
          year = gps.date.year();

          if (date < 10)
            date_str = '0';
          date_str += String(date);

          date_str += " / ";

          if (month < 10)
            date_str += '0';
          date_str += String(month);

          date_str += " / ";

          if (year < 10)
            date_str += '0';
          date_str += String(year);
        }

        if (gps.time.isValid())
        {
          time_str = "";
          hour = gps.time.hour();
          minute = gps.time.minute();
          second = gps.time.second();

          minute = (minute + 30);
          if (minute > 59)
          {
            minute = minute - 60;
            hour = hour + 1;
          }
          hour = (hour + 5) ;
          if (hour > 23)
            hour = hour - 24;

          if (hour >= 12)
            pm = 1;
          else
            pm = 0;

          hour = hour % 12;

          if (hour < 10)
            time_str = '0';
          time_str += String(hour);

          time_str += " : ";

          if (minute < 10)
            time_str += '0';
          time_str += String(minute);

          time_str += " : ";

          if (second < 10)
            time_str += '0';
          time_str += String(second);

          if (pm == 1)
            time_str += " PM ";
          else
            time_str += " AM ";
        }
      }
    }

    server.handleClient();
  }

  void handleRoot()
  {
    String html = "<!DOCTYPE html><html><head><title>Location Details</title></head><body>";
    html += "<h1>Location Details</h1>";
    html += "<p><b>Latitude:</b> " + String(latitude, 6) + "</p>";
    html += "<p><b>Longitude:</b> " + String(longitude, 6) + "</p>";
    html += "<p><b>Date:</b> " + date_str + "</p>";
    html += "<p><b>Time:</b> " + time_str + "</p>";
    html += "</body></html>";

    server.send(200, "text/html", html);
  }
