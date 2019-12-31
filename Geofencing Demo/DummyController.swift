//
//  GeofencingHelper.swift
//  Geofencing Demo
//
//  Created by Sreenath on 11/12/19.
//  Copyright © 2019 Sreenath. All rights reserved.
//

import Foundation
import CoreLocation




class GeofencingDummy: NSObject, CLLocationManagerDelegate {
    
    static let shared = GeofencingDummy()
    
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
        let geofenceRegionCenter1 = CLLocationCoordinate2DMake(10.01199577, 76.3666361000)
        let geofenceRegionCenter2 = CLLocationCoordinate2DMake(10.015142, 76.345530)
        let geofenceRegionCenter3 = CLLocationCoordinate2DMake(9.994811, 76.353301)
        let geofenceRegionCenter4 = CLLocationCoordinate2DMake(9.998886, 76.359023)
        let geofenceRegionCenter5 = CLLocationCoordinate2DMake(10.015718, 76.364375)
        let geofenceRegions = [geofenceRegionCenter1, geofenceRegionCenter2, geofenceRegionCenter3, geofenceRegionCenter4, geofenceRegionCenter5]
        
        /* Create a region centered on desired location,
         choose a radius for the region (in meters)
         choose a unique identifier for that region */
        
        
        for (index, geofenceRegionCenter) in geofenceRegions.enumerated() {
            let geofenceRegion = CLCircularRegion(center: geofenceRegionCenter,
                                                  radius: 100,
                                                  identifier: "UniqueIdentifier\(index)")
            geofenceRegion.notifyOnEntry = true
            geofenceRegion.notifyOnExit = true
            locationManager?.startMonitoring(for: geofenceRegion)
        }
    }
    
    
    
    
    private func evaluateClosestRegions() {
        
        //Calulate distance of each region's center to currentLocation
        allRegions = allRegions.map({ storableRegion in
            var circularRegion = storableRegion
            let region =  circularRegion.region
            let distance = currentLocation?.distance(from: CLLocation(latitude: region.center.latitude, longitude: region.center.longitude))
            circularRegion.distance = distance ?? 0.0
            return circularRegion
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
            locationManager?.requestState(for: $0.region
            )

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
extension GeofencingDummy {
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        
        print("didUpdateLocations", locations.first?.coordinate.latitude,locations.first?.coordinate.longitude)
        currentLocation = locations.first
        delegate?.getLatestCoordiante(location: currentLocation!)
    }
    
    
    func locationManager(_ manager: CLLocationManager, didEnterRegion region: CLRegion) {

        enterGeofence(geofence: region, manager: manager)
    }



    func locationManager(_ manager: CLLocationManager, didExitRegion region: CLRegion) {

        exitGeofence(geofence: region, manager: manager)

    }

    
    
//    func locationManager(_ manager: CLLocationManager, didStartMonitoringFor region: CLRegion) {
//        locationManager?.requestState(for: region)
//        locationManager?.perform(#selector(CLLocationManager.requestState(for:)), with: region , afterDelay: 5)
//    }
//
//
//
//    func locationManager(_ manager: CLLocationManager, didDetermineState state: CLRegionState, for region: CLRegion) {
//
//
//        switch state {
//        case .inside:
//            enterGeofence(geofence: region, manager: manager)
//            break
//        case .outside:
//            exitGeofence(geofence: region, manager: manager)
//            break
//        case .unknown:
//            print("Unknown state for geofence:",region)
//            break
//        default:
//            break
//        }
//    }
    
    
    
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
    
    
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        
        print("didFailWithError",error)
    }
}
