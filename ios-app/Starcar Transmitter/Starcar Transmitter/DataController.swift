//
//  DataController.swift
//  Starcar Transmitter
//
//  Created by Patrick Eichler on 2/14/25.
//

import Foundation
import SocketIO

struct SensorData: Codable{
    var timeStamp: Int
    
    var accelX : Double
    var accelY : Double
    var accelZ : Double
    
    var gauge1: Int32
    var gauge2: Int32
}

struct TelemetryData: Codable{
    var timeStamp: Int
    
    var latt: Double
    var lng: Double
}

struct DataMessage: Codable{
    var missionID: Int
    var sensorData: [SensorData]
    var telemetryData: [TelemetryData]
}

struct Mission : Codable{
    var missionID: Int
}

// TODO: Remove hack of unchecked sendable
class DataController : ObservableObject, @unchecked Sendable {
    static let instance = DataController()
    
    var bluetoothReader: BluetoothReader
    var motionReader: MotionReader
    var locationReader: LocationReader
    
    var socketManager: SocketManager
    var socket : SocketIOClient?
    var sensorDataBuffer = [SensorData]()
    var telemetryDataBuffer = [TelemetryData]()
    
    @Published var recording = false
    @Published var isPaused = false
    @Published var isRecap = false
    @Published var isFinished = false
    var curMission : Mission?
    
    private var timer = Timer()
    private var starTime: Int?
    
    init (){
        self.bluetoothReader = BluetoothReader( targetServiceUUID: config.targetServiceUUID, targetCharacteristicUUID: config.targetCharacteristicUUID)
        self.motionReader = MotionReader()
        self.locationReader = LocationReader()

        self.socketManager = SocketManager(socketURL: config.serverURL)
        
        self.bluetoothReader.onReceiveData = record
        self.locationReader.onUpdate = locationUpdate
        self.locationReader.requestLocation()
    }
    
    func locationUpdate(latt: Double, lng: Double){
        guard recording && isPaused == false else {return}
        
        self.telemetryDataBuffer.append(TelemetryData(timeStamp: self.getTimeStamp(), latt: latt, lng: lng))
    }
    
    func measure(){
        self.bluetoothReader.measure()
//        self.motionReader.measure()
    }
    
    func milliEpochTime() -> Int{
        return Int(Date().timeIntervalSince1970 * 1000)
    }
    
    func setStartTime() {
        self.starTime = self.milliEpochTime()
    }
    
    func getTimeStamp() -> Int{
        guard let start = self.starTime else {return 0}
        
        return milliEpochTime() - start
    }
    
    func record(){
        self.motionReader.measure()
        
        sensorDataBuffer.append(SensorData(timeStamp: self.getTimeStamp(), accelX: self.motionReader.accel.x, accelY: self.motionReader.accel.y, accelZ: self.motionReader.accel.z, gauge1: self.bluetoothReader.dataVal, gauge2: 0))
        
        if sensorDataBuffer.count > config.sensorBufferSize{
            sendData()
        }
        
        // TODO: CHECK if we need this
        objectWillChange.send()
    }
    
    func sendData(ackCallback: ((Array<Any>)->Void)? = nil){
        guard let s = self.socket else {return}
        
        let dataMessasge = DataMessage(missionID: self.curMission!.missionID, sensorData: sensorDataBuffer, telemetryData: telemetryDataBuffer)
        
        let encoder = JSONEncoder()
        let data = try! encoder.encode(dataMessasge)
        let json = String(data: data, encoding: String.Encoding.utf8)!
         
        print("Sending data")
        if ackCallback != nil{
            s.emitWithAck("stream-data", json).timingOut(after: 0, callback: ackCallback!)
        }else{
            s.emit("stream-data", json)
        }
        
        sensorDataBuffer.removeAll(keepingCapacity: true)
        telemetryDataBuffer.removeAll(keepingCapacity: true)
    }
    
    func newRecording(){
        recording = true
        
        var request = URLRequest(url: config.serverURL.appendingPathComponent("/mission/create"))
        request.httpMethod = "POST"
        
        URLSession.shared.dataTask(with: request) { (data, response, error) in
            guard let data = data else {return}
            
            //TODO: Error checks
            let result = try! JSONDecoder().decode(Mission.self, from: data)
            self.curMission = result
            print("Starting mission: \(self.curMission!.missionID)")
            self.startSocketConnection()
        }.resume()
    }
    
    func startSocketConnection(){
        let options = SocketIOClientOption.extraHeaders(["Authorization": "Bearer \(APIKeyManager.instance.apiKey!)"])
        self.socketManager.config = []
        self.socketManager.setConfigs([options])
        self.socket = socketManager.defaultSocket
        
        guard let s = self.socket else {return}
        
        s.on(clientEvent: .connect) {data, ack in
            print("Socket connected!!!")
            self.resumeRecording()
            self.setStartTime()
        }
        
        s.on(clientEvent: .disconnect) { data, ack in
            print("Socket disconnected event!")
        }
        
        s.connect()
    }
    
    func resumeRecording(){
        print("Started recording")
        guard timer.isValid == false else {return}
        
        isPaused = false
        self.locationReader.startUpdates()
        timer = Timer.scheduledTimer(withTimeInterval: config.dataRefreshInterval, repeats: true) { _ in
            self.measure()
        }
    }
    
    func pauseRecording(){
        isPaused = true
        self.timer.invalidate()
        self.locationReader.stopUpdates()
    }
    
    func stopRecording(){
        pauseRecording()
        
        recording = false
        isRecap = true
        
        if self.sensorDataBuffer.count > 0 || self.telemetryDataBuffer.count > 0{
            sendData(){data in
                self.closeSocketConnection()
            }
        }else{
            self.closeSocketConnection()
        }
    }
    
    func closeSocketConnection(){
        guard let s = self.socket else {return}
        
        let json = try! String(data: JSONEncoder().encode(self.curMission), encoding: String.Encoding.utf8)!
        s.emitWithAck("stop-stream", json).timingOut(after: 0) { data in
            print("Socket disconnect!")
//            s.disconnect()
            self.socketManager.disconnect()
            s.removeAllHandlers()
            self.socket = nil
        }
        
        isFinished = true
    }
    
    func backToHome(){
        isRecap = false
        isFinished = false
    }
}
