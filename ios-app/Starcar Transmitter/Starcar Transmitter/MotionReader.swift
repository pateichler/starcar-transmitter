//
//  MotionReader.swift
//  Starcar Transmitter
//
//  Created by Patrick Eichler on 2/14/25.
//

import CoreMotion
import UIKit

class MotionReader: ObservableObject {
    private let manager = CMMotionManager()
    
    @Published var accel: CMAcceleration = CMAcceleration(x:0, y:0, z:0)
    
    init() {
        if manager.isDeviceMotionAvailable {
            manager.startDeviceMotionUpdates()
        } else {
            print("Device motion not available")
        }
    }
    
    func measure() {
        if let data = manager.deviceMotion {
            accel = data.userAcceleration
        }
    }

    func stop() {
        manager.stopDeviceMotionUpdates()
    }

    deinit {
        stop()
    }
}
