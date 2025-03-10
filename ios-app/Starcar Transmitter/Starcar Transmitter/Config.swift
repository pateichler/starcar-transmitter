//
//  Config.swift
//  Starcar Transmitter
//
//  Created by Patrick Eichler on 2/14/25.
//

import Foundation
import CoreBluetooth

struct Config{
    let targetServiceUUID: String
    let targetCharacteristicUUID: String
    let dataRefreshInterval: TimeInterval
    let prodServerURL: URL
    let prodServerDomain: String
    let devServerURL: URL
    let devServerDomain: String
    let sensorBufferSize: Int
}

private let prodDomain = "api.star-car.net"
private let devDomain = "192.168.0.101:5050"

let config = Config(
    targetServiceUUID: "A07498CA-AD9B-475E-950D-16F1FBE7E8CD",
    targetCharacteristicUUID: "51FF12BB-3ED8-46E5-B4F9-D64E2FEC021B",
    dataRefreshInterval: TimeInterval(0.150),
    prodServerURL: URL(string: "https://\(prodDomain)")!,
    prodServerDomain: prodDomain,
    devServerURL: URL(string: "http://\(devDomain)")!,
    devServerDomain: devDomain,
    sensorBufferSize: 100
)
