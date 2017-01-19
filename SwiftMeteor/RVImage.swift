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
    override class var      insertMethod: RVMeteorMethods { get { return RVMeteorMethods.InsertImage}}
    override class func     collectionType() -> RVModelType {return RVModelType.image }
    override class var      updateMethod: RVMeteorMethods { get { return RVMeteorMethods.UpdateImage } }
    override class var      deleteMethod: RVMeteorMethods { get { return RVMeteorMethods.DeleteImage } }
    override class var      findMethod: RVMeteorMethods { get { return RVMeteorMethods.FindImage}}
    override class func     createInstance(fields: [String : AnyObject])-> RVBaseModel { return RVImage(fields: fields) }

    override class func modelFromFields(fields: [String: AnyObject]) -> RVBaseModel {
        return RVImage(fields: fields)
    }

    override func initializeProperties() {
        super.initializeProperties()
        self.height = 0.0
        self.width  = 0.0
        self.bytes  = 0
    }
    
    var height: CGFloat {
        get {
            if let number = getNSNumber(key: .height) { return CGFloat(number.doubleValue) }
            return 0.0
        }
        set {
            updateNumber(key: .height, value: NSNumber(value:Double(newValue)), setDirties: true)
        }
    }

    var width: CGFloat {
        get {
            if let number = getNSNumber(key: .width) { return CGFloat(number.doubleValue) }
            return 0.0
        }
        set {
            updateNumber(key: .width, value: NSNumber(value:Double(newValue)), setDirties: true)
        }
    }
    var bytes: Int {
        get {
            if let number = getNSNumber(key: .bytes) { return number.intValue }
            return 0
        }
        set {
            updateNumber(key: .bytes, value: NSNumber(value:newValue), setDirties: true)
        }
    }
    var urlString: String? {
        get { return getString(key: RVKeys.urlString) }
        set { updateString(key: RVKeys.urlString, value: newValue, setDirties: true)}
    }

    var url: URL? {
        get {
            if let urlString = self.urlString { return URL(string: urlString) }
            return nil
        }
        set {
            if let url = newValue {
                self.urlString = url.absoluteString
            } else {
                self.urlString = nil
            }
        }
    }
    var filetype: RVFileType {
        get {
            if let rawValue = getString(key: .filetype) {
                if let type = RVFileType(rawValue: rawValue) { return type }
            }
            return RVFileType.unkown
        }
        set { updateString(key: RVKeys.filetype, value: newValue.rawValue, setDirties: true)}
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
