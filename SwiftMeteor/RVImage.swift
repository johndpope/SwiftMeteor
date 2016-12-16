//
//  RVImage.swift
//  SwiftMeteor
//
//  Created by Neil Weintraut on 12/11/16.
//  Copyright © 2016 Neil Weintraut. All rights reserved.
//

import UIKit
import SDWebImage
enum RVFileType: String {
    case jpeg   = "image/jpeg"
    case png    = "image/png"
    case unkown = "unknown"
}
class RVImage: RVBaseModel {
    static var jpegQuality: CGFloat = 0.9
    override class var insertMethod: RVMeteorMethods { get { return RVMeteorMethods.InsertImage}}
    override class func collectionType() -> RVModelType {return RVModelType.image }
    override class var updateMethod: RVMeteorMethods { get { return RVMeteorMethods.UpdateImage } }
    override class var deleteMethod: RVMeteorMethods { get { return RVMeteorMethods.DeleteImage } }
    override class var findMethod: RVMeteorMethods { get { return RVMeteorMethods.FindImage}}
    override class func createInstance(fields: [String : AnyObject])-> RVBaseModel { return RVImage(fields: fields) }

    override func innerUpdate(key: RVKeys, value: AnyObject?) -> Bool {
        if super.innerUpdate(key: key, value: value) == true {
            return true
        } else {
            //  print("In RVTasks.innerUpdate \(key.rawValue), \(value)")
            switch(key) {
            case .height:
                let _ = self._height.updateNumber(newValue: value)
                return true
            case .width:
                let _ = self._width.updateNumber(newValue: value)
                return true
            case .bytes:
                let _ = self._bytes.updateNumber(newValue: value)
                return true
            case .filetype:
                let _ = self._filetype.updateString(newValue: value)
                return true
            case .urlString:
                let _ = self._urlString.updateString(newValue: value)
                return true
            default:
                print("In \(instanceType).innerUpdate, did not find key \(key)")
                return false
            }
        }
    }
    
    
    
    
    
    override func setupCallback() {
        super.setupCallback()
        self._height.model = self
        self._width.model = self
        self._bytes.model = self
        self._urlString.model = self
        self._filetype.model = self
    }
    override func getRVFields(onlyDirties: Bool) -> [String : AnyObject] {
        var dict = super.getRVFields(onlyDirties: onlyDirties)
        if !onlyDirties || (onlyDirties && self._height.dirty) {
            dict[RVKeys.height.rawValue] = self.height as AnyObject
            self._height.dirty = false
        }
        if !onlyDirties || (onlyDirties && self._width.dirty) {
            dict[RVKeys.width.rawValue] = self.width as AnyObject
            self._width.dirty = false
        }
        if !onlyDirties || (onlyDirties && self._bytes.dirty) {
            dict[RVKeys.bytes.rawValue] = self.bytes as AnyObject
            self._bytes.dirty = false
        }
        if !onlyDirties || (onlyDirties && self._filetype.dirty) {
            dict[RVKeys.filetype.rawValue] = self.filetype.rawValue as AnyObject
            self._filetype.dirty = false
        }
        if !onlyDirties || (onlyDirties && self._urlString.dirty) {
            if let string = self.urlString { dict[RVKeys.urlString.rawValue] = string as AnyObject }
            else { dict[RVKeys.urlString.rawValue] = NSNull() }
            self._urlString.dirty = false
        }
        return dict
    }
    override func initializeProperties() {
        super.initializeProperties()
        self._height.value = 0.0 as CGFloat as AnyObject
        self._width.value = 0.0 as CGFloat as AnyObject
        self._width.value = 0 as Int as AnyObject
    }
    var _height = RVRecord(fieldName: RVKeys.height)
    var height: CGFloat {
        get {
            if let height = _height.value as? CGFloat { return height}
            return 0
        }
        set {
            let _ = _height.changeNumber(newValue: newValue as AnyObject)
        }
    }
    var _width = RVRecord(fieldName: RVKeys.width)
    var width: CGFloat {
        get {
            if let width = _width.value as? CGFloat { return width}
            return 0
        }
        set {
            let _ = _width.changeNumber(newValue: newValue as AnyObject)
        }
    }
    var _bytes = RVRecord(fieldName: RVKeys.bytes)
    var bytes: Int {
        get {
            if let bytes = _bytes.value as? Int { return bytes}
            return 0
        }
        set {
            let _ = _bytes.changeNumber(newValue: newValue as AnyObject)
        }
    }
    var _urlString = RVRecord(fieldName: RVKeys.urlString)
    var urlString: String? {
        get {
            if let string = _urlString.value as? String { return string}
            return nil
        }
        set {
            if let value = newValue {
                let _ = _urlString.changeString(newValue: value as AnyObject)
            } else {
                let _ = _urlString.changeString(newValue: NSNull())
            }
            
        }
    }
    var _filetype = RVRecord(fieldName: RVKeys.filetype)
    var filetype: RVFileType {
        get {
            if let rawValue = _filetype.value as? String {
                if let type = RVFileType(rawValue: rawValue) {
                    return type
                }
            }
            return RVFileType.unkown
        }
        set {
            let _ = _filetype.changeString(newValue: newValue.rawValue as AnyObject)
        }
    }
}
extension RVImage {
    // path = "goofy/something/
    class func saveImage(image: UIImage, path: String?, filename: String, filetype: RVFileType, parent: RVBaseModel?, params: [String:AnyObject],callback: @escaping(_ rvImage: RVImage?, _ error: RVError?) -> Void ) {
        RVUser.sharedInstance.userId(callback: {(userId, error) -> Void in
            if let error = error {
                error.append(message: "In RVImage.saveImage error getting userId")
                callback(nil , error)
            } else if let userId = userId {
                var data: Data? = nil
                var fileExtension = ".png"
                if filetype == .png {
                    data = UIImagePNGRepresentation(image)
                } else if filetype == .jpeg {
                    data = UIImageJPEGRepresentation(image, jpegQuality)
                    fileExtension = "jpeg"
                } else {
                    let error = RVError(message: "In \(classForCoder()).saveImage, Invalid filetype \(filetype.rawValue)")
                    callback(nil, error)
                }
                var fullPath = ""
                if let path = path {
                    fullPath = path.lowercased()
                }
                if let data = data {
                    let rvImage = RVImage()
                    rvImage.height = image.size.height
                    rvImage.width = image.size.width
                    rvImage.bytes = data.count
                    rvImage.filetype = filetype
                    if let parent = parent { rvImage.setParent(parent: parent)}
                    if let title = params[RVKeys.title.rawValue] as? String { rvImage.title = title }
                    fullPath = fullPath + userId + "/" + rvImage._id + "/" + filename.lowercased() + "." + fileExtension.lowercased()
                    RVAWS.sharedInstance.upload(data: data, path: fullPath, contentType: filetype.rawValue, callback: { (data, response, error) in
                        if let error = error {
                            let rvError = RVError(message: "In \(classForCoder()).saveImage, got AWS upload error", sourceError: error)
                            callback(nil, rvError)
                        } else if let response = response as? HTTPURLResponse {
                            if response.statusCode == 200 {
                                if let url = response.url {
                                    let absoluteString = url.absoluteString
                                    let urlString = absoluteString.components(separatedBy: "?")[0]
                                    print("In \(classForCoder()).saveImage, uploaded Image to \(urlString)")
                                    rvImage.urlString = urlString
                                    rvImage.create(callback: { (error) in
                                        if let error = error {
                                            error.append(message: "In RVImage.saveImage, got error creating RVImage record, id: \(rvImage._id)")
                                            callback(nil, error)
                                        } else {
                                            RVImage.retrieveInstance(id: rvImage._id, callback: { (model , error) in
                                                if let error = error {
                                                    error.append(message: "Error in RVImage.saveImage")
                                                    callback(nil , error)
                                                } else if let rvImage = model as? RVImage {
                                                    callback(rvImage, nil)
                                                } else {
                                                    let rvError = RVError(message: "In RVImage.saveImage, saved image but failed to retrieve rvImage record with id \(rvImage._id)")
                                                    callback(nil , rvError)
                                                }
                                            })
                                        }
                                    })
                                }
                            }
                        }
                    })
                }
            } else {
                let error = RVError(message: "In RVImage.saveImage, no error but no userId")
                callback(nil , error)
            }
        })

    }
    
    override func additionalToString() -> String {
        var output = "height: \(self.height), width: \(self.width), bytes: \(self.bytes), filetype: \(self.filetype.rawValue)\n"
        output = output + "urlString: \(self.urlString)"
        return output
    }
}
