//
//  RVGooglePlace.swift
//  SwiftMeteor
//
//  Created by Neil Weintraut on 1/20/17.
//  Copyright © 2017 Neil Weintraut. All rights reserved.
//

import UIKit
import CoreLocation


class RVGooglePlace {
    enum Keys: String {
        case name       = "name"            //0
        case vicinity   = "vicinity"        //0  street "495 Geary Street, San Francisco"
        case geometry   = "geometry"        //0
        case reference  = "reference"       //0
        case icon       = "icon"            //0 a URL
        case id         = "id"              //0
        case place_id   = "place_id"        //0
        case scope      = "scope"           //0 "GOOGLE"
        case types      = "types"           //0   an array of strings like "locality" , "political", "lodging", "points_of_interest", "establishment"
        case rating     = "rating"          //0   number like 4.1
        case price_level = "price_level"    //0   number like 4
        case opening_hours = "opening_hours" //0
        case photos     = "photos"
        
        case location   = "location"         // 1 geometry
        case viewport   = "viewport"        // 1 geometry
        case lat        = "lat"             // 2 geometry.location  also 3 geometry.viewport.[northeast, southwest] number like "37.787
        case lng        = "lng"             // 2 geometry.location  also 3 geometry.viewport.[northeast, southwest]
        case northeast  = "northeast"       // 2 geometry.viewport
        case southwest  = "sorthwest"       // 2 gemoetry.viewport
        
        case photo_reference = "photo_reference" // 2 photos[index]
        case height     = "height"          // 2 photos[index]
        case width      = "width"           // 2 photos[index]
        case html_attributions = "html_attributions" // 2 photos[index]
        
        case open_now   = "open_now"        // 1 opening_hours Integer
        case weekday_text = "weekday_text"  // 1 opening_hours  Array
        
        
    }
    var name: String? = nil
    var address: String? = nil
    var coordinate: CLLocationCoordinate2D? = nil
    var placeType: String? = nil
    var photoReference: String? = nil
    var photo: UIImage? = nil
    
    init(dictionary:[String : AnyObject], acceptedTypes: [String])
    {
        if let name = dictionary[Keys.name.rawValue] as? String { self.name = name }
        if let vicinity = dictionary[Keys.vicinity.rawValue] as? String { self.address = vicinity }
        if let geometry = dictionary[Keys.geometry.rawValue] as? [String : AnyObject] {
            if let latLng = geometry[Keys.location.rawValue] as? [String : NSNumber] {
                if let lat = latLng[Keys.lat.rawValue] {
                    if let lng = latLng[Keys.lng.rawValue] {
                        self.coordinate = CLLocationCoordinate2DMake(CLLocationDegrees(lat), CLLocationDegrees(lng))
                    }
                }
            }
        }
        if let photos = dictionary[Keys.photos.rawValue] as? [[String: AnyObject]] {
            if let photo = photos.first {
                if let reference = photo[Keys.photo_reference.rawValue] {
                    self.photoReference = reference.string
                }
            }
        }
        var foundType = "unknown"
        let possibleTypes = acceptedTypes.count > 0 ? acceptedTypes : ["bakery", "bar", "cafe", "grocery_or_supermarket", "restaurant"]
        if let types = dictionary[Keys.types.rawValue] as? [String ] {
            for type in types {
                if possibleTypes.contains(type) {
                    foundType = type
                    break
                }
            }
        }
        self.placeType = foundType
        /*
         let json = JSON(dictionary)
         name = json["name"].stringValue
         address = json["vicinity"].stringValue
         
         let lat = json["geometry"]["location"]["lat"].doubleValue as CLLocationDegrees
         let lng = json["geometry"]["location"]["lng"].doubleValue as CLLocationDegrees
         coordinate = CLLocationCoordinate2DMake(lat, lng)
         
         photoReference = json["photos"][0]["photo_reference"].string
         
         var foundType = "restaurant"
         let possibleTypes = acceptedTypes.count > 0 ? acceptedTypes : ["bakery", "bar", "cafe", "grocery_or_supermarket", "restaurant"]
         
         for type in json["types"].arrayObject as! [String] {
         if possibleTypes.contains(type) {
         foundType = type
         break
         }
         }
         placeType = foundType
         */
    }
}
