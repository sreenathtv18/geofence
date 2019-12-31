//
//  GeofencingProtocol.swift
//  Geofencing Demo
//
//  Created by Sreenath on 17/12/19.
//  Copyright © 2019 Sreenath. All rights reserved.
//

import CoreLocation


protocol GeofencingProtocol: class {
    func didEnterRegion()
    func didExitRegion()
    func getLatestCoordiante(location: CLLocation)
}
