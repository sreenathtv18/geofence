//
//  GeofencingModel.swift
//  Geofencing Demo
//
//  Created by Sreenath on 17/12/19.
//  Copyright © 2019 Sreenath. All rights reserved.
//

import CoreLocation


struct Coordinate {
    
    let latitude: CLLocationDegrees
    let longitude: CLLocationDegrees
    let radius: CLLocationDistance
    let identifier: String

}

class CircularRegion {
    
    var coordinate: Coordinate
    var distance: Double = 0.0
    
    lazy var region: CLCircularRegion = { [unowned self] in
        
        let geofenceRegionCenter = CLLocationCoordinate2DMake(coordinate.latitude, coordinate.longitude)
        let geofenceRegion = CLCircularRegion(center: geofenceRegionCenter,
                                              radius: coordinate.radius,
                                              identifier: coordinate.identifier)
        return geofenceRegion
    }()
    
    init(location: Coordinate) {
        self.coordinate = location
    }
    
    static func loadDummyData() -> [CircularRegion] {
        // Dummy data
        let region1 = CircularRegion(location: Coordinate(latitude: 10.015142, longitude: 76.345530, radius: 100, identifier: "1"))
        let region2 = CircularRegion(location: Coordinate(latitude: 10.015142, longitude: 76.345530, radius: 100, identifier: "2"))
        let region3 = CircularRegion(location: Coordinate(latitude: 9.994811, longitude: 76.353301, radius: 100, identifier: "3"))
        let region4 = CircularRegion(location: Coordinate(latitude: 9.998886, longitude: 76.353301, radius: 100, identifier: "4"))
        let region5 = CircularRegion(location: Coordinate(latitude: 10.015718, longitude: 76.364375, radius: 100, identifier: "5"))
        
        return [region1, region2, region3, region4, region5]

    }
}
