//
//  RVGMaps.swift
//  SwiftMeteor
//
//  Created by Neil Weintraut on 1/20/17.
//  Copyright © 2017 Neil Weintraut. All rights reserved.
//

import GoogleMaps
import GooglePlaces



class RVGMSMapStyle: GMSMapStyle {
    
}
class RVGMaps {
    enum MapType: String {
        case normal     = "Normal"
        case satellite  = "Satellite"
        case hybrid     = "Hybrid"
        case terrain    = "Terrain"
        case none       = "No Type"
        
        var gmsType: GMSMapViewType {
            switch self {
            case .normal: return .normal
            case .satellite: return .satellite
            case .hybrid: return .hybrid
            case .terrain: return .terrain
            case .none: return .none
            }
        }
    }
    enum MapStyle: String {
        case normal     = "Normal"
        case retro      = "Retro"
        case grayscale  = "Grayscale"
        case night      = "Night"
        case noPOIs     = "No business points of interest, no transit"
        case none       = "No Style"
        
        var gmapsStyle: String  {
            switch self {
            case .retro:    return "mapstyle-retro"
            case .grayscale: return "mapstyle-silver"
            case .night:    return "mapstyle-night"
            default: return "Not a correct usage \(self.rawValue)"
            }
            
        }
    }
    enum Extension: String {
        case json = "json"
    }
    let APIKey = "AIzaSyCGCyDe7324EWKEVm7dR0dAYWfNhBba4GI"
    static var sharedInstance: RVGMaps = {
        return RVGMaps()
    }()
    var usaFilter: GMSAutocompleteFilter {
        get {
            let filter = GMSAutocompleteFilter()
            filter.country = "USA"
            return filter
        }
    }
    init() {
        GMSServices.provideAPIKey(APIKey)
        GMSPlacesClient.provideAPIKey(RVAPIKeys.GooglePlacesAPIKey.rawValue)
    }
    func mapView(latitude: CLLocationDegrees, longitude: CLLocationDegrees, zoom: Float) -> RVMapView {
        let camera = GMSCameraPosition.camera(withLatitude: latitude, longitude: longitude, zoom: zoom)
        return RVMapView.map(withFrame: CGRect.zero, camera: camera)
    }
    func mapStyle(mapStyle: MapStyle, callback: @escaping(_ style: RVGMSMapStyle?, _ error: RVError?)-> Void ) {
        switch mapStyle {
        case .retro, .grayscale, .night:
            self.mapStyleHelper(style: mapStyle, callback: callback)
        case .noPOIs:
            self.noPOIsMapStyle(callback: callback)
        default:
            let error = RVError(message: "In RVGMaps.mapStyle, \(mapStyle.rawValue) is unsupported", sourceError: nil)
            callback(nil, error)
        }
    }
    private func mapStyleHelper(style: MapStyle, callback: @escaping(_ style: RVGMSMapStyle?, _ error: RVError?) -> Void) {
        if let url = Bundle.main.url(forResource: style.gmapsStyle, withExtension: Extension.json.rawValue) {
            do {
                let style = try RVGMSMapStyle(contentsOfFileURL: url)
                callback(style , nil)
                return
            } catch let error  {
                let rvError = RVError(message: "In RVGMaps.mapStyleHelperL, got error getting type from Bundle", sourceError: error)
                // print("In RVGMaps. mapyStyleHelper, got error \(error.localizedDescription)")
                callback(nil , rvError)
                return
            }
        } else {
            let error = RVError(message: "In RVGMaps.mapStyleHelper, failed to find URL for \(style.rawValue)")
            callback(nil, error)
            return
        }
    }
    private func noPOIsMapStyle(callback: @escaping(_ style: RVGMSMapStyle?, _ error: RVError?) -> Void) {
        let noPOIsString = " [\n  {\n  \"featureType\": \"poi.business\",\n  \"elementType\": \"all\",\n  \"stylers\": [\n              {\n              \"visibility\": \"off\"\n              }\n              ]\n  },\n  {\n  \"featureType\": \"transit\",\n  \"elementType\": \"all\",\n  \"stylers\": [\n              {\n              \"visibility\": \"off\"\n              }\n              ]\n  }\n  ]"
        do {
            let style = try RVGMSMapStyle(jsonString: noPOIsString)
            callback(style, nil)
        } catch let error {
            let rvError = RVError(message: "In RVGMaps.noPOIsMapStyle, got GMaps error converting \(MapStyle.noPOIs.rawValue) to JSON", sourceError: error)
            callback(nil, rvError)
        }
    }
    
}

class RVMarker: GMSMarker {
    var place: RVGooglePlace?
    var location: RVLocation?
    init(position: CLLocationCoordinate2D) {
        super.init()
        self.position = position
    }
    init(location: RVLocation) {
        super.init()
        self.location = location
        if let coordinate = location.coordinate {
            self.position = coordinate
        }
        self.icon = nil
        if let types = location.types {
            if let type = types.first {
                if let image = UIImage(named: type + "_pin") {
                    self.icon = image
                }
            }
            
        }
        self.title = location.title
        groundAnchor = CGPoint(x: 0.5, y: 1.0)
        appearAnimation = GMSMarkerAnimation.pop
    }
    init(place: RVGooglePlace) {
        self.place = place
        super.init()
        if let coordinate = place.coordinate {
            self.position = coordinate
        }
        icon = nil
        if let type = place.placeType {
            if let image = UIImage(named: type + "_pin") {
                icon = image
            }
        }
        groundAnchor = CGPoint(x: 0.5, y: 1.0)
        appearAnimation = GMSMarkerAnimation.pop
    }
}
class RVMapView: GMSMapView {
    
}
