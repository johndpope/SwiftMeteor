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
class Download: NSObject {
    
    var url: String
    var isDownloading = false
    var progress: Float = 0.0
    
    var downloadTask: URLSessionDownloadTask?
    var resumeData: Data?
    
    init(url: String) {
        self.url = url
    }
}
extension RVAWSDirect: URLSessionDownloadDelegate {
    /* Sent when a download task that has completed a download.  The delegate should
     * copy or move the file at the given location to a new location as it will be
     * removed when the delegate message returns. URLSession:task:didCompleteWithError: will
     * still be called.
     */
    public func urlSession(_ session: URLSession, downloadTask: URLSessionDownloadTask, didFinishDownloadingTo location: URL) {
        print("In Delegate, didFinishLoadingTo.... URL \(location)")
    }
    
    
    /* Sent periodically to notify the delegate of download progress. */
    public func urlSession(_ session: URLSession, downloadTask: URLSessionDownloadTask, didWriteData bytesWritten: Int64, totalBytesWritten: Int64, totalBytesExpectedToWrite: Int64) {
        print("In download delegate, bytesWritten \(totalBytesWritten) total: \(totalBytesExpectedToWrite)")
        if let downloadURL = downloadTask.originalRequest?.url?.absoluteString {
            if let download = activeDownloads[downloadURL] {
                download.progress = Float(totalBytesWritten)/Float(totalBytesExpectedToWrite)
               // let totalSize = ByteCountFormatter.string(fromByteCount: totalBytesExpectedToWrite, countStyle: ByteCountFormatter.CountStyle.binary)
            }
        }
    }
    
    
    /* Sent when a download has been resumed. If a download failed with an
     * error, the -userInfo dictionary of the error will contain an
     * NSURLSessionDownloadTaskResumeData key, whose value is the resume
     * data.
     */

    public func urlSession(_ session: URLSession, downloadTask: URLSessionDownloadTask, didResumeAtOffset fileOffset: Int64, expectedTotalBytes: Int64) {
        
    }
}

public class RVAWSDirect: NSObject {

    var activeDownloads = [Int: Download]()
    let defaultServiceRegionType = AWSRegionType.usWest1
    static let s3domainAddress     = "s3.amazonaws.com"
    static let amazonDomainAddress = "amazonaws.com"
    let transferManagerIdentifier: String = "USWest2S3TransferManager"
    let identityPoolId = "us-west-2:035aed25-71d4-4d56-afab-9dfc4a1be60a"

    static let bucket = "swiftmeteor"
    

    let cognitoRegion = AWSRegionType.usWest2
    let S3Region = AWSRegionType.usWest1
    
    static let accessKey           = "AKIAIMIHTAKR4RY7R2HA"
    static let secret              = "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"
    
    
    // Attached path in the format of: directoryi/directoryii.../filename (note no leading slash)
    static let baseURL: URL = {
        URL(string: "https://\(RVAWSDirect.bucket).\(RVAWSDirect.s3domainAddress)")!
    }()
    private static var _sharedInstance: RVAWSDirect = RVAWSDirect()
    
    public static var sharedInstance: RVAWSDirect {
        get {
            return _sharedInstance
        }
    }
    
    public func launch() {
        AWSLogger.default().logLevel = AWSLogLevel.verbose
        //URLProtocol.registerClass(RVS3URLProtocol.self)
        let credentialsProvider: AWSCognitoCredentialsProvider = AWSCognitoCredentialsProvider(regionType: self.cognitoRegion, identityPoolId: self.identityPoolId)
        let configuration: AWSServiceConfiguration = AWSServiceConfiguration(region: self.S3Region, credentialsProvider: credentialsProvider)
        AWSServiceManager.default().defaultServiceConfiguration = configuration
        //   RVAWSDirect.sharedInstance.tryIt()
        //RVAWSDirect.sharedInstance.downloadFromS3()
       

     //   RVAWSDirect.sharedInstance.download0(path: "elmerfudd.jpg")
        let path = "elmerfudd.jpg"
        RVAWSDirect.sharedInstance.download1(path: path, completionHandler: self.processIt)
        
        //RVAWSDirect.sharedInstance.tryIt2()
        //self.listObjects()

        

        print("--------------- END OF LAUNCH ------------\n")
    }
    func syncTest() {
        let syncClient = AWSCognito.default()
        if let  dataset = syncClient?.openOrCreateDataset("myDataset") {
            dataset.setString("myValue....zzzzz", forKey: "myKey")
            dataset.synchronize().continue({ (task) -> Any? in
                if let error = task.error {
                    print("Error RVAWSDirect \(error)")
                } else if let result  = task.result {
                    print("Result: \(result)")
                } else {
                    print("In AWSDirect.syncTest no error but no result")
                }

                return nil
            })
        } else {
            print("No dataset")
        }
    }
    
    func processIt(err: Error?, response: URLResponse?, url: URL?) throws -> Void  {
        if let err = err {
            print("RVAWSDirect processIt error \(err)")
        } else if let response = response {
            if let response = response as? HTTPURLResponse {
                if response.statusCode == 200 {
                    
                    if let url = url {
                        do {
                            let _ = try Data(contentsOf: url)
                            print("Successfully got data. AWSDirect processIt")
                        } catch   {
                            print("Data retrieval error \(error)")
                        }
                    }
                    //
                }
            }
        }
    }
    
    func download2(path: String, completionHandler: @escaping (Data?, URLResponse?, Error?) -> Void  ) {
        let getPresignedURLRequest = AWSS3GetPreSignedURLRequest()
        getPresignedURLRequest.bucket = RVAWSDirect.bucket
        getPresignedURLRequest.key = path
        getPresignedURLRequest.httpMethod = AWSHTTPMethod.GET
        getPresignedURLRequest.expires = NSDate(timeIntervalSinceNow: 3600) as Date
        let t = AWSS3PreSignedURLBuilder.default().getPreSignedURL(getPresignedURLRequest)
        t.continue(successBlock: { (task: AWSTask!) -> AnyObject! in
            if let error = task.error {
                print(error)
            } else if let exception = task.exception {
                print(exception)
            } else if let presignedURL = task.result  {
                print("download presigned URL is: \(presignedURL)\n\n")
                let request = URLRequest(url: presignedURL as URL)
                UIApplication.shared.isNetworkActivityIndicatorVisible = true
                let session = URLSession(configuration: URLSessionConfiguration.ephemeral, delegate: RVAWSDirect.sharedInstance, delegateQueue: OperationQueue.main)
                self.activeDownloads[session.hashValue] = session
                let downloadTask = session.dataTask(with: request, completionHandler: { (data, response, error) in
                    DispatchQueue.main.async {
                        UIApplication.shared.isNetworkActivityIndicatorVisible = false
                        
                        completionHandler(data, response, error)
                    }
                })
                downloadTask.resume()
            } else {
                print("In \(self.classForCoder).upload in task closure, no presignURL")
            }
            return nil
        })
    }
    
    func download1(path: String, completionHandler: @escaping (Error?, URLResponse?, URL?) throws -> Void  ) {
        
        let getPresignedURLRequest = AWSS3GetPreSignedURLRequest()
        
        getPresignedURLRequest.bucket = RVAWSDirect.bucket
        getPresignedURLRequest.key = path
        getPresignedURLRequest.httpMethod = AWSHTTPMethod.GET
        getPresignedURLRequest.expires = NSDate(timeIntervalSinceNow: 3600) as Date
        let t = AWSS3PreSignedURLBuilder.default().getPreSignedURL(getPresignedURLRequest)
        t.continue(successBlock: { (task: AWSTask!) -> AnyObject! in
            if let error = task.error {
                print(error)
            } else if let exception = task.exception {
                print(exception)
            } else if let presignedURL = task.result  {
                print("download presigned URL is: \(presignedURL)\n\n")
                let request = NSMutableURLRequest(url: presignedURL as URL)
                UIApplication.shared.isNetworkActivityIndicatorVisible = true
                
                let downloadTask =  URLSession.shared.downloadTask(with: request as URLRequest , completionHandler: { (url: URL?, response: URLResponse?, error) in
                    UIApplication.shared.isNetworkActivityIndicatorVisible = false
                    //NSNotificationCenter.defaultCenter().postNotificationName("RVS3URLProtocolProgress", object: self, userInfo: ["progress" : percentage, "totalBytesExpected": totalExpected, "path": path])
                    do {
                        try completionHandler(error, response, url)
                    } catch {
                        print("In AWSDirect.download1, got exception with handler \(error)")
                    }
                })
                downloadTask.resume()
            } else {
                print("In \(self.classForCoder).upload in task closure, no presignURL")
            }
            return nil
        })
    }
    
    // http://docs.aws.amazon.com/mobile/sdkforios/developerguide/s3transfermanager.html
    // Upload in background
    func download0(path: String) {
        
        let getPresignedURLRequest = AWSS3GetPreSignedURLRequest()
        let S3BucketName = "swiftmeteor"
        getPresignedURLRequest.bucket = S3BucketName
        getPresignedURLRequest.key = path
        getPresignedURLRequest.httpMethod = AWSHTTPMethod.GET
        getPresignedURLRequest.expires = NSDate(timeIntervalSinceNow: 3600) as Date
       // let fileContentTypeString = contentType
      //  getPresignedURLRequest.contentType = fileContentTypeString
        
        let t = AWSS3PreSignedURLBuilder.default().getPreSignedURL(getPresignedURLRequest)
        
        
        t.continue(successBlock: { (task: AWSTask!) -> AnyObject! in
            if let error = task.error {
                print(error)
            } else if let exception = task.exception {
                print(exception)
            } else if let presignedURL = task.result  {
                     print("Got presignedURL")
                     print("download presigned URL is: \(presignedURL)\n\n")

                let request = NSMutableURLRequest(url: presignedURL as URL)
              //  request.httpMethod = "GET"
               // request.setValue(fileContentTypeString, forHTTPHeaderField: "Content-Type")
                
                let downloadTask =  URLSession.shared.downloadTask(with: request as URLRequest , completionHandler: { (url: URL?, response: URLResponse?, error) in
                    if let error = error {
                        print("In download0, got error \(error)")
                    } else if let response = response  {
                        if let response = response as? HTTPURLResponse {
                            print("In download0, got response: \(response.statusCode)")
                            if response.statusCode == 200 {
                                if url != nil {
                                    /*
                                    do {
                                        let data = try Data(contentsOf: url)
                                     let image = UIImage(data: data)
                                    } catch error {
                                        print("\(error)")
                                    }
                                    */
                                    
                                }
                            }

                        }

                    }
                    if let url = url {
                        print("In download0, get URL \(url)")
                    }
                })

                downloadTask.resume()

                
            } else {
                print("In \(self.classForCoder).upload in task closure, no presignURL")
            }
            return nil
        })
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
                            if let key = s3Object.key{
                                print(key)
                            }
                            
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
            self.upload(bucket: RVAWSDirect.bucket, filename: "elmerfudd.jpg", sourceURL: URL(fileURLWithPath: uploadingPath))
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
            self.download(bucket: RVAWSDirect.bucket, sourcePath: "ranch.jpg", destinationFileURL: pathFinal)
        
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
