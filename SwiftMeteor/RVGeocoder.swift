//
//  RVGeocoder.swift
//  SwiftMeteor
//
//  Created by Neil Weintraut on 1/20/17.
//  Copyright © 2017 Neil Weintraut. All rights reserved.
//

import UIKit
import GoogleMaps
class RVGeocoder: GMSGeocoder {
    static let googleGeocodeURL = "https://maps.googleapis.com/maps/api/geocode/json?address="
    static let geocodeAPIKey = "AIzaSyAXI9hftSuC0AOWESG9cKMbRT74Mwu3ZVc"
    var geocodeTask: URLSessionDataTask? = nil
    var session: URLSession {
        return URLSession.shared
    }
    static var sharedInstance: RVGeocoder = {
        return RVGeocoder()
    }()
    
    func RVReverseGeocodeCoorindate(coordinate: CLLocationCoordinate2D, callback: @escaping(_ response: [GMSAddress], _ error: RVError?) -> Void) {
        super.reverseGeocodeCoordinate(coordinate) { (response: GMSReverseGeocodeResponse?, error: Error?) in
            if let error = error {
                let rvError = RVError(message: "In \(self.classForCoder).got GMaps error", sourceError: error)
                callback([GMSAddress](), rvError)
                return
            } else if let response = response {
                if let results: [GMSAddress] = response.results() {
                    if let address: GMSAddress = results.first {
                        if let lines: [String] = address.lines {
                            if lines.count > 1 {
                                // lines[1] // City, State, Zip
                            }
                        }
                    }
                    callback(results, nil)
                    return
                }
                callback([GMSAddress](), nil)
            } else {
                callback([GMSAddress](), nil)
            }
        }
    }
    func geocodeAddress(address: String, callback: @escaping(_ location: RVLocation?, _ error: RVError?)-> Void) {
        let address: String = "1600 Amphitheatre Parkway, Mountain+View, CA"
        var parameters = "\(address)&key=\(RVGeocoder.geocodeAPIKey)"
        parameters = parameters.replacingOccurrences(of: " ", with: "+")
        parameters = parameters.replacingOccurrences(of: ":", with: "")
        parameters = parameters.replacingOccurrences(of: ";", with: "")
        parameters = parameters.replacingOccurrences(of: "#", with: "")
        parameters = parameters.replacingOccurrences(of: "!", with: "")
        parameters = parameters.replacingOccurrences(of: "*", with: "")
        parameters = parameters.replacingOccurrences(of: "^", with: "")
        //print(parameters)
        let urlString = "\(RVGeocoder.googleGeocodeURL)\(parameters)"
        if let url = URL(string: urlString) {
            if let task = geocodeTask, task.taskIdentifier > 0  && task.state == .running {
                task.cancel()
            }
            //print("\(urlString)")
            UIApplication.shared.isNetworkActivityIndicatorVisible = true
            geocodeTask = session.dataTask(with: url, completionHandler: { (data: Data?, response: URLResponse? , error: Error?) in
                UIApplication.shared.isNetworkActivityIndicatorVisible = false
                if let error = error {
                    let rvError = RVError(message: "In RVGeocoder.geocodeAddress, got Server error ", sourceError: error)
                    DispatchQueue.main.async {
                        callback(nil, rvError)
                    }
                    return
                } else if let response = response as? HTTPURLResponse {
                    if response.statusCode == 200 {
                        if let data = data {
                            do {
                                let json = try JSONSerialization.jsonObject(with: data, options: .mutableContainers)
                                if let json = json as? [String: AnyObject] {
                                    if let status = json["status"] as? String {
                                        if status == "REQUEST_DENIED" {
                                            let rvError = RVError(message: "In RVGeocoder.geocodeAddress, REQUEST_DENIED", sourceError: nil)
                                            DispatchQueue.main.async {
                                                callback(nil, rvError)
                                                return
                                            }
                                        } else if status == "OK" {
                                            if let results = json["results"] as? [ [String: AnyObject]] {
                                                for result in results {
                                                    print(RVLocation(geocode: result).toString())
                                                }
                                            }
                                        } else {
                                            let rvError = RVError(message: "In RVGeocoder.geocodeAddress failing status \(status)", sourceError: nil)
                                            DispatchQueue.main.async {
                                                callback(nil, rvError)
                                                return
                                            }
                                        }
                                    }
                                } else {
                                    let rvError = RVError(message: "In RVGeocoder.geocodeAddress, JSON did not cast to [String:AnyObject]", sourceError: nil)
                                    DispatchQueue.main.async {
                                        callback(nil, rvError)
                                    }
                                    return
                                }
                            } catch let error {
                                let rvError = RVError(message: "In RVGeocoder.geocodeAddress, got JSON exception", sourceError: error)
                                DispatchQueue.main.async {
                                    callback(nil, rvError)
                                }
                                return
                            }
                        } else {
                            let rvError = RVError(message: "In RVGeocoder.geocodeAddress, no data", sourceError: error)
                            DispatchQueue.main.async {
                                callback(nil, rvError)
                            }
                            return
                        }
                    } else {
                        let rvError = RVError(message: "In RVGeocoder.geocodeAddress, statusCode \(response.statusCode) ", sourceError: error)
                        DispatchQueue.main.async {
                            callback(nil, rvError)
                        }
                        return
                    }
                } else {
                    let rvError = RVError(message: "In RVGeocoder.geocodeAddress no response", sourceError: nil)
                    DispatchQueue.main.async {
                        callback(nil, rvError)
                    }
                    return
                }
            })
            geocodeTask!.resume()
        } else {
            let rvError = RVError(message: "In RVGeocoder.geocodeAddress bad URL", sourceError: nil)
            callback(nil, rvError)
        }
    }
}
//https://maps.googleapis.com/maps/api/geocode/json?address=1600+Amphitheatre+Parkway,+Mountain+View,+CA&key=AIzaSyCGCyDe7324EWKEVm7dR0dAYWfNhBba4GI
//https://maps.googleapis.com/maps/api/geocode/json?address=1600+Amphitheatre+Parkway,+Mountain+View,+CA&key=AIzaSyAXI9hftSuC0AOWESG9cKMbRT74Mwu3ZVc


