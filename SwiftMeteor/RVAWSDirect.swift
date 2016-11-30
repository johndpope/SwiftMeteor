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
        let configuration: AWSServiceConfiguration = AWSServiceConfiguration(region: region, credentialsProvider: credentialsProvider)
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
                    print("No error but no result Nothing")
                }
                if let cognitoId: String = credentialsProvider.identityId {
                    print("Id = \(cognitoId)")
                } else {
                    print("No id")
                }
                return nil
            })
        } else {
            print("No dataset")
        }

        

        print("--------------- END OF LAUNCH ------------\n")
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
        let request = downloadRequest(bucket: bucket, sourcePath: sourcePath, destinationFileURL: destinationFileURL)
        let transferManager: AWSS3TransferManager = AWSS3TransferManager.default()
        let task: AWSTask<AnyObject> = transferManager.download(request)
        let _: AWSTask<AnyObject> = task.continue(with: AWSExecutor.mainThread(), withSuccessBlock: { (result: AWSTask<AnyObject>) in
            if let error = task.error { // AWSS3TransferManagerErrorDomain
                // ErrorCancelled
                // ErrorPaused
                print("In RVAWSDirect.download, have error \(error)")
            } else if let result = task.result  {
                print("In RVAWSDirect.download have result\n")
                print(result)
                //let image = UIImage(contentsOfFile: destinationFileURL)
            } else {
                print("In RVAWSDirect.download, no error but no result")
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
