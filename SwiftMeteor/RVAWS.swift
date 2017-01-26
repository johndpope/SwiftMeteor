//
//  RVAWS.swift
//  SwiftMeteor
//
//  Created by Neil Weintraut on 12/10/16.
//  Copyright © 2016 Neil Weintraut. All rights reserved.
//

import Foundation
import AWSCore
import AWSS3
import AWSCognito
import SDWebImage

public class RVAWS: NSObject {


    let defaultServiceRegionType = AWSRegionType.usWest1
    private static let s3domainAddress     = "s3.amazonaws.com"
    private static let amazonDomainAddress = "amazonaws.com"
    let transferManagerIdentifier: String  = "USWest2S3TransferManager"
    private static let identityPoolId      = "us-west-2:035aed25-71d4-4d56-afab-9dfc4a1be60a"
    
    static let bucket = "swiftmeteor"
    
    
    private static let cognitoRegion = AWSRegionType.usWest2
    private static let S3Region = AWSRegionType.usWest1
    private static let S3RegionString = "s3-us-west-1"
    
    private static let accessKey           = "AKIAIMIHTAKR4RY7R2HA"
    private static let secret              = "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"
    
    
    // Attached path in the format of: directoryi/directoryii.../filename (note no leading slash)
    static let baseURL: URL = {
        URL(string: "https://\(RVAWS.bucket).\(RVAWS.S3RegionString).\(RVAWS.amazonDomainAddress)")!
    }()
    private static var _sharedInstance: RVAWS?
    public static var sharedInstance: RVAWS {
        get {
            if let sharedInstance = _sharedInstance { return sharedInstance}
            AWSLogger.default().logLevel = AWSLogLevel.error
            if URLProtocol.registerClass(RVS3URLProtocol.self) {
           //     print("In \(self.classForCoder()).sharedInstance Successful register")
            } else {
                print("Not successful register")
            }
            //URLProtocol.registerClass(RVS3URLProtocol.self)
            let credentialsProvider: AWSCognitoCredentialsProvider = AWSCognitoCredentialsProvider(regionType: RVAWS.cognitoRegion, identityPoolId: RVAWS.identityPoolId)
            let configuration: AWSServiceConfiguration = AWSServiceConfiguration(region: RVAWS.S3Region, credentialsProvider: credentialsProvider)
            AWSServiceManager.default().defaultServiceConfiguration = configuration
            let rvaws = RVAWS()
            RVAWS._sharedInstance = rvaws
            return rvaws
        }
    }
    // http://docs.aws.amazon.com/mobile/sdkforios/developerguide/s3transfermanager.html
    // Upload in background
    // @path = "folders/\(filename)"
    func upload(data: Data, path: String, contentType: String, callback: @escaping (Data? , URLResponse?  , RVError?)-> Void ) {
        
        let getPresignedURLRequest = AWSS3GetPreSignedURLRequest()
        getPresignedURLRequest.bucket = RVAWS.bucket
        getPresignedURLRequest.key = path
        getPresignedURLRequest.httpMethod = AWSHTTPMethod.PUT
        getPresignedURLRequest.expires = NSDate(timeIntervalSinceNow: 3600) as Date
        let fileContentTypeString = contentType
        getPresignedURLRequest.contentType = fileContentTypeString
        let t = AWSS3PreSignedURLBuilder.default().getPreSignedURL(getPresignedURLRequest)
        t.continue(successBlock: { (task: AWSTask!) -> AnyObject! in
            if let error = task.error {
                print(error)
                let rvError = RVError(message: "In RVAWS.upload, failed to get Presigned URL for \(RVAWS.bucket)\(path)", sourceError: error)
                callback(nil, nil, rvError)
            } else if let exception = task.exception {
                let rvError = RVError(message: "In RVAWS.upload, got exception \(exception)", sourceError: nil)
                callback(nil, nil, rvError)
            } else if let presignedURL = task.result  {
                let interval: TimeInterval = 3600.0
                let request = NSMutableURLRequest(url: presignedURL as URL, cachePolicy: NSURLRequest.CachePolicy.reloadIgnoringLocalCacheData, timeoutInterval: interval)
                request.httpMethod = "PUT"
                request.setValue(fileContentTypeString, forHTTPHeaderField: "Content-Type")
                let uploadTask = URLSession.shared.uploadTask(with: request as URLRequest, from: data, completionHandler: { (data, response, error) in
                    if let error = error {
                        let rvError = RVError(message:"In RVAWS.upload, got error uploading \(RVAWS.bucket) \(path)", sourceError: error)
                        callback(data, response, rvError)
                    } else {
                        callback(data, response, nil)
                    }
                })
                uploadTask.resume()
            } else {
                let rvError = RVError(message: "In RVAWS.upload no error but no presigned URL \(RVAWS.bucket) \(path)", sourceError: nil)
                callback(nil , nil , rvError)
            }
            return nil
        })
    }
    func download(urlString: String, progress: @escaping(Int, Int) -> Void, completion: @escaping(UIImage?, RVError?, SDImageCacheType, Bool, URL?) -> Void ) {
        if let url = URL(string: urlString) {
            SDWebImageManager.shared().downloadImage(with: url, options: SDWebImageOptions(rawValue: 0), progress: progress, completed: { (image, error, type, finished, url) in
   
                    if let error = error {
                        let rvError = RVError(message: "Error with SDWebImageManager in RVAWS.download ", sourceError: error)
                        completion(image, rvError, type, finished, url)
                    } else {
                        completion(image, nil, type, finished, url)
                    }
                
            })
        } else {
            let error = RVError(message: "Bad URL String: \(urlString)")
            completion(nil, error, SDImageCacheType.memory, false, nil)
        }
    }
}
