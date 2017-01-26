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
    override class func     createInstance(fields: [String : AnyObject])-> RVBaseModel {
       // print("In RVImage.createInstance. \nFields are: \(fields)")
        return RVImage(fields: fields)
    }

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
    
    var photo_reference: String? {
        get { return getString(key: RVKeys.photo_reference) }
        set { updateString(key: RVKeys.photo_reference, value: newValue, setDirties: true)}
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
    class func fakeIt() -> RVImage {
        let image = RVImage()
        image.height = 123.0
        image.width = 987.0
        image.bytes = 32
        image.urlString = "URL STRING"
        image.photo_reference = "Some Photo_Reference"
        image.filetype = .jpeg
    //    image.parentModelType = .unknown
        image.special = .regular
        image.regularDescription = "Image Description"
        image.title = "Image Title"
        image.ownerId = "ImageOwnerId"
        image.text = "Image Text"
        image.username = "Image UserName"
        image.fullName = "Image Fullname"
        image.handle = "Image handle"
        image.comment = "Image comment"
        image.schemaVersion = 32
        image.location = nil
        return image
    }
    override func additionalToString()-> String {
        var output = ""
        output = addTerm(term: "height", input: output, value: "\(self.height)")
        output = addTerm(term: "width", input: output , value: "\(self.width)")
        output = addTerm(term: "bytes", input: output , value: self.bytes.description)
        output = addTerm(term: "photo_reference", input: output, value: self.photo_reference)
        output = addTerm(term: "filetype", input: output , value: self.filetype.rawValue) + "\n"
        output = addTerm(term: "urlString", input: output, value: self.urlString)
        return output
    }
}
extension RVImage {
    func download(callback: @escaping(_ uiImage: UIImage?, _ error: RVError?) -> Void) {
        if let urlString = self.urlString {
            RVAWS.sharedInstance.download(urlString: urlString, progress: { (progress, total) in
                
            }, completion: { (image, error, cacheTYpe, success, url ) in
                if let error = error {
                    error.append(message: "In \(self.classForCoder).download, got error")
                    callback(nil, error)
                    return
                } else if let image = image {
                    callback(image, nil)
                    return
                } else {
                    print("IN \(self.classForCoder).download, no error but no result")
                    callback(nil, nil)
                }
            })
        }
    }
    // path = "goofy/something/
    class func saveImage(image: UIImage, path: String?, filename: String, filetype: RVFileType, parent: RVBaseModel?, params: [String:AnyObject],callback: @escaping(_ rvImage: RVImage?, _ error: RVError?) -> Void ) {
        RVMeteorUser.sharedInstance.userId(callback: {(userId, error) -> Void in
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
                    if let id = rvImage.localId {
                        
                        fullPath = fullPath + userId + "/" + id + "/" + filename.lowercased() + "." + fileExtension.lowercased()
                        RVAWS.sharedInstance.upload(data: data, path: fullPath, contentType: filetype.rawValue, callback: { (data, response, error) in
                            DispatchQueue.main.async {
                                if let error = error {
                                    let rvError = RVError(message: "In \(classForCoder()).saveImage, got AWS upload error", sourceError: error)
                                    callback(nil, rvError)
                                } else if let response = response as? HTTPURLResponse {
                                    if response.statusCode == 200 {
                                        if let url = response.url {
                                            let absoluteString = url.absoluteString
                                            let urlString = absoluteString.components(separatedBy: "?")[0]
                                            //     print("In \(classForCoder()).saveImage, uploaded Image to \(urlString)")
                                            rvImage.urlString = urlString
                                            rvImage.create(callback: { (rvImage, error) in
                                                if let error = error {
                                                    error.append(message: "In RVImage.saveImage, got error creating RVImage record")
                                                    callback(nil, error)
                                                } else if let rvImage = rvImage as? RVImage {
                                                    print("Created a new RVImage record with id \(rvImage.localId) \(rvImage.shadowId) $$$$$$$$$$$$$$$$$")
                                                    callback(rvImage, nil)
                                                } else if let rvImage = rvImage {
                                                    print("In RVImage.saveImage, saved actual image, no cast is of type \(rvImage)")
                                                    callback(nil, nil)
                                                    
                                                } else {
                                                    print("In RVImage.saveImage, saved actual image, no error but no rvImage")
                                                    callback(nil, nil)
                                                }
                                            })
                                            return
                                        } else {
                                            let rvError = RVError(message: "In \(self.classForCoder()).saveImage, no URL")
                                            callback(nil, rvError)
                                            return
                                        }
                                    } else {
                                        let rvError = RVError(message: "In \(self.classForCoder()).saveImage, response status code is \(response.statusCode)")
                                        callback(nil, rvError)
                                        return
                                    }
                                } else {
                                    let rvError = RVError(message: "In \(self.classForCoder()).saveImage, response did not cast as HTTPURLResponse")
                                    callback(nil, rvError)
                                    return
                                }
                            }
                        })
                        return
                    } else {
                        let rvError = RVError(message: "In \(self.classForCoder()).saveImage, no id for Image model")
                        callback(nil, rvError)
                        return
                    }
 
                }
            } else {
                let error = RVError(message: "In RVImage.saveImage, no error but no userId")
                callback(nil , error)
            }
        })

    }
    /*
    override func additionalToString() -> String {
        var output = "height: \(self.height), width: \(self.width), bytes: \(self.bytes), filetype: \(self.filetype.rawValue)\n"
        output = output + "urlString: \(self.urlString)"
        return output
    }
 */
}
