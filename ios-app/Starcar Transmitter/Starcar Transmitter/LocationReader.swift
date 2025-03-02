//
//  LocationReader.swift
//  Starcar Transmitter
//
//  Created by Patrick Eichler on 2/16/25.
//

import Combine
import CoreLocation

// Implemented from Kilo Loco
class LocationReader: NSObject, CLLocationManagerDelegate, ObservableObject{
    
    var onUpdate: ((Double, Double) -> Void)?
    
    private lazy var manager: CLLocationManager = {
        let man = CLLocationManager()
        man.desiredAccuracy = kCLLocationAccuracyBest
        man.delegate = self
        return man
    }()
    
    func isAuthorized() -> Bool{
        return manager.authorizationStatus == .authorizedWhenInUse || manager.authorizationStatus == .authorizedAlways
    }
    
    func requestLocation(){
        guard isAuthorized() == false else {return}
        
        switch manager.authorizationStatus{
        case .notDetermined:
            manager.requestWhenInUseAuthorization()
        default:
            print("Location permission change needed!")
        }
    }
    
    func startUpdates(){
        guard isAuthorized() else {
            print("ERROR: No permision given to location")
            return
        }
        
        manager.startUpdatingLocation()
    }
    
    func stopUpdates(){
        self.manager.stopUpdatingLocation()
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let location = locations.last else {return}
        onUpdate?(location.coordinate.latitude, location.coordinate.longitude)
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: any Error) {
        print("ERROR in recieving lcoation \(error)")
    }
}
