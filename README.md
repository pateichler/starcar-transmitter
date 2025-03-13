# Starcar Transmitter

This is the data acquition for my personal project called Starcar. Refer to the main repository for details about the project.

## Structure

The data acquition collects strain gauge data from my car struts as well as acceleratomer and GPS data from my iPhone. 

The strain gauges are constructed in a full wheatstone bridge to measure axial strain on the car strut. The output voltage is then sent to the HX711 chip to be converted into a digial value. This digital value is read by an Arduino Nano BLE. Finally the arduino sends the value to my iPhone using bluetooth connection where the value is then sent to a backend server through a WebSocket connection.

### Arduino

Arduino scirpt for interacting with the HX711 is in the hardware folder. This arduino script requires the [HX711 Arduino Library](https://docs.arduino.cc/libraries/hx711-arduino-library/) as well as the [ArduinoBLE Library](https://docs.arduino.cc/libraries/arduinoble/).

### iOS App

The iOS app is built using Swift in Xcode.
