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
        current.updateCount = newModel.updateCount
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
                    current.location = updateEmbeddedLocation(current: currentLocation, newLocation: newLocation)
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
        } else { return newImage }
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
    func updateEmbeddedLocation(current: RVLocation?, newLocation: RVLocation) -> RVLocation {
        if let current = current {
            updateEmbedded(current: current, newModel: newLocation)
            locationUnique(current: current, newLocation: newLocation)
            return current
        } else { return newLocation }
    }
}
