//
//  RVGoogleDataProvider.swift
//  SwiftMeteor
//
//  Created by Neil Weintraut on 1/20/17.
//  Copyright © 2017 Neil Weintraut. All rights reserved.
//

import UIKit
import CoreLocation
import WebKit

class RVGoogleDataProvider {
    var photoCache = [String:UIImage]()
    var placesTask: URLSessionDataTask?
    var session: URLSession {
        return URLSession.shared
    }
    
    func fetchPlacesNearCoordinate(coordinate: CLLocationCoordinate2D, radius: Double, types:[String], callback: @escaping ( _ places: [RVLocation], _ error: RVError? )-> Void) -> ()
    {
        print("In RVGoogleDataProvider.fetch...")
        var urlString = "http://localhost:10000/maps/api/place/nearbysearch/json?location=\(coordinate.latitude),\(coordinate.longitude)&radius=\(radius)&rankby=prominence&sensor=true"
        var typesString = types.count > 0 ? types.joined(separator: "|") : "food"
        typesString = "&types=\(typesString)"
        if let typesString = typesString.stringByAddingPercentEncodingForRFC3986() {
            urlString += typesString
            // let typesString = types.count > 0 ? types.joined(separator: "|") : "food"
            // urlString += "&types=\(typesString)"
            // if let urlString = urlString.stringByAddingPercentEncodingForRFC3986() {
            if let url = URL(string: urlString) {
                if let task = placesTask, task.taskIdentifier > 0 && task.state == .running {
                    print("In RVGoogleDataProvider, cancel task")
                    task.cancel()
                }
                //  print("In RVGoogleDataProvider.fetch about to do Query")
                UIApplication.shared.isNetworkActivityIndicatorVisible = true
                placesTask = session.dataTask(with: url) {data, response, error in
                    UIApplication.shared.isNetworkActivityIndicatorVisible = false
                    if let error = error {
                        // print("In RVGoogleDataProvider.fetch.... got server error \(error.localizedDescription) for url \(url.absoluteString)")
                        let rvError = RVError(message: "In RVGoogleDatProvider.fetch got server error with URL\n\(url.absoluteString)\n", sourceError: error)
                        callback([RVLocation](), rvError)
                        return
                    } else if let response = response {
                        if let response = response as? HTTPURLResponse {
                            // print("Got statusCode of \(response.statusCode)")
                            if response.statusCode == 200 {
                                
                                let placesArray = [RVLocation]()
                                if let data = data {
                                    do {
                                        let json = try JSONSerialization.jsonObject(with: data, options: .mutableContainers)
                                        if let json = json as? [String : AnyObject] {
                                            if let results = json["results"] as? [[String: AnyObject]] {
                                                var locations = [RVLocation]()
                                                for index in 0..<results.count {
                                                    let result = results[index]
                                                    let location = RVLocation(rawPlaces: result)
                                                    locations.append(location)
                                                    if let image = location.image {
                                                        if let photoReference = image.photo_reference {
                                                            self.fetchPhotoFromReference(reference: photoReference, completion: { (image , error) in
                                                                if let error = error {
                                                                    print("In RVGoogleDataProvider, got error \(error.messages), \(error.sourceError?.localizedDescription ?? "No localized Description")")
                                                                } else if let image = image {
                                                                    location.photo = image
                                                                }
                                                            })
                                                        }
                                                    }
                                                }
                                                DispatchQueue.main.async {
                                                    callback(locations, nil)
                                                }
                                                return
                                            } else {
                                                DispatchQueue.main.async() {
                                                    let error = RVError(message: "In RVGoogleDataProvider.fetch... results did not convert", sourceError: nil)
                                                    callback([RVLocation](), error)
                                                }
                                                return
                                            }
                                        } else {
                                            DispatchQueue.main.async() {
                                                let error = RVError(message: "In RVGoogleDataProvider.fetch... json did not convert to [String: AnyObject", sourceError: nil)
                                                callback([RVLocation](), error)
                                            }
                                            return
                                        }
                                    } catch let myJSONError {
                                        DispatchQueue.main.async() {
                                            let error = RVError(message: "In RVGoogleDataProvider.fetch... Exception convering JSON", sourceError: myJSONError)
                                            callback([RVLocation](), error)
                                        }
                                        return
                                    }
                                    
                                } else {
                                    DispatchQueue.main.async() {
                                        callback(placesArray, nil)
                                    }
                                    return
                                }
                            } else {
                                DispatchQueue.main.async() {
                                    let error = RVError(message: "In RVGoogleDataProvider.fetch... got bad status code of \(response.statusCode)", sourceError: nil)
                                    callback([RVLocation](), error)
                                }
                                return
                            }
                        }
                        
                    }
                    DispatchQueue.main.async {
                        let error = RVError(message: "In RVGoogleDataProvider.fetch. no server error but no response", sourceError: nil)
                        callback([RVLocation](), error)
                    }
                }
                placesTask?.resume()
            } else {
                let rvError = RVError(message: "In RVGoogleDataProvider.fetchPlacesNear... could not create URL from \(urlString)", sourceError: nil)
                callback([RVLocation](), rvError)
            }
        } else {
            let rvError = RVError(message: "In RVGoogleDataProvider.fetchPlacesNear... bad URL String", sourceError: nil)
            callback([RVLocation](), rvError)
        }
        
    }
    
    
    func fetchPhotoFromReference(reference: String, completion: @escaping (_ image: UIImage?, _ error: RVError?) -> Void) -> () {
        if let photo = photoCache[reference] as UIImage? {
            completion(photo, nil)
        } else {
            let urlString = "http://localhost:10000/maps/api/place/photo?maxwidth=200&photoreference=\(reference)"
            UIApplication.shared.isNetworkActivityIndicatorVisible = true
            if let url = URL(string: urlString) {
                session.downloadTask(with: url) {url, response, error in
                    UIApplication.shared.isNetworkActivityIndicatorVisible = false
                    if let error = error {
                        DispatchQueue.main.async {
                            let rvError = RVError(message: "In RVGoogleDataProvider.fetchPhoto... got Error from server", sourceError: error)
                            completion(nil, rvError)
                        }
                        return
                    } else if let response = response as? HTTPURLResponse {
                        if response.statusCode == 200 {
                            if let url = url {
                                do {
                                    let data = try Data(contentsOf: url)
                                    if let downloadedPhoto = UIImage(data: data) {
                                        self.photoCache[reference] = downloadedPhoto
                                        DispatchQueue.main.async() {
                                            completion(downloadedPhoto, nil)
                                        }
                                        return
                                    } else {
                                        DispatchQueue.main.async() {
                                            let rvError = RVError(message: "In RVGoogleDataProvider.fetchPhoto... no downloadedPhoto")
                                            completion(nil, rvError )
                                        }
                                        return
                                    }
                                } catch let error {
                                    DispatchQueue.main.async() {
                                        let rvError = RVError(message: "In RVGoogleDataProvider.fetchPhoto... getting image generated exception", sourceError: error)
                                        completion(nil, rvError )
                                    }
                                    return
                                }
                            } else {
                                DispatchQueue.main.async() {
                                    let rvError = RVError(message: "In RVGoogleDataProvider.fetchPhoto... no url")
                                    completion(nil, rvError )
                                }
                                return
                            }
                        } else {
                            DispatchQueue.main.async {
                                let rvError = RVError(message: "In RVGoogleDataProvider.fetchPhoto.... no error but response code: \(response.statusCode)", sourceError: nil)
                                completion(nil, rvError)
                            }
                            return
                        }
                    } else {
                        DispatchQueue.main.async {
                            let rvError = RVError(message: "In RVGoogleDataProvider.fetchPhoto.... no error but response did not cast", sourceError: nil)
                            completion(nil, rvError)
                        }
                        return
                    }
                    }.resume()
            }
            
        }
    }
}
