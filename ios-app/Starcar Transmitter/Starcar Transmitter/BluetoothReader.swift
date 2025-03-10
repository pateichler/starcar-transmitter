//
//  BluetoothReader.swift
//  Starcar Transmitter
//
//  Created by Patrick Eichler on 2/14/25.
//

import Foundation
import CoreBluetooth

class BluetoothReader: NSObject, ObservableObject{
    private let manager : CBCentralManager
    
    private var targetServiceUUID: CBUUID
    private var targetCharacteristicUUID: CBUUID
     
    
    @Published var gauge1: Int32 = 0
    @Published var gauge2: Int32 = 0
    @Published var ready: Bool = false
    
    var peripheral: CBPeripheral?
    var characterstic: CBCharacteristic?
    
    var onReady: (()->Void)?
    var onReceiveData: (()->Void)?
    
    init(targetServiceUUID: String, targetCharacteristicUUID: String){
        print("Init!!!")
        self.targetServiceUUID = CBUUID(string: targetServiceUUID)
        self.targetCharacteristicUUID = CBUUID(string: targetCharacteristicUUID)
//        self.onReady = onReady
        
        self.manager = CBCentralManager()
        super.init()
        self.manager.delegate = self
    }
}

extension BluetoothReader: CBCentralManagerDelegate{
    func centralManagerDidUpdateState(_ central: CBCentralManager) {
        print("Update state \(central.state)")
        if central.state == .poweredOn{
            central.scanForPeripherals(withServices: [targetServiceUUID])
        }
    }
    
    func centralManager(_ central: CBCentralManager, didDiscover peripheral: CBPeripheral, advertisementData: [String : Any], rssi RSSI: NSNumber) {
        guard peripheral.name != nil else {return}
        
        self.peripheral = peripheral
        self.manager.stopScan()
        self.manager.connect(peripheral)
        
        print("Discovered peripheral!")
    }
    
    func centralManager(_ central: CBCentralManager, didConnect peripheral: CBPeripheral) {
        self.peripheral?.delegate = self
        self.peripheral?.discoverServices([targetServiceUUID])
    }
    
    func centralManager(_ central: CBCentralManager, didFailToConnect peripheral: CBPeripheral, error: (any Error)?) {
        print("FAILED to connect!!!!")
    }
    
    func centralManager(_ central: CBCentralManager, didDisconnectPeripheral peripheral: CBPeripheral, error: (any Error)?) {
        print("Peripheral disconnect!")
        manager.cancelPeripheralConnection(peripheral)
        self.ready = false
    }
}

extension BluetoothReader: CBPeripheralDelegate{
    func peripheral(_ peripheral: CBPeripheral, didDiscoverServices error: (any Error)?) {
        if let e = error{
            print("Error in in service discovery \(e.localizedDescription)!!!!")
            return
        }
        
        guard let service = peripheral.services?.first else {return}
        
        peripheral.delegate = self
        peripheral.discoverCharacteristics([targetCharacteristicUUID], for: service)
    }
    
    func peripheral(_ peripheral: CBPeripheral, didDiscoverCharacteristicsFor service: CBService, error: (any Error)?) {
        if let e = error{
            print("Error in in characterstic discovery \(e.localizedDescription)!!!!")
            return
        }
        
        guard let characteristic = service.characteristics?.first else {return}
        
        self.characterstic = characteristic
        
        self.onReady?()
        self.ready = true
    }
    
    func peripheral(_ peripheral: CBPeripheral, didUpdateValueFor characteristic: CBCharacteristic, error: (any Error)?) {
        if let e = error{
            print("Error in reading characteristic \(e.localizedDescription)!!!!")
            return
        }
        
        
        guard let data = characteristic.value else {return}
        (self.gauge1, self.gauge2) = data.withUnsafeBytes{ pointer in
            let val1 = pointer.load(as: Int32.self).littleEndian
            let val2 = pointer.load(fromByteOffset: MemoryLayout<Int32>.size, as: Int32.self).littleEndian
            return (val1, val2)
        }
        
        self.onReceiveData?()
    }
    
    func measure(){
        if Settings.instance.mockDevice {
            self.gauge1 = Int32.random(in: 1..<100)
            self.gauge2 = Int32.random(in: 1..<100)
            self.onReceiveData?()
            return
        }
        
        self.peripheral?.readValue(for: self.characterstic!)
    }
}
