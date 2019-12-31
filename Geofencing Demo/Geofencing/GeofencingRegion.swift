//
//  GeofencingHelper.swift
//  Geofencing Demo
//
//  Created by Sreenath on 11/12/19.
//  Copyright © 2019 Sreenath. All rights reserved.
//

import Foundation
import CoreLocation




class GeofencingRegion: NSObject, CLLocationManagerDelegate {
    
    // Declarations
    static let shared = GeofencingRegion()

    var allRegions: [CircularRegion] = []
    lazy var locationManager: CLLocationManager? = { [weak self] in
        let locationManager = CLLocationManager()
        locationManager.desiredAccuracy = kCLLocationAccuracyKilometer
        locationManager.delegate = self
        return locationManager
    }()
    private var currentLocation: CLLocation? {
        didSet {
            evaluateClosestRegions()
        }
    }
    weak var delegate: GeofencingProtocol?
    private var enteredRegion: CLRegion?
    
    // MARK: Life Cycle
    override init() {
        
        super.init()
        //ask for location permission
        GeofencePermission.enableLocationServices(locationManager: locationManager)
        loadMonitoringRegions()
    }
    
    
    func startUpdatingLocation() {

        locationManager?.startUpdatingLocation()
    }
    
    
    
    func stopUpdatingLocation() {
        
        locationManager?.stopUpdatingLocation()
    }
    
    
    
    private func loadMonitoringRegions() {
        
        // Dummy data
        allRegions = CircularRegion.loadDummyData()
        
        /* Create a region centered on desired location,
         choose a radius for the region (in meters)
         choose a unique identifier for that region */
        for circularRegion in allRegions {
            let geofenceRegion = circularRegion.region
            geofenceRegion.notifyOnEntry = true
            geofenceRegion.notifyOnExit = true
            locationManager?.startMonitoring(for: geofenceRegion)
        }
    }
    
    
    
    private func evaluateClosestRegions() {
        
        //Calulate distance of each region's center to currentLocation
        allRegions = allRegions.map({ storableRegion in
            let distance = currentLocation?.distance(from: CLLocation(latitude: storableRegion.coordinate.latitude, longitude: storableRegion.coordinate.longitude))
            storableRegion.distance = distance ?? 0.0
            return storableRegion
        })


        //sort and get 20 closest
        let twentyNearbyRegions = allRegions
            .sorted{ $0.distance < $1.distance }
            .prefix(20)

        stopMonitoringRegion()
        startMonitorRegion(twentyNearbyRegions: twentyNearbyRegions)
    }
    
    
    
    func startMonitorRegion(twentyNearbyRegions: ArraySlice<CircularRegion>) {

        twentyNearbyRegions.forEach {
            locationManager?.startMonitoring(for: $0.region)
            locationManager?.requestState(for: $0.region)
        }
    }
    
    
    
    func stopMonitoringRegion() {
        
        // Remove all regions you were tracking before
        guard let monitoredRegions = locationManager?.monitoredRegions else {
            return
        }
        
        for region in monitoredRegions {
            locationManager?.stopMonitoring(for: region)
        }
    }
}






// Location manager delegate methods
extension GeofencingRegion {
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        
        print("didUpdateLocations", locations.first?.coordinate.latitude,locations.first?.coordinate.longitude)
        currentLocation = locations.first
        delegate?.getLatestCoordiante(location: currentLocation!)
    }
    
    
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        
        print("didFailWithError",error)
    }
    
    
    
    func locationManager(_ manager: CLLocationManager, didEnterRegion region: CLRegion) {

        enterGeofence(geofence: region, manager: manager)
    }



    func locationManager(_ manager: CLLocationManager, didExitRegion region: CLRegion) {

        exitGeofence(geofence: region, manager: manager)
    }
    
    
    
    func enterGeofence(geofence: CLRegion, manager: CLLocationManager) {
    
        print("didEnterRegion", geofence.identifier)
        enteredRegion = geofence
        delegate?.didEnterRegion()
    }
    
    
    
    func exitGeofence(geofence: CLRegion, manager: CLLocationManager) {
    
        print("didExitRegion", geofence.identifier)
        if enteredRegion == geofence {
            enteredRegion = nil
            currentLocation = manager.location
            delegate?.didExitRegion()
        }
    }
}
