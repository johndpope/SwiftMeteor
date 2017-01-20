//
//  RVGeoJSON.swift
//  SwiftMeteor
//
//  Created by Neil Weintraut on 1/20/17.
//  Copyright © 2017 Neil Weintraut. All rights reserved.
//

import Foundation

// https://docs.mongodb.com/manual/reference/geojson/#geospatial-indexes-store-geojson
// specified with "type" key
// coordinates are always: [logitude, latitude]
enum RVGeoJSONObjects: String {
    case Point = "Point"
    case LineString = "LineString"
    case Polygon = "Polygon"
    case MultiPoint = "MultiPoint"
    case MultiLineString = "MultiLineString"
    case MultiPolygon = "MultiPolygon"
    case GeometryCollection = "GeometryCollection"
}
enum RVGeoJSONField: String {
    case type = "type"
    case coordinates = "coordinates"
}
// https://docs.mongodb.com/manual/reference/operator/query-geospatial/
enum RVGeospatialQueryOperator: String {
    case geoWithin = "$geoWithin"
    case geoIntersects = "$geoIntersects"
    case near = "$near"
    case nearSphere = "$nearSphere"
}

// https://docs.mongodb.com/manual/reference/operator/query-geospatial/
enum RVGeometrySpecifier: String {
    case geometry = "$geometry"
    case minDistance = "$minDistance"
    case maxDistance = "$maxDistance"
    case center = "$center"
    case centerSphere = "$centerSphere"
    case box = "$box"
    case polygon = "$polygon"
    case uniqueDocs = "$uniqueDocs" // deprecated
}

