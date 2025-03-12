#include <ArduinoBLE.h>
#include "HX711.h"

const char* deviceServiceUuid = "A07498CA-AD9B-475E-950D-16F1FBE7E8CD";
const char* deviceServiceCharacteristicUuid = "51FF12BB-3ED8-46E5-B4F9-D64E2FEC021B";

HX711 loadcell1;
const int LOADCELL_DOUT_PIN_1 = 2;
const int LOADCELL_SCK_PIN_1 = 3;

HX711 loadcell2;
const int LOADCELL_DOUT_PIN_2 = 11;
const int LOADCELL_SCK_PIN_2 = 12;

long loadcellValues[] = {0, 0};

BLEService bService(deviceServiceUuid); 
BLECharacteristic bCharacterstic(deviceServiceCharacteristicUuid, BLERead | BLEWrite, sizeof(loadcellValues), true);

void setup() {
  // put your setup code here, to run once:
  Serial.println("Init");
  
  if (!BLE.begin()) {
    Serial.println("- Starting Bluetooth® Low Energy module failed!");
    while (1);
  }

  BLE.setLocalName("Strain Gauge Reader");
  BLE.setAdvertisedService(bService);
  bService.addCharacteristic(bCharacterstic);
  BLE.addService(bService);
  writeValues(); 
  BLE.advertise();

  bCharacterstic.setEventHandler(BLERead, readRequest);

  Serial.println("Started advertisment");

  loadcell1.begin(LOADCELL_DOUT_PIN_1, LOADCELL_SCK_PIN_1);
  loadcell2.begin(LOADCELL_DOUT_PIN_2, LOADCELL_SCK_PIN_2);
}


// void readValue(){
//   if (loadcell.is_ready()) {
//     bCharacterstic.writeValue(loadcell.read());
//   } else {
//     Serial.println("ERROR: HX711 not found.");
//   }
// }

void writeValues(){
  bCharacterstic.writeValue(loadcellValues, sizeof(loadcellValues));
}

void readRequest(BLEDevice central, BLECharacteristic characteristic) {
  if (loadcell1.is_ready()) {
    loadcellValues[0] = loadcell1.read(); 
    Serial.println(loadcellValues[0]);
  } else {
    Serial.println("ERROR: Load cell 1 not ready.");
    return;
  }

  if (loadcell2.is_ready()) {
    loadcellValues[1] = loadcell2.read(); 
    Serial.println(loadcellValues[1]);
  } else {
    Serial.println("ERROR: Load cell 2 not ready.");
    return;
  }

  writeValues();
}

void loop() {
  BLEDevice central = BLE.central();
  Serial.println("- Looking for central device...");
  delay(500);

  if (central) {
    Serial.println("* Connected to central device!");
    Serial.print("* Device MAC address: ");
    Serial.println(central.address());
    Serial.println(" ");

    while (central.connected()) {
      BLE.poll();
      // readValue();
      // delay(150);
    }
    
    Serial.println("* Disconnected to central device!");
  }
}
