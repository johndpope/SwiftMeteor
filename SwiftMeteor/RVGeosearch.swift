//
//  RVGeosearch.swift
//  SwiftMeteor
//
//  Created by Neil Weintraut on 1/20/17.
//  Copyright © 2017 Neil Weintraut. All rights reserved.
//

import Foundation
import CoreLocation

/*
class RVQuery {
    enum Keys: String {
        case near = "$near"
    }
}
 */

class RVGeosearch {
    
    var latitude: CLLocationDegrees?  = nil
    var longitude: CLLocationDegrees? = nil
    var radius: CLLocationDistance = 0.0
    let minDistance: CLLocationDistance = 0.0
    let scalar: CLLocationDistance = 1000.0
    
    init(latitude: CLLocationDegrees?, longitude: CLLocationDegrees?, radius: CLLocationDistance = 1000.0) {
        self.latitude = latitude
        self.longitude = longitude
    }
    // https://docs.mongodb.com/manual/core/2dsphere/
    var nearQueryTerm: [String : AnyObject]? {
        get {
            if let latitude = self.latitude {
                if let longitude = self.longitude {
                    let coordinates = [longitude as Double, latitude as Double]
                    var geometry = [String : AnyObject] ()
                    geometry[RVGeoJSONField.type.rawValue] = RVGeoJSONObjects.Point.rawValue as AnyObject
                    geometry[RVGeoJSONField.coordinates.rawValue] = coordinates as AnyObject
                    var near = [String: AnyObject]()
                    near[RVGeometrySpecifier.geometry.rawValue] = geometry as AnyObject
                    near[RVGeometrySpecifier.maxDistance.rawValue] = Double(self.radius * self.scalar) as AnyObject
                    near[RVGeometrySpecifier.minDistance.rawValue] = Double(self.minDistance * self.scalar) as AnyObject
                    return [RVGeospatialQueryOperator.near.rawValue : near as AnyObject]
                    
                }
            }
            return nil
        }
    }
    var recordDictionary: [String: AnyObject]? {
        var dictionary = [String : AnyObject]()
        if let latitude = self.latitude {
            if let longitude = self.longitude {
                dictionary[RVGeoJSONField.type.rawValue] = RVGeoJSONObjects.Point.rawValue as AnyObject
                dictionary[RVGeoJSONField.coordinates.rawValue] = [Double(longitude) , Double(latitude)] as AnyObject
                return dictionary
            }
        }
        return nil
    }
}

