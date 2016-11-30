//
//  RVAWSDirect.swift
//  SwiftMeteor
//
//  Created by Neil Weintraut on 11/29/16.
//  Copyright © 2016 Neil Weintraut. All rights reserved.
//

import UIKit
import AWSCore
import AWSS3
import AWSCognito

public class RVAWSDirect: NSObject {
   // let region = AWSRegionType.usEast1
    let defaultServiceRegionType = AWSRegionType.usWest1
    static let s3domainAddress     = "s3.amazonaws.com"
    static let amazonDomainAddress = "amazonaws.com"
    let transferManagerIdentifier: String = "USWest2S3TransferManager"
    let identityPoolId = "us-west-2:035aed25-71d4-4d56-afab-9dfc4a1be60a"
    
    
    //let identityPoolId: String = "us-east-1:c87f0067-d1bf-44f8-b77f-d5ad70dc2946"
    let bucket = "swiftmeteor"
    
    //let identityPoolId: String = "us-west-2:c2265fbf-241f-45ba-b2a9-2f651228b868"
    let region = AWSRegionType.usWest2
    
    
    let accessKey           = "AKIAIMIHTAKR4RY7R2HA"
    let secret              = "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"
    private static var _sharedInstance: RVAWSDirect = RVAWSDirect()
    
    public static var sharedInstance: RVAWSDirect {
        get {
            return _sharedInstance
        }
    }
    
    public func launch() {
        AWSLogger.default().logLevel = AWSLogLevel.verbose
        let credentialsProvider: AWSCognitoCredentialsProvider = AWSCognitoCredentialsProvider(regionType: region, identityPoolId: identityPoolId)
        let configuration: AWSServiceConfiguration = AWSServiceConfiguration(region: AWSRegionType.usWest1, credentialsProvider: credentialsProvider)
        AWSServiceManager.default().defaultServiceConfiguration = configuration
        let syncClient = AWSCognito.default()
        if let  dataset = syncClient?.openOrCreateDataset("myDataset") {
            dataset.setString("myValue....zzzzz", forKey: "myKey")
            dataset.synchronize().continue({ (task) -> Any? in
                if let error = task.error {
                    print("Error RVAWSDirect \(error)")
                } else if let result  = task.result {
                    print("Result: \(result)")
                } else {
                    print("try")
                }
                if let cognitoId: String = credentialsProvider.identityId {
                    print("Id = \(cognitoId)")
                } else {
                    print("No id")
                }
                    //   RVAWSDirect.sharedInstance.tryIt()
                RVAWSDirect.sharedInstance.downloadFromS3()
                //RVAWSDirect.sharedInstance.tryIt2()
               //self.listObjects()
                return nil
            })
        } else {
            print("No dataset")
        }

        

        print("--------------- END OF LAUNCH ------------\n")
    }
    
    // http://docs.aws.amazon.com/mobile/sdkforios/developerguide/s3transfermanager.html
    // Upload in background
    func upload0(data: Data, path: String, contentType: String, callback: @escaping (Error?, String?)-> Void ) {
        
        let getPresignedURLRequest = AWSS3GetPreSignedURLRequest()
        let S3BucketName = "swiftmeteor"
        getPresignedURLRequest.bucket = S3BucketName
        getPresignedURLRequest.key = path
        getPresignedURLRequest.httpMethod = AWSHTTPMethod.PUT
        getPresignedURLRequest.expires = NSDate(timeIntervalSinceNow: 3600) as Date
        let fileContentTypeString = contentType
        getPresignedURLRequest.contentType = fileContentTypeString
        
        let t = AWSS3PreSignedURLBuilder.default().getPreSignedURL(getPresignedURLRequest)

        
        t.continue(successBlock: { (task: AWSTask!) -> AnyObject! in
            if let error = task.error {
                print(error)
            } else if let exception = task.exception {
                print(exception)
            } else if let presignedURL = task.result  {
                //     print("Got presignedURL")
                //     print("upload presigned URL is: \(presignedURL)\n\n")
                let interval: TimeInterval = 3600.0
                let request = NSMutableURLRequest(url: presignedURL as URL, cachePolicy: NSURLRequest.CachePolicy.reloadIgnoringLocalCacheData, timeoutInterval: interval)
                request.httpMethod = "PUT"
                request.setValue(fileContentTypeString, forHTTPHeaderField: "Content-Type")
                
                let uploatTask = URLSession.shared.uploadTask(with: request as URLRequest, from: data, completionHandler: { (data, response, error) in
                    if let error = error {
                        print(error)
                       // let error = RVError(message: "In \(self.classForCoder).upload0", sourceError: error)
                        callback(error, nil)
                        return
                    } else {
                        print("Completed uploading \(path) ")
                        if let response = response as? HTTPURLResponse {
                            print("In \(self.classForCoder).upload, ResponseStatus: \(response.statusCode)")
                            callback(nil, response.url?.absoluteString)
                        }
                        
                        //       print(response)
                        
                        //self.listObjects()
                    }
                })
                
                uploatTask.resume()
                
            } else {
                print("In \(self.classForCoder).upload in task closure, no presignURL")
            }
            return nil
        })
    }
    
    
    func listObjects() {
        let s3 = AWSS3.default()
        
        if let listObjectsRequest = AWSS3ListObjectsRequest() {
            s3.listObjects(listObjectsRequest).continue({ (task) -> Any? in
                if let error = task.error {
                    print("List Objects Error \(error)")
                } else if let exception = task.exception {
                    print("List objects exception \(exception)")
                
                } else if let result = task.result  {
                    if let contents = result.contents {
                        for s3Object in contents {
                            print(s3Object.key)
                        }
                    }
                } else {
                    print("listObjects no result no error")
                }
                return nil
            })
        }

    }
    public func uploadRequest(bucket: String, filename: String, sourceURL: URL) -> AWSS3TransferManagerUploadRequest {
        let uploadRequest: AWSS3TransferManagerUploadRequest = AWSS3TransferManagerUploadRequest()
        uploadRequest.bucket = bucket
        uploadRequest.key = filename
        uploadRequest.body = sourceURL
        return uploadRequest
    }
    public func upload(bucket: String, filename: String, sourceURL: URL) {
    
        let request = uploadRequest(bucket: bucket, filename: filename, sourceURL: sourceURL)
        let transferManager: AWSS3TransferManager = AWSS3TransferManager.default()
        let task: AWSTask<AnyObject> = transferManager.upload(request)
        
        let _: AWSTask<AnyObject> = task.continue(with: AWSExecutor.mainThread(), withSuccessBlock: { (result: AWSTask<AnyObject>) in
            if let error = task.error { // AWSS3TransferManagerErrorDomain
                // ErrorCancelled
                // ErrorPaused
                print("RVAWSDirect.updload got error \(error)")
            } else if let result = task.result {
                print("RVAWSDirect.upload succeeded \(result)");
            } else {
                print("In RVAWSDirect.upload, no error but no result")
            }
            return nil
        })
    }
    public func downloadRequest(bucket: String, sourcePath: String, destinationFileURL: URL) -> AWSS3TransferManagerDownloadRequest {
        let downloadRequest: AWSS3TransferManagerDownloadRequest = AWSS3TransferManagerDownloadRequest()
       // downloadRequest
        downloadRequest.bucket = bucket
        downloadRequest.key = sourcePath
        downloadRequest.downloadingFileURL = destinationFileURL
        return downloadRequest
    }
    public func download(bucket: String, sourcePath: String, destinationFileURL: URL) {
       print("In download....")
        let request = downloadRequest(bucket: bucket, sourcePath: sourcePath, destinationFileURL: destinationFileURL)
        let transferManager: AWSS3TransferManager = AWSS3TransferManager.default()
        let task: AWSTask<AnyObject> = transferManager.download(request)
        print("............ %%%%%%%%% before task")

        
        let _: AWSTask<AnyObject> = task.continue(with: AWSExecutor.mainThread(), with: { (result: AWSTask<AnyObject>) in
            print("CALLBACK.......")
            if let error = task.error { // AWSS3TransferManagerErrorDomain
                // ErrorCancelled
                // ErrorPaused
                print("--------------- In RVAWSDirect.download, have error \(error)")
            } else if let result = task.result  {
                print("-------------- In RVAWSDirect.download have result\n")
                print(result)
                //let image = UIImage(contentsOfFile: destinationFileURL)
            } else {
                print("------------ In RVAWSDirect.download, no error but no result")
            }
            return nil
        })
    }
    public func directoryTest() {
        let docsDir:String = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0].path
        //   let docsURL: URL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
        //    let subDirURL = docsURL.appendingPathComponent("SubDirectory")
        iterateThroughDirectory(directory: docsDir)
        
        let appTempDirectory: String = NSTemporaryDirectory()
        iterateThroughDirectory(directory: appTempDirectory)
        //  let downloadingURLPath = URL(string: downloadingFilePath)?.appendingPathComponent(filePath)
    }
    public func tryIt() {
        if let uploadingPath = getTestFilePath() {
            self.upload(bucket: bucket, filename: "elmerfudd.jpg", sourceURL: URL(fileURLWithPath: uploadingPath))
        }
    }
    public func tryIt2() {
        if let data = getData() {
            self.upload0(data: data, path: "upload0.jpg", contentType: "jpg", callback: { (error, result) in
                if let error = error {
                    print("TryIt2 error \(error)")
                } else if let result = result {
                    print("In TryIt2 result \(result)")
                } else {
                    print("In TryIt2 no error no result")
                }
            })
        }
    }
    public func downloadFromS3() {
        let dir = NSTemporaryDirectory()
        print("In downloadFromS3")
        let path = URL(fileURLWithPath: dir)
            print("have path \(path)")
            let pathFinal = path.appendingPathComponent("elmo.jpg")
            print("URL is.... \(pathFinal.path)")
            self.download(bucket: self.bucket, sourcePath: "ranch.jpg", destinationFileURL: pathFinal)
        
    }
    public func getData() -> Data? {
        let imageName = "ranch"
        let imageType = "jpg"
        if let filePath = Bundle.main.path(forResource: imageName, ofType: imageType) {
            print("\(filePath)")
            if let image = UIImage(contentsOfFile: filePath) {
                return UIImagePNGRepresentation(image)
            } else {
                print("Failed to get image")
            }
        } else {
            print("In RVAWSDirect.tryIt, failed to get filePath for image: \(imageName) of type: \(imageType)")
        }
        return nil
    }
    
    public func getTestFilePath() -> String? {
        let imageName = "ranch"
        let imageType = "jpg"
        if let filePath = Bundle.main.path(forResource: imageName, ofType: imageType) {
            print("\(filePath)")
            if let _ = UIImage(contentsOfFile: filePath) {
                print("Got image")
                return filePath
            } else {
                print("Failed to get image")
            }
        } else {
            print("In RVAWSDirect.tryIt, failed to get filePath for image: \(imageName) of type: \(imageType)")
        }
        return nil
    }
    public func iterateThroughDirectory(directory: String) {
        if FileManager.default.changeCurrentDirectoryPath(directory) {
            print("\nIn RVAWSDirect, changed directory to \(directory)")
            do {
                let filelist = try FileManager.default.contentsOfDirectory(atPath: "/")
                for filename in filelist {
                    print(filename)
                }
                print("--------------------------------")
            } catch let error {
                print("Error: \(error.localizedDescription)")
            }
        } else {
            print("In RVAWSDirect, failed to change directory to \(directory)")
            print("--------------------------------")
        }
        
    }
}
