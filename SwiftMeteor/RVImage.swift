//
//  RVImage.swift
//  SwiftMeteor
//
//  Created by Neil Weintraut on 12/11/16.
//  Copyright © 2016 Neil Weintraut. All rights reserved.
//

import Foundation

class RVImage: RVBaseModel {
    override class var insertMethod: RVMeteorMethods {
        get {
            return RVMeteorMethods.InsertImage
        }
    }

}
