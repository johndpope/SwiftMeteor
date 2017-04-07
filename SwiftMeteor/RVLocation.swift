//
//  RVLocation.swift
//  SwiftMeteor
//
//  Created by Neil Weintraut on 1/20/17.
//  Copyright © 2017 Neil Weintraut. All rights reserved.
//

import UIKit
import CoreLocation
import GoogleMaps
import GooglePlaces

class RVGeocodeTerm {
    var types = [String]()
    var value: AnyObject
    init(types: [String], value: AnyObject) {
        self.value = value
        self.types = types
    }
}
class RVLocation: RVInterest {
    enum GeocodeKeys: String {
        case formatted_address = "formatted_address"
        case address_components = "address_components"
        
    }
    override class func collectionType() -> RVModelType { return RVModelType.location }
//    override class var insertMethod: RVMeteorMethods { get { return RVMeteorMethods.InsertTask } }
//    override class var updateMethod: RVMeteorMethods { get { return RVMeteorMethods.UpdateTask } }
//    override class var deleteMethod: RVMeteorMethods { get { return RVMeteorMethods.DeleteTask } }
//    override class var findMethod: RVMeteorMethods { get { return RVMeteorMethods.FindTask}}
//    override class var bulkQueryMethod: RVMeteorMethods { get { return RVMeteorMethods.BulkTask } }
 
    private var rawPlaces = [String: AnyObject]()
    private var gmsAddress: GMSAddress? = nil
    var gmsPlace: GMSPlace? = nil
    var photo: UIImage? = nil
    override init(fields: [String: AnyObject]){
        super.init(fields: fields)
    }
    init(rawPlaces: [String: AnyObject]) {
        super.init()
        absorbPlaces(rawPlaces: rawPlaces)
        self.geocoded = true
    }
    init(googlePlace: GMSPlace) {
        super.init()
        absorbPlace(place: googlePlace)
        self.geocoded = true
        let _ = self.generateGeoIndex()
    }
    init(gmsAddress: GMSAddress) {
        super.init()
        absorbGMSAddress(gmsAddress: gmsAddress)
        self.geocoded = true
        let _ = self.generateGeoIndex()
    }
    init(geocode: [String : AnyObject]) {
        super.init()
        absorbGeocode(geocode: geocode)
        self.geocoded = true
    }
    
    required init(id: String, fields: NSDictionary?) {
        super.init(id: id , fields: fields)
    }

    private func absorbPlace(place: GMSPlace) {
        self.gmsPlace = place
        self.latitude = place.coordinate.latitude
        self.longitude = place.coordinate.longitude
        self.title = place.name
        if let components: [GMSAddressComponent] = place.addressComponents {
            for component in components {
                if component.type == "street_number" {
                    self.street_number = component.name
                } else if component.type == "route" { // Address
                    self.route = component.name
                } else if component.type == "neighborhood" { // Central Portola Valley
                    self.neighborhood = component.name
                } else if component.type == "locality" { // Portola Valley
                    self.locality = component.name
                    self.city = component.name
                } else if component.type == "administrative_area_level_1" { // state
                    self.state = component.name
                    self.administrativeArea = component.name
                } else if component.type == "administrative_area_level_2" { // county
                    self.administrativeArea2 = component.name
                } else if component.type == "country" {
                    self.country = component.name
                } else if component.type == "postal_code" {
                    self.postalCode = component.name
                } else if component.type == "postal_code_suffix" {
                    self.postalCodeSuffix = component.name
                } else if component.type == "subpremise" { // such as "1b"
            
                
                } else {
                    print("IN \(self.classForCoder).absorbPlace, got component that was unaddressed \(component.type) : \(component.name)")
                }
            }
        }
        if let string = place.formattedAddress {
            self.fullAddress = string
            self.lines  = [string]
        }
        self.placeId = place.placeID
        if let url = place.website { self.websiteString = url.absoluteString }
        if let phone = place.phoneNumber { self.phoneNumber = phone }
        let _ = self.generateGeoIndex()
    }
    
    private func absorbGeocode(geocode: [String: AnyObject]) {
        var title = ""
        if let geometry = geocode[RVGooglePlace.Keys.geometry.rawValue] as? [String : AnyObject] {
            if let location = geometry[RVGooglePlace.Keys.location.rawValue] as? [String : NSNumber] {
                //print("In \(self.classForCoder).geometry is \(geometry) and location is \(location)  -----------------")
                if let latitude = location[RVGooglePlace.Keys.lat.rawValue] {
                    if let longitude = location[RVGooglePlace.Keys.lng.rawValue] {
                        self.latitude = latitude.doubleValue
                        self.longitude = longitude.doubleValue
                    }
                }
            }
        } else {
            print("In \(self.classForCoder).absorbGeocode, geometry did not cast: \(geocode[RVGooglePlace.Keys.geometry.rawValue] ?? "no Key" as AnyObject) ---------------")
        }
        if let formattedAddress = geocode[GeocodeKeys.formatted_address.rawValue] as? String {
            self.lines = [formattedAddress]
            self.fullAddress = formattedAddress
        }
        if let address_components = geocode[GeocodeKeys.address_components.rawValue] as? [[String:AnyObject]] {
            var bigArray = [ RVGeocodeTerm]()
            for index in (0..<address_components.count) {
                //  print("***********************************")
                let component = address_components[index]
                var types = [String]()
                var count: Int = 0
                for (key, value) in component {
                    //    print("Address component: \(key) : \(value)")
                    //    print("--------------")
                    let mod = count % 3
                    count = count + 1
                    if mod == 0 {
                        if let value = value as? [String] {
                            types = value
                        } else {
                            print("In \(self.classForCoder).absorbGeocode failed casting types \(key):\(value)")
                        }
                    } else if mod == 1 {
                        bigArray.append(RVGeocodeTerm(types: types, value: value))
                    }
                    
                }
            }
            for term in bigArray {
                for type in term.types {
                    if type == "street_number" {
                        if let value = term.value as? String {
                            title = "\(value)"
                            self.street_number = value
                        }
                        // do nothing "1600"
                    } else if type == "route" {
                        if let value = term.value as? String {
                            title = "\(title) \(value)"
                            self.route = value
                        }
                        // do nothing "Ampitheatre Way"
                    } else if type == "locality" {
                        if let city = term.value as? String {
                            self.city = city
                        }
                    } else if type == "administrative_area_level_2" {
                        // do nothing "Santa Clara County"
                    } else if type == "administrative_area_level_1" {
                        if let state = term.value as? String {
                            self.state = state
                        }
                    } else if type == "country" {
                        if let country = term.value as? String {
                            self.country = country
                        }
                    } else if type == "postal_code" {
                        if let postal_code = term.value as? String {
                            self.postalCode = postal_code
                        }
                    } else if type == "political" {
                        // do nothing
                    } else if type == "subpremise" {
                        // do nothing
                    } else {
                        print("In RVLocation.absorbGeocode no match \(type) \(term.value)")
                    }
                }
            }
        } else {
            print("RVLocation.absorbGeocode Didnt get address components")
        }
        if let string = geocode[RVGooglePlace.Keys.place_id.rawValue] as? String { self.placeId = string }
        if title != "" { self.title = title }
    }
    private func absorbGMSAddress(gmsAddress: GMSAddress) {
        if (gmsAddress.coordinate.latitude != kCLLocationCoordinate2DInvalid.latitude) &&  (gmsAddress.coordinate.longitude != kCLLocationCoordinate2DInvalid.longitude){
            let coordinate = gmsAddress.coordinate
            self.latitude = coordinate.latitude
            self.longitude = coordinate.longitude
        }
        if let string = gmsAddress.thoroughfare {self.thoroughfare = string }  // Street number and name
        if let string = gmsAddress.locality {self.locality = string }  // Locality or city
        if let string = gmsAddress.subLocality {self.subLocality = string }
        if let string = gmsAddress.administrativeArea {self.administrativeArea = string } // Region or State or Administrative area
        if let string = gmsAddress.postalCode {self.postalCode = string }
        if let string = gmsAddress.country {self.country = string }
        if let array  = gmsAddress.lines {self.lines = array }
        self.gmsAddress = gmsAddress
    }
    private func absorbPlaces(rawPlaces: [String: AnyObject]) {
        self.rawPlaces = rawPlaces
        if let geometry = rawPlaces[RVGooglePlace.Keys.geometry.rawValue] as? [String : AnyObject] {
            if let location = geometry[RVGooglePlace.Keys.location.rawValue] as? [String : NSNumber] {
                if let latitude = location[RVGooglePlace.Keys.lat.rawValue] {
                    if let longitude = location[RVGooglePlace.Keys.lng.rawValue] {
                        self.latitude = latitude.doubleValue
                        self.longitude = longitude.doubleValue
                    }
                }
            }
        }
        if let string = rawPlaces[RVGooglePlace.Keys.reference.rawValue] as? String { self.reference = string }
        if let string = rawPlaces[RVGooglePlace.Keys.icon.rawValue] as? String {
            if let _ = URL(string: string) { self.iconURLString = string }
        }
        if let string = rawPlaces[RVGooglePlace.Keys.vicinity.rawValue] as? String { self.fullAddress = string }
        if let string = rawPlaces[RVGooglePlace.Keys.name.rawValue] as? String { self.title = string }
        if let string = rawPlaces[RVGooglePlace.Keys.place_id.rawValue] as? String { self.placeId = string }
        if let string = rawPlaces[RVGooglePlace.Keys.id.rawValue] as? String { self.record_id = string }
        if let types = rawPlaces[RVGooglePlace.Keys.types.rawValue] as? [String] { self.types = types }
        if let photos = rawPlaces[RVGooglePlace.Keys.photos.rawValue] as? [[String : AnyObject]] {
            if let photo = photos.first {
                //print("---------- In RVLocation.absorbPlaces..... have photo 8888888888")
                let image = RVImage()
                if let height = photo[RVGooglePlace.Keys.height.rawValue] as? NSNumber { image.height = CGFloat(height.doubleValue) }
                if let width = photo[RVGooglePlace.Keys.width.rawValue] as? NSNumber { image.width = CGFloat(width.doubleValue) }
                if let string = photo[RVGooglePlace.Keys.photo_reference.rawValue] as? String { image.photo_reference = string }
                self.image = image
            } else {
                
            }
        }
        
        self.dirties = [String: AnyObject]()
        
    }
    var coordinate: CLLocationCoordinate2D? {
        get {
            if let latitude = self.latitude {
                if let longitude = self.longitude {
                    return CLLocationCoordinate2DMake(latitude , longitude)
                }
            }
            return nil
        }
        set {
            if let coordinate = newValue {
                self.latitude = coordinate.latitude
                self.longitude = coordinate.longitude
            } else {
                self.latitude = nil
                self.longitude = nil
            }
        }
    }
    var geometry: [String : AnyObject]? {
        get {
            if let dictionary = objects[RVKeys.geometry.rawValue] as? [String : AnyObject] { return dictionary }
            return nil
        }
        set {
            updateAnyObject(key: .geometry, value: newValue as AnyObject , setDirties: true)
        }
    }
    var latitude: CLLocationDegrees? {
        get { return getNSNumber(key: .latitude) as? CLLocationDegrees }
        set {
            if let value = newValue {
                updateNumber(key: .latitude, value: NSNumber(value: Double(value)) , setDirties: true)
            } else {
                updateNumber(key: .latitude, value: nil , setDirties: true)
            }
        }
    }
    var longitude: CLLocationDegrees? {
        get { return getNSNumber(key: .longitude) as? CLLocationDegrees }
        set {
            if let value = newValue {
                updateNumber(key: .longitude, value: NSNumber(value: Double(value)) , setDirties: true)
            } else {
                updateNumber(key: .longitude, value: nil , setDirties: true)
            }
        }
    }
    private func generateGeoIndex() -> [String : AnyObject]? {
        return RVGeosearch(latitude: self.latitude, longitude: self.longitude).recordDictionary
    }
    var geoIndex: [String : AnyObject]? {
        get {
            if let dictionary = objects[RVKeys.geoIndex.rawValue] as? [String : AnyObject] { return dictionary }
            return nil
        }
        set {
            if let dictionary = newValue {
                self.updateAnyObject(key: .geoIndex, value: dictionary as AnyObject, setDirties: true)
            } else {
                self.updateAnyObject(key: .geoIndex, value: NSNull(), setDirties: true)
            }
        }
    }
    var geocoded: Bool? {
        get { return getBool(key: .geocoded) }
        set { updateAnyObject(key: .geocoded, value: newValue as AnyObject, setDirties: true) }
    }
    var fullAddress: String? {
        get { return getString(key: .fullAddress) }
        set { updateString(key: .fullAddress, value: newValue, setDirties: true)}
    }
    var placeId: String? {
        get { return getString(key: .placeId) }
        set { updateString(key: .placeId, value: newValue, setDirties: true)}
    }
    
    var record_id: String? {
        get { return getString(key: .record_id) }
        set { updateString(key: .record_id, value: newValue, setDirties: true)}
    }
    var reference: String? {
        get { return getString(key: .reference) }
        set { updateString(key: .reference, value: newValue, setDirties: true)}
    }
    /** Street number and name. */
    var thoroughfare: String? {
        get { return getString(key: .thoroughfare) }
        set { updateString(key: .thoroughfare, value: newValue, setDirties: true)}
    }
    /** Street NEIL IS THIS USED. */
    var street: String? {
        get { return getString(key: .street) }
        set { updateString(key: .street, value: newValue, setDirties: true)}
    }
    /** Locality or city. */
    var locality: String? {
        get { return getString(key: .locality) }
        set { updateString(key: .locality, value: newValue, setDirties: true)}
    }
    /** Subdivision of locality, district or park. */
    var subLocality: String? {
        get { return getString(key: .subLocality) }
        set { updateString(key: .subLocality, value: newValue, setDirties: true)}
    }
    /** Region/State/Administrative area. */
    var administrativeArea: String? {
        get { return getString(key: .administrativeArea) }
        set { updateString(key: .administrativeArea, value: newValue, setDirties: true)}
    }
    var administrativeArea2: String? {
        get { return getString(key: .administrativeArea2) }
        set { updateString(key: .administrativeArea2, value: newValue, setDirties: true)}
    }
    var postalCode: String? {
        get { return getString(key: .postalCode) }
        set { updateString(key: .postalCode, value: newValue, setDirties: true)}
    }
    var postalCodeSuffix: String? {
        get { return getString(key: .postalCodeSuffix) }
        set { updateString(key: .postalCodeSuffix, value: newValue, setDirties: true)}
    }
    var city: String? {
        get { return getString(key: .city) }
        set { updateString(key: .city, value: newValue, setDirties: true)}
    }
    var state: String? {
        get { return getString(key: .state) }
        set { updateString(key: .state, value: newValue, setDirties: true)}
    }
    var country: String? {
        get { return getString(key: .country) }
        set { updateString(key: .country, value: newValue, setDirties: true)}
    }
    var street_number: String? {
        get { return getString(key: .street_number) }
        set { updateString(key: .street_number, value: newValue, setDirties: true)}
    }
    var route: String? {
        get { return getString(key: .route) }
        set { updateString(key: .route, value: newValue, setDirties: true)}
    }
    var neighborhood: String? {
        get { return getString(key: .neighborhood) }
        set { updateString(key: .neighborhood, value: newValue, setDirties: true)}
    }
    var phoneNumber: String? {
        get { return getString(key: .phoneNumber) }
        set { updateString(key: .phoneNumber, value: newValue, setDirties: true)}
    }
    var lines: [String]? {
        get {
            if let array = objects[RVKeys.lines.rawValue] as? [String] { return array }
            return nil
        }
        set {
            updateAnyObject(key: .lines, value: newValue as AnyObject , setDirties: true)
        }
    }
    var firstLine: String? {
        get {
            if let lines = self.lines { return lines.first}
            return nil
        }
    }
    var iconURLString: String? {
        get {return getString(key: .iconURLString) }
        set { updateString(key: .iconURLString, value: newValue, setDirties: true)}
    }
    var iconURL: URL? {
        get {
            if let raw = self.iconURLString {
                return URL(string: raw)
            } else {
                return nil
            }
        }
        set {
            if let url = newValue {
                self.iconURLString = url.absoluteString
            } else {
                self.iconURLString = nil
            }
            
        }
    }
    var websiteString: String? {
        get {return getString(key: .websiteString) }
        set { updateString(key: .websiteString, value: newValue, setDirties: true)}
    }
    var website: URL? {
        get {
            if let raw = self.websiteString {
                return URL(string: raw)
            } else {
                return nil
            }
            
        }
        set {
            if let url = newValue {
                self.websiteString = url.absoluteString
            } else {
                self.websiteString = nil
            }
            
        }
    }
    var types: [String]? {
        get {
            if let array = objects[RVKeys.types.rawValue] as? [String] { return array }
            return nil
        }
        set {
            updateAnyObject(key: .types, value: newValue as AnyObject , setDirties: true)
        }
    }
    class func fakeIt() -> RVLocation {
        let location = RVLocation(fields: [String:AnyObject]())
        location.modelType = .location
        location.geometry = [ "elmer": "fudd" as AnyObject]
        location.geoIndex = ["index" : 555.6666 as AnyObject]
        location.latitude = 37.92
        location.longitude = -122.123
        location.geocoded = false
        location.fullAddress = "15 Cordova Court, Portola Valley, CA 94028"
        location.placeId = "SomePlaceId"
        location.record_id = "SomeRecordId"
        location.reference = "SomeReference"
        location.thoroughfare = "Some thoroughfare"
        location.street = "15 Cordova Court"
        location.administrativeArea = "Administrative Area"
        location.locality = "Some Locality"
        location.subLocality = "Some SubLocality"
        location.postalCode = "94028"
        location.city = "San Francisco"
        location.state = "CA"
        location.country = "US"
        location.neighborhood  = "Some Neighborhood"
        location.phoneNumber = "6665551212"
        location.lines = ["First Line", "Second Line"]
        location.iconURLString = "https://www.google.com"
        location.websiteString = "https://www.somewebsite.com"
        return location
    }
    override func additionalToString() -> String {
        var output = ""
        if let value = self.title {
            output = "\(output) Title = \(value), "
        } else {
            output = "\(output) <no title>, "
        }
        if let value = self.fullAddress {
            output = "\(output) address = \(value), "
        } else {
            output = "\(output) <no address>, "
        }
        if let latitude = self.latitude {
            output = "\(output) Latitude = \(latitude), "
        } else {
            output = "\(output) <no latitude>, "
        }
        if let value = self.longitude {
            output = "\(output) Longitude = \(value), "
        } else {
            output = "\(output) <no longitude>\n"
        }
        if let value = self.city {
            output = "\(output) city = \(value), "
        } else {
            output = "\(output) <no city>, "
        }
        if let value = self.state {
            output = "\(output) state = \(value), "
        } else {
            output = "\(output) <no state>, "
        }
        if let zip = self.postalCode {
            output = "\(output) zip = \(zip), "
        } else {
            output = "\(output) <no zip>, "
        }
        output = addTerm(term: "Country", input: output, value: self.country)
        output = addTerm(term: "thoroughfare", input: output, value: self.thoroughfare)
        output = addTerm(term: "Locality", input: output , value: self.locality)
        output = addTerm(term: "subLocality", input: output, value: self.subLocality)
        output = addTerm(term: "neighborhood", input: output, value: self.neighborhood)
        output = addTerm(term: "administrativeArea", input: output, value: self.administrativeArea)
        output = addTerm(term: "administrativeArea2 (County)", input: output, value: self.administrativeArea2)
        output = addTerm(term: "fullAddress", input: output, value: self.fullAddress)
        output = addTerm(term: "iconURLString", input: output, value: self.iconURLString)
        output = addTerm(term: "websiteString", input: output, value: self.websiteString)
        output = addTerm(term: "Phone Number", input: output, value: self.phoneNumber)
        output = addTerm(term: "reference", input: output, value: self.reference)
        output = addTerm(term: "record_id", input: output, value: self.record_id)
        output = addTerm(term: "placeId", input: output, value: self.placeId)
        if let types = self.types {
            output = "\(output), types: \(types), "
        } else {
            output = "\(output)<no types>, "
        }
        if let geometry = self.geometry {
            output = "\(output) geometry: \(geometry)"
        } else {
            output = "\(output) <no geometry>, "
        }
        if let image = self.image {
            output = "\(output) -- ImageObject: \(image.toString())"
        } else {
            output = "\(output) < no image>"
        }
        return output
    }
}

