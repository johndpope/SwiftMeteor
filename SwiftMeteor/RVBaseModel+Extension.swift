//
//  RVBaseModel+Extension.swift
//  SwiftMeteor
//
//  Created by Neil Weintraut on 1/21/17.
//  Copyright © 2017 Neil Weintraut. All rights reserved.
//

import Foundation
extension RVBaseModel {
    func updateEmbedded(current: RVBaseModel, newModel: RVBaseModel) {
        current.modelType = newModel.modelType
        current.collection = newModel.collection
        current.title = newModel.title
        current.regularDescription = newModel.regularDescription
        current.text = newModel.text
        current.comment = newModel.comment
        current.value = newModel.value
        current.owner = newModel.owner
        current.deleted = newModel.deleted
        current.ownerId = newModel.ownerId
        current.ownerModelType = newModel.ownerModelType
        current.parentId = newModel.parentId
        current.parentModelType = newModel.parentModelType
        current.domainId = newModel.domainId
        current.fullName = newModel.fullName
        current.handle = newModel.handle
        current.numberOfLikes = newModel.numberOfLikes
        current.numberOfFollowers = newModel.numberOfFollowers
        current.numberOfObjections = newModel.numberOfObjections
        current.schemaVersion = newModel.schemaVersion
//        current.score = newModel.score
        current.special = newModel.special
        current.tags = newModel.tags
        current.username = newModel.username
        current.validRecord = newModel.validRecord
        current.visibility = newModel.visibility
        current.parentField = newModel.parentField
        // image
        // location
    }
    func nullOutBase(current: RVBaseModel) {
       // current.modelType
       // current.collection
        current.title = nil
        current.regularDescription = nil
        current.text = nil
        current.comment = nil
        current.value = nil
        current.deleted = true
        current.owner = nil
        current.ownerId = nil
        current.ownerModelType = .unknown
        current.parentId = nil
        current.parentModelType = .unknown
        current.domainId = nil
        current.fullName = nil
        current.handle = nil
        current.numberOfLikes = 0
        current.numberOfFollowers = 0
        current.numberOfObjections = 0
        current.schemaVersion = 0
        //        current.score = newModel.score
        current.special = .unknown
        current.tags = [String]()
        current.username = nil
        current.validRecord = false
        current.visibility = .publicVisibility
        current.parentField = nil
        // image
        // location
    }
    func nullOutImage(current: RVImage) {
        nullOutBase(current: current)
        current.bytes = 0
        current.filetype = RVFileType.unkown
        current.height = 0
        current.photo_reference = nil
        //        current.url = newImage.url
        current.urlString = nil
        current.width = 0
    }
    func imageUnique(current: RVImage, newImage: RVImage) {
        current.bytes = newImage.bytes
        current.filetype = newImage.filetype
        current.height = newImage.height
        current.photo_reference = newImage.photo_reference
//        current.url = newImage.url
        current.urlString = newImage.urlString
        current.width = newImage.width
    }
    func updateEmbeddedImage(current: RVImage?, newImage: RVImage) -> RVImage {
        if let current = current {
            updateEmbedded(current: current, newModel: newImage)
            imageUnique(current: current , newImage: newImage)
            if let currentLocation = current.location {
                if let newLocation = newImage.location {
                    current.location = updateEmbeddedLocation(key: .location, current: currentLocation, newLocation: newLocation)
                } else {
                    current.location = nil
                }
                print("In \(self.instanceType).updateEmbeddedImage, dirties \(current.dirties.count), current is \(current)")
            } else if let newLocation = newImage.location {
                // current has no location so just add new one
                current.location = newLocation
            } else {
                // current and new are both nil. No action needed.
            }
            return current
        } else {
            return newImage
        }
    }
    func nullOutLocation(current: RVLocation) {
        nullOutBase(current: current)
        current.administrativeArea = nil
        current.city = nil
        current.country = nil
        //current.firstLine = newLocation.firstLine
        current.geocoded = nil
        current.geoIndex = nil
        current.geometry = nil
        current.iconURLString = nil
        current.latitude = nil
        current.locality = nil
        current.longitude = nil
        current.neighborhood = nil
        current.phoneNumber = nil
        current.photo = nil
        current.placeId = nil
        current.postalCode = nil
        current.record_id = nil
        current.reference = nil
        current.route = nil
        current.state = nil
        current.street = nil
        current.street_number = nil
        current.subLocality = nil
        current.thoroughfare = nil
        current.types = nil
        current.websiteString = nil
        current.fullAddress = nil
    }
    func locationUnique(current: RVLocation, newLocation: RVLocation) {
        current.administrativeArea = newLocation.administrativeArea
        current.city = newLocation.city
        current.country = newLocation.country
        //current.firstLine = newLocation.firstLine
        current.fullAddress = newLocation.fullAddress
        current.geocoded = newLocation.geocoded
        current.geoIndex = newLocation.geoIndex
        current.geometry = newLocation.geometry
        current.iconURLString = newLocation.iconURLString
        current.latitude = newLocation.latitude
        current.locality = newLocation.locality
        current.longitude = newLocation.longitude
        current.neighborhood = newLocation.neighborhood
        current.phoneNumber = newLocation.phoneNumber
        current.photo = newLocation.photo
        current.placeId = newLocation.placeId
        current.postalCode = newLocation.postalCode
        current.record_id = newLocation.record_id
        current.reference = newLocation.reference
        current.route = newLocation.route
        current.state = newLocation.state
        current.street = newLocation.street
        current.street_number = newLocation.street_number
        current.subLocality = newLocation.subLocality
        current.thoroughfare = newLocation.thoroughfare
        current.types = newLocation.types
        current.websiteString = newLocation.websiteString
    }
    func updateEmbeddedLocation(key: RVKeys, current: RVLocation?, newLocation: RVLocation?) -> RVLocation {
        if let current = current {
            if let newLocation = newLocation {
                updateEmbedded(current: current, newModel: newLocation)
                locationUnique(current: current, newLocation: newLocation)
            } else {
                nullOutLocation(current: current)
            }
        } else if let newLocation = newLocation {
            updateDictionary(key: key, dictionary: newLocation.objects , setDirties: true)
        } else {
            // both are nil so do nothing
        }

    }
}
