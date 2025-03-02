#include <ArduinoBLE.h>

const char* deviceServiceUuid = "A07498CA-AD9B-475E-950D-16F1FBE7E8CD";
const char* deviceServiceCharacteristicUuid = "51FF12BB-3ED8-46E5-B4F9-D64E2FEC021B";

BLEService bService(deviceServiceUuid); 
BLEIntCharacteristic bCharacterstic(deviceServiceCharacteristicUuid, BLERead | BLEWrite);

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
  bCharacterstic.writeValue(-1);
  BLE.advertise();

  bCharacterstic.setEventHandler(BLERead, readRequest);

  Serial.println("Started advertisment");
}

void readRequest(BLEDevice central, BLECharacteristic characteristic) {
  // central wrote new value to characteristic, update LED
  Serial.println("Characterstic read request");

  int rValue = random(1000);
  // bCharacterstic.writeValue(&rValue, 4);
  bCharacterstic.writeValue(rValue);
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
    }
    
    Serial.println("* Disconnected to central device!");
  }
}
