//
//  RVAWS.swift
//  SwiftMeteor
//
//  Created by Neil Weintraut on 11/29/16.
//  Copyright © 2016 Neil Weintraut. All rights reserved.
//

import Foundation
import UIKit

import UIKit
import AWSS3
//import AFNetworking
// import AFAmazonS3Manager
//import SDWebImage

class RVAWS:NSObject {
    enum ContentType: String {
        case JPEG = "image/jpeg"
        case PNG = "image/png"
        case UNKNOWN = "text/unknown"
        var suffix : String {
            get {
                switch(self) {
                case .JPEG:
                    return "jpeg"
                case .PNG:
                    return "png"
                case .UNKNOWN:
                    return "unknown"
                }
            }
        }
        
    }
    let CognitoRegionType = AWSRegionType.usEast1
    let DefaultServiceRegionType = AWSRegionType.usWest1
    static let S3BucketName = "rendevu2"
    let accessKey           = "AKIAIMIHTAKR4RY7R2HA"
    let secret              = "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"
    static let s3domainAddress     = "s3.amazonaws.com"
    static let amazonDomainAddress = "amazonaws.com"
    
    let CognitoIdentityPoolId: String = "us-east-1:c87f0067-d1bf-44f8-b77f-d5ad70dc2946"
    let transferManagerIdentifier: String = "USWest2S3TransferManager"
    var configuration: AWSServiceConfiguration
    
    let uploadPath = "upload"
    static var sharedInstance: RVAWS = {
        return RVAWS()
    }()
    // Attached path in the format of: directoryi/directoryii.../filename (note no leading slash)
    static let baseURL: NSURL = {
        NSURL(string: "https://\(RVAWS.S3BucketName).\(RVAWS.s3domainAddress)")!
    }()
    
    
    override init() {
        //AWSLogger.defaultLogger().logLevel = .Verbose
        let credentialProvider = AWSCognitoCredentialsProvider(regionType: CognitoRegionType, identityPoolId: CognitoIdentityPoolId)
        self.configuration = AWSServiceConfiguration(region: AWSRegionType.usWest1, credentialsProvider: credentialProvider)
        AWSServiceManager.default().defaultServiceConfiguration = self.configuration
        AWSS3TransferManager.register(with: self.configuration, forKey: transferManagerIdentifier)
        super.init()
        self.createTempDirectory()
    }
    private func createTempDirectory() {
        do {
            let path = (NSTemporaryDirectory() as NSString).appendingPathComponent(uploadPath)
            try FileManager.default.createDirectory(atPath: path , withIntermediateDirectories: true, attributes: nil)
            // print("In \(self.classForCoder).createTempDirectory. Got temp directory\n")
        } catch {
            print("Failed to get temp directory \(error)")
        }
    }
    func listObjects() {
        let s3 = AWSS3.default()
        if let listObjectRequest = AWSS3ListObjectsRequest() {
            listObjectRequest.bucket = RVAWS.S3BucketName
            let objects = s3.listObjects(listObjectRequest)
            objects.continue(successBlock: { (task: AWSTask?) -> Any? in
                if let task = task {
                    if let error = task.error {
                        print("List objects failed \(error)")
                    } else if let exception = task.exception {
                        print("List objects exception \(exception)")
                    } else if let listObjectsOutput:AWSS3ListObjectsOutput = task.result {
                        if let contents: [AWSS3Object] = listObjectsOutput.contents {
                            for object in contents {
                                if let key = object.key {
                                    print(key)
                                }
                            }
                        }
                    }
                }

            })
        }
    }
    func runTest(callback: @escaping (_ image: UIImage)-> Void) {
        //self.listObjects()
        let path = "/yashar/yashar.jpeg"
        self.getFile(path: path, progress: { (percentage, totalBytes) -> Void in
            print("In \(self.classForCoder).runTest, % completed: \(percentage)")
        }) { (error, data) -> Void in
            if let error = error {
                let error = RVError(message: "In \(self.classForCoder).runTests, getFile", sourceError: error)
                error.printError()
            } else if let data = data {
                // callback(data: data)
                /*
                 self.upload(data, contentType: RVAWS.ContentType.JPEG, destinationPath: "/Elmo", progress: { (bytesWritten, totalBytesWritten, totalBytesExpectedToWrite) -> Void in
                 let percentage = totalBytesWritten / totalBytesExpectedToWrite
                 print("in \(self.classForCoder).runTest, uploadFile, \(percentage)% completed of \(totalBytesExpectedToWrite)")
                 }, completionHandler: { (error, url) -> Void in
                 if let error = error {
                 print("in \(self.classForCoder).runTest upload got error \(error)")
                 } else if let url = url {
                 print("In \(self.classForCoder).runTest uploadFile, url is \(url)")
                 } else {
                 print("In \(self.classForCoder).runTest uploadFile no error but no URL")
                 }
                 })
                 */
                let uploadPath = "0afolder/\(NSDate().timeIntervalSince1970).jpg"
                self.upload0(data: data, path: uploadPath, contentType: "image/jpeg", callback: { (error, url) -> Void in
                    if let error = error {
                        print("in \(self.classForCoder).runTest upload got error \(error)")
                    } else if let _ = url {
                        if let url = NSURL(string: uploadPath, relativeTo: RVAWS.baseURL as URL) {
                            SDWebImageManager.sharedManager().downloadImageWithURL(url, options: SDWebImageOptions(rawValue: 0), progress: { (soFar, ExpectedTotal) -> Void in
                                
                            }, completed: { (image: UIImage!, error: NSError!, SDImageCacheType, finished: Bool, url: NSURL!) -> Void in
                                if let error = error {
                                    print("\n:-( in \(self.classForCoder).runTest SDWebImage download got error \(error)")
                                } else if let image = image {
                                    callback(image:image)
                                } else {
                                    print("in \(self.classForCoder).runTest SDWebImage no error but no image")
                                }
                            })
                        }
                        
                    }
                })
            }
            
        }
    }
    func getFile(path: String, progress: @escaping ((_ percentage: Float, _ totalBytes: UInt) -> Void), callback: @escaping (_ error: RVError?, _ data: NSData?) -> Void ) {
        let s3Manager = AFAmazonS3Manager(accessKeyID: RVAWS.sharedInstance.accessKey, secret: RVAWS.sharedInstance.secret)
        s3Manager.requestSerializer.region = AFAmazonS3USWest1Region
        s3Manager.requestSerializer.bucket = RVAWS.S3BucketName
        s3Manager.getObjectWithPath(path, progress: { (bytesJustSent: UInt, totalBytesSent: Int64, totalBytesExpected: Int64) -> Void in
            let percentage =  Float(totalBytesSent / totalBytesExpected)
            let totalBytes = UInt(totalBytesExpected)
            progress(percentage: percentage, totalBytes: totalBytes)
        }, success: { (responseObject: AnyObject!, data: NSData!) -> Void in
            if let responseObject = responseObject as? AFAmazonS3ResponseObject {
                if let originalResponse: NSHTTPURLResponse = responseObject.originalResponse {
                    if originalResponse.statusCode == 200 {
                        print(originalResponse.URL)
                        if let data = data {
                            callback(error: nil, data: data)
                            return
                        } else {
                            let error = RVError(message: "In \(self.classForCoder).getFile, got 200 response, but no data")
                            callback(error: error, data: nil)
                            return
                        }
                    } else {
                        let error = RVError(message: "In \(self.classForCoder).getFile, got statusCode \(originalResponse.statusCode)")
                        callback(error: error, data: nil)
                        return
                    }
                } else {
                    let error = RVError(message: "In \(self.classForCoder).getFile, no originalResponse object")
                    callback(error: error, data: nil)
                    return
                }
            } else {
                let error = RVError(message: "In \(self.classForCoder).getFile, no originalResponse object")
                callback(error: error, data: nil)
                return
            }
        }) { (error: NSError!) -> Void in
            if let error = error {
                let error = RVError(message: "In \(self.classForCoder).getFile", sourceError: error)
                callback(error: error, data: nil)
                return
            } else {
                let error = RVError(message: "In \(self.classForCoder).getFile, got error but no error reported")
                callback(error: error, data: nil)
                return
            }
        }
    }
    func upload(data: NSData, contentType: RVAWS.ContentType, destinationPath: String, progress: ((_ bytesWritten: UInt, _ totalBytesWritten: Int64, _ totalBytesExpectedToWrite: Int64) -> Void), completionHandler: (_ error: RVError?, _ url: NSURL?) -> Void ) {
        var suffix = ""
        switch(contentType){
        case .JPEG:
            suffix = "jpeg"
        case .PNG:
            suffix = "png"
        case .UNKNOWN:
            suffix = "unknown"
        }
        let fileName = ProcessInfo.processInfo.globallyUniqueString.stringByAppendingString(".\(suffix)")
        if let temp = NSURL(string: NSTemporaryDirectory()) {
            let temp = temp.URLByAppendingPathComponent(uploadPath).URLByAppendingPathComponent(fileName)
            if let sourcePath = temp.path {
                do {
                    try data.writeToFile(sourcePath, options: NSDataWritingOptions.AtomicWrite)
                    uploadFromLocalFile(sourcePath, contentType: contentType, destinationPath: destinationPath, progress: progress, completionHandler: completionHandler)
                    return
                } catch   {
                    print("------------- Failed to Write to \(sourcePath)--------------")
                    let rvError = RVError(message: "In \(self.classForCoder).upload2, filed to save data to local disk")
                    completionHandler(rvError, nil)
                    return
                }
            }
        }
        let error = RVError(message: "In \(self.classForCoder).upload2 problem with disk", sourceError: nil)
        completionHandler(_: error, nil)
    }
    // destinationPath = "/pathOnS3/to/file.txt"
    public func uploadFromLocalFile(sourcePath: String, contentType: RVAWS.ContentType, destinationPath: String,  progress: @escaping ((_ bytesWritten: UInt, _ totalBytesWritten: Int64, _ totalBytesExpectedToWrite: Int64) -> Void), completionHandler: @escaping (_ error: RVError?, _ url: NSURL?)-> Void ) {
        let s3Manager = AFAmazonS3Manager(accessKeyID: RVAWS.sharedInstance.accessKey, secret: RVAWS.sharedInstance.secret)
        
        s3Manager.requestSerializer.region = AFAmazonS3USWest1Region
        s3Manager.requestSerializer.bucket = RVAWS.S3BucketName
        s3Manager.requestSerializer.setValue(contentType.rawValue, forHTTPHeaderField: "Content-Type")
        s3Manager.putObjectWithFile(sourcePath, destinationPath: destinationPath, parameters: nil, progress: progress, success: { (response: AnyObject!) -> Void in
            if let response = response as? AFAmazonS3ResponseObject {
                if let originalResponse = response.originalResponse {
                    if originalResponse.statusCode == 200 {
                        if let url = response.URL {
                            completionHandler(error: nil, url: url)
                            return
                        } else {
                            let error = RVError(message: "In \(self.classForCoder).uploadFromLocalFile, no url")
                            completionHandler(error: error, url: nil)
                            return
                        }
                    } else {
                        let error = RVError(message: "In \(self.classForCoder).uploadFromLocalFile, status not 200, instead \(originalResponse.statusCode)")
                        completionHandler(error: error, url: nil)
                        return
                    }
                } else {
                    let error = RVError(message: "In \(self.classForCoder).uploadFromLocalFile, no originalResponse")
                    completionHandler(error: error, url: nil)
                    return
                }
            } else {
                let error = RVError(message: "In \(self.classForCoder).uploadFromLocalFile, response Object did not cast")
                completionHandler(error: error, url: nil)
                return
            }
        }) { (error: NSError!) -> Void in
            let error = RVError(message: "In \(self.classForCoder).uploadFromLocalFile, got AWS S3 error", sourceError: error)
            completionHandler(error: error, url: nil)
        }
    }
    
    // http://docs.aws.amazon.com/mobile/sdkforios/developerguide/s3transfermanager.html
    // Upload in background
    public func upload0(data: NSData, path: String, contentType: String, callback: @escaping (_ error: RVError?, _ url: String?)-> Void ) {
        
        let getPresignedURLRequest = AWSS3GetPreSignedURLRequest()
        getPresignedURLRequest.bucket = RVAWS.S3BucketName
        getPresignedURLRequest.key = path
        getPresignedURLRequest.httpMethod = AWSHTTPMethod.PUT
        getPresignedURLRequest.expires = NSDate(timeIntervalSinceNow: 3600) as Date
        let fileContentTypeString = contentType
        getPresignedURLRequest.contentType = fileContentTypeString
        
        AWSS3PreSignedURLBuilder.default().getPreSignedURL(getPresignedURLRequest).continue { (task: AWSTask!) -> AnyObject! in
            if let error = task.error {
                print(error)
            } else if let exception = task.exception {
                print(exception)
            } else if let presignedURL = task.result as? NSURL  {
                //     print("Got presignedURL")
                //     print("upload presigned URL is: \(presignedURL)\n\n")
                let interval: NSTimeInterval = 3600.0
                let request = NSMutableURLRequest(URL: presignedURL, cachePolicy: NSURLRequestCachePolicy.ReloadIgnoringLocalCacheData, timeoutInterval: interval)
                request.HTTPMethod = "PUT"
                request.setValue(fileContentTypeString, forHTTPHeaderField: "Content-Type")
                
                let uploadTask = NSURLSession.sharedSession().uploadTaskWithRequest(request, fromData: data , completionHandler: { (data: NSData?, response: NSURLResponse?, error: NSError?) -> Void in
                    if let error = error {
                        print(error)
                        let error = RVError(message: "In \(self.classForCoder).upload0", sourceError: error)
                        callback(error: error, url: nil)
                        return
                    } else {
                        print("Completed uploading \(path) ")
                        if let response = response as? NSHTTPURLResponse {
                            print("In \(self.classForCoder).upload, ResponseStatus: \(response.statusCode)")
                            callback(error: nil, url: response.URL?.absoluteString)
                        }
                        
                        //       print(response)
                        
                        //self.listObjects()
                    }
                })
                
                uploadTask.resume()
                
            } else {
                print("In \(self.classForCoder).upload in task closure, no presignURL")
            }
            return nil
        }
    }
    
}
