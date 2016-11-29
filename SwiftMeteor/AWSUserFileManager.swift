//
//  AWSUserFileManager.swift
//  SwiftMeteor
//
//  Created by Neil Weintraut on 11/28/16.
//  Copyright © 2016 Neil Weintraut. All rights reserved.
//

import UIKit
import AWSCore
/*
 func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {
    let credentialProvider = AWSCognitoCredentialsProvider(regionType: .USEast1, identityPoolId: "YourIdentityPoolId")
    let configuration = AWSServiceConfiguration(region: .USWest2, credentialsProvider: credentialProvider)
    let userFileManagerConfiguration = AWSUserFileManagerConfiguration(bucketName: "myBucket", serviceConfiguration: configuration)
    AWSUserFileManager.registerUserFileManagerWithConfiguration(userFileManagerConfiguration, forKey: "USWest2BucketManager")
    return true
 }
 Then call the following to get the helper client: 
 let userFilemanager = AWSUserFileManager(forKey: "USWest2BucketManager")
 */

public protocol AWSUserFileProvider {
    func PUTURL(key: String, completionHanlder: (NSURL?, NSError?)-> Void ) -> Void
    func DELETEURL(key: String, completionHanlder: (NSURL?, NSError?)-> Void) -> Void
    func GetURL(key: String, completionHandler: (NSURL?, NSError?)-> Void) -> Void
}
public enum AWSContentManagerType {
    case S3
    case CloudFront
}
public enum AWSContentStatusType {
    case Unknown
    case NotStarted // "Has been created but has not started yet."
    case Running // Is running and transferring data from/to the remote server.
    case Completed
    case Failed
}
public enum AWSContentDownloadType {
    case IfNotCached
    case IfNewerExists // Downloads a file is not cached locally or the remote version is newer than the locally cached version.
    case Always // Downloads a file and overwrite it if the local cache exists.
}

public class AWSContentManager: NSObject, URLSessionDelegate {
    var contentProvider: AWSUserFileProvider?
    var URLSession: URLSession?
    var runningTasks: [AnyObject] = [AnyObject]()
    var bucket: String = "nothing"
    var type: AWSContentManagerType
    var serviceConfiguration: AWSServiceConfiguration
    var identifier: String
    /**
     *  The list of currently uploading contents.
     */
    var uploadingContents: [AnyObject] = [AnyObject]()
    var cloudFrontURL: String?
    init(type: AWSContentManagerType, bucket: String, cloudFrontURL: String?, serviceConfiguration: AWSServiceConfiguration, identifier: String) {
        self.bucket = bucket
        self.type = type
        self.serviceConfiguration = serviceConfiguration
        self.identifier = identifier
        self.cloudFrontURL = cloudFrontURL
        super.init()
    }
    public func urlSession(_ session: URLSession, didBecomeInvalidWithError error: Error?) {
    }
    public func urlSession(_ session: URLSession, didReceive challenge: URLAuthenticationChallenge, completionHandler: @escaping (URLSession.AuthChallengeDisposition, URLCredential?) -> Swift.Void) {
        
    }
    public func urlSessionDidFinishEvents(forBackgroundURLSession session: URLSession) {
        
    }
}

/**
 *  The content object that holds the cached data and its metadata.
 */
public class AWSContent: NSObject {
    var manager: AWSContentManager?
    /**
     *  The status of the content.
     */
    var status: AWSContentStatusType = AWSContentStatusType.NotStarted
    /**
     *  The Amazon S3 key associated with the content.
     */
    var key: String = ""
    /**
     *  Shows if the content is a directory.
     */
    public var directory: Bool = false
    /**
     *  The transfer progress.
     */
    var progress: Progress?
    var pinOnCompletion: Bool = false
    /**
     *  The status of the content.
     */
    var uploadData: NSData?
    /**
     *  The last known size reported by the Amazon S3. May be different from the actual size if the file was modified on the server.
     */
    public var knownRemoteByteCount: UInt = 0
    /**
     *  The last known last modified date reported by the Amazon S3. May be different from the actual last modified date if the file was modified on the server.
     */
    public var knownRemoteLastModifiedDate: NSDate?
    /**
     *  The cached data object.
     */
    public var cachedData: NSData?
    
    /**
     *  The cached data size.
     */
    public var fileSize: UInt = 0
    
    /**
     *  The date the cached data was downloaded.
     */
    public var downloadedDate: NSDate?
    /**
     *  Weather the content is pinned. Pinned objects are not subject to the content cache limit.
     */
    public var pinned: Bool = false
    
    /**
     *  Wheather the content is locally cached.
     */
    public var cached: Bool = false
    var uploadProgressBlock: (AWSLocalContent, Progress) -> Void = {(content: AWSLocalContent, progress: Progress) -> Void in }
    var uploadCompletionHandler: (AWSLocalContent, Error?) -> Void = {(content: AWSLocalContent, error: Error?) -> Void in }
    var downloadProgressBlock: ((AWSLocalContent, Progress) -> Void)?
    var downloadCompletionHandler: (AWSContent?, NSData?, NSError?) -> Void = {(content: AWSContent?, data: NSData?, error: NSError?)  -> Void in }
    init(manager: AWSContentManager) {
        self.manager = manager
        self.directory = false
        self.status = AWSContentStatusType.NotStarted
        super.init()

    }
    override init() {
        super.init()
    }
    public func isCached() -> Bool {
        return false
    }
    public func isPinned() -> Bool {
        return false
    }
    public func dowloadedDate() -> NSDate? {
        return nil
    }
    public func filexSize() -> UInt {
        return 0
    }
    public func Progress() -> Progress? {
        return self.progress
    }
    public func isDirectory() -> Bool {
        return self.directory
    }

    func removeContent(content: AWSContent) {
        content.removeRemoteContent(completionHandler: {(content: AWSContent?, error: NSError?) -> Void in
            if let error = error {
                print("Failed to delete an object from the remote server. \(error)")
            } else {
                print("Success")
                // Do something further
            }
        })
    }
    func removeRemoteContent(completionHandler: (AWSContent?, NSError?) -> Void) -> Void {
        print("RemoveRemoteCntent not implemented")
    }
    let AWSContentManagerErrorDomain = "AWSContentManagerErrorDomain"
    /*
    @param loadingType       Specifies the loading behavior for downloading data.
    @param pinOnCompletion   When set to `YES`, it pins the content on completion. You can download a content that does not fit in the content cache by setting it to `YES`.
    @param progressBlock     The progress feedback block.
    @param completionHandler The completion handler block.
    */
    public func downloadWithDownloadType(loadingType: AWSContentDownloadType, pinOnCompletion: Bool, progressBlock: ((AWSContent, Progress) -> Void)?, callback: @escaping (AWSContent?, NSData?, NSError?) -> Void) {
        if self.isDirectory() {
            let error = NSError(domain: AWSContentManagerErrorDomain, code: 99, userInfo: nil)
            callback(nil, nil, error)
            return
        }
        if self.status == AWSContentStatusType.Running {
            let error = NSError(domain: AWSContentManagerErrorDomain, code: 98, userInfo: nil)
            callback(nil, nil, error)
            return
        } else if loadingType == AWSContentDownloadType.IfNotCached {
            if let cachedData: NSData = self.cachedData {
                callback(self, cachedData, nil)
                return
            }
        }
        self.status = AWSContentStatusType.Running
        self.downloadCompletionHandler = callback
        self.downloadProgressBlock = progressBlock
        if let contentManager = self.manager {
           let weakSelf = self
            if let provider = contentManager.contentProvider {
                provider.GetURL(key: key, completionHandler: { (url, error) in
                    if let error = error {
                        callback(nil, nil, error)
                        return
                    } else if let url = url {
                        
                            let request = NSMutableURLRequest(url: url as URL, cachePolicy: NSURLRequest.CachePolicy.reloadIgnoringCacheData, timeoutInterval: 10000)
                            request.httpMethod = "GET"
                            // NEIL
                            if (loadingType == AWSContentDownloadType.IfNewerExists) {
                                if let _: NSData = weakSelf.cachedData {
                                    //request.addValue(cachedData, forHTTPHeaderField: "If-None-Match")
                                }
                            }
                            /*
                            if let downloadTask = contentManager.URLSession?.downloadTask(with: request) {
                               contentManager.runningTasks[downloadTask.taskIdentifier] = weakSelf
                            }
 */
                        
                        
                    } else {
                        
                    }
                })
            }
        }
    }
    public func getRemoteFileURLWithCompletionHandler(completionHandler: (NSURL?, NSError?) -> Void) {
        print("No implemented")
    }
    
    /**
     *  Pins the locally cached object. Pinned objects are not subject to the content cache limit.
     */
    public func pin() {
        self.pinned = true
    }
    
    /**
     *  Unpins the pinned object. It may purge the content cache if the content cache does not have enough available space to fit the unpinned data.
     */
    public func unPin() {
        self.pinned = false
    }
    
    /**
     *  Removes locally cached data regardless of the pinning status.
     */
    public func removeLocal() {
        self.cached = false
        self.cachedData = nil
    }
    
}
public class AWSUserFileManager: AWSContentManager {
    

    private static let AWSInfoUserFileManager = "UserFileManager"
    private static let AWSUserFileManagerBucketName = "S3Bucket"
    private static var _serviceClients: AWSSynchronizedMutableDictionary = AWSSynchronizedMutableDictionary()
    private static var _defaultUserFileManager: AWSUserFileManager?
    
    // Returns the default User File Manager singleton instance configured using the information provided in `Info.plist` file.
    class func defaultUserFileManager() -> AWSUserFileManager? {
        if let manager = AWSUserFileManager._defaultUserFileManager { return manager }
        let myGlobal: () = { () -> Void in
            var serviceConfiguration: AWSServiceConfiguration? = nil
            var bucketName: String? = nil
            if let serviceInfo: AWSServiceInfo = AWSInfo.default().defaultServiceInfo(AWSUserFileManager.AWSInfoUserFileManager) {
                serviceConfiguration = AWSServiceConfiguration(region: serviceInfo.region, credentialsProvider: serviceInfo.cognitoCredentialsProvider)
                if let name = serviceInfo.infoDictionary[AWSUserFileManager.AWSUserFileManagerBucketName] as? String {
                    bucketName = name
                }
            }
            if serviceConfiguration == nil {
                serviceConfiguration = AWSServiceManager.default().defaultServiceConfiguration
            }
            if let bucketName = bucketName {
                if let serviceConfiguration = serviceConfiguration {
                    AWSUserFileManager._defaultUserFileManager = AWSUserFileManager(type: AWSContentManagerType.S3, bucket: bucketName, cloudFrontURL: nil , serviceConfiguration: serviceConfiguration, identifier: AWSInfoDefault)
                }
                
            }
            print("In AWSUserFileManager.defautUserFileManager(), the Push Manager specifric configuraiton is set incorrectly in the Info.plist")
        }()
        _ = myGlobal
        return AWSUserFileManager._defaultUserFileManager
    }
    /**
     Retrieves the helper client associated with the key. You need to call `+ registerUserFileManagerWithConfiguration:forKey:` before invoking this method. If `+ registerUserFileManagerWithConfiguration:forKey:` has not been called in advance or the key does not exist, this method returns `nil`.
     
     let credentialProvider = AWSCognitoCredentialsProvider(regionType: .USEast1, identityPoolId: "YourIdentityPoolId")
     let configuration = AWSServiceConfiguration(region: .USWest2, credentialsProvider: credentialProvider)
     let userFileManagerConfiguration = AWSUserFileManagerConfiguration(bucketName: "myBucket", serviceConfiguration: configuration)
     AWSUserFileManager.registerUserFileManagerWithConfiguration(userFileManagerConfiguration, forKey: "USWest2BucketManager")
     Then call the following to get the helper client:
     let UserFilemanager = AWSUserFileManager.UserFileManager(forKey: "USWest2BucketManager")
     */
    class func UserFileManager(forKey key: String) -> AWSUserFileManager? {
        if let serviceClient: AWSUserFileManager = AWSUserFileManager._serviceClients.object(forKey: key) as? AWSUserFileManager {
           return serviceClient
        } else {
            if let serviceInfo: AWSServiceInfo = AWSInfo.default().serviceInfo(AWSUserFileManager.AWSInfoUserFileManager, forKey: key) {
                if let serviceConfiguration: AWSServiceConfiguration = AWSServiceConfiguration(region: serviceInfo.region, credentialsProvider: serviceInfo.cognitoCredentialsProvider) {
                    if let bucketName: String = serviceInfo.infoDictionary[AWSUserFileManager.AWSUserFileManagerBucketName] as? String {
                        let userFileManagerConfiguration: AWSUserFileManagerConfiguration = AWSUserFileManagerConfiguration(bucketName: bucketName, serviceConfiguration: serviceConfiguration)
                        AWSUserFileManager.registerUserFileManager(configuration: userFileManagerConfiguration, key: key)
                    } else {
                        print("No bucketName in AWSUserFileManager.UserFileManager(key...")
                    }
                } else {
                    print("No serviceConfiguration in AWSUserFileManager.UserFileManager(key...")
                }
            } else {
                print("No serviceInfo in AWSUserFileManager.UserFileManager(key...)")
            }
            return AWSUserFileManager._serviceClients.object(forKey: key) as! AWSUserFileManager?
        }
    }
    /*
     @warning After calling this method, do not modify the configuration object. It may cause unspecified behaviors.
     @param  configuration    AWSUserFileManagerConfiguration object for the manager.
     @param  key              A string to identify the helper client.
    */

    class func registerUserFileManager(configuration: AWSUserFileManagerConfiguration, key: String ) {
        if key == AWSInfoDefault {
            print("AWSUserFileManager.registerUserFileManager ERROR. The key -\(key) - used for registering this instance is reserved key.")
        } else {
            let myGlobal: () = {()-> Void in
                AWSUserFileManager._serviceClients = AWSSynchronizedMutableDictionary()
            }()
            _ = myGlobal
            let manager = AWSUserFileManager(type: AWSContentManagerType.S3, bucket: configuration.bucketName, cloudFrontURL: nil, serviceConfiguration: configuration.serviceConfiguration, identifier: key)
            self._serviceClients.setObject(manager, forKey: key as NSCopying!)
        }
    }

    class func removeUserFileManagerForKey(key: String) -> Void {
        AWSUserFileManager._serviceClients.removeObject(forKey: key)
    }
    
 
    
    /**
     Returns an instance of `AWSLocalContent`. You use this method to create an instance of `AWSLocalContent` to upload data to an Amazon S3 bucket with the specified key.

     func uploadWithData(data: NSData, forKey key: String) {
        let userFilemanager = AWSUserFileManager(forKey: "KeyUsedToRegister")
        let localContent = userFilemanager.localContentWithData(data, key: key)
        localContent.uploadWithPinOnCompletion(..., progressBlock: ..., completionHandler: ...)
     }
     */
    /*
     @param data The data to be uploaded.
     @param key  The Amazon S3 key.
     @return An instance of `AWSLocalContent` that represents data to be uploaded.
     
     */
    func localContentWithData(data: NSData, key: String) -> AWSLocalContent {
        return AWSLocalContent(data: data, key: key)
    }
    public func PUTURL(key: String, completionHanlder: (url: NSURL?, error: NSError?) ) -> Void {
        print("AWSUserFileManager.PUTURL not implemented")
    }
    public func DELETEURL(key: String, completionHanlder: (url: NSURL?, error: NSError?)) -> Void {
        print("AWSUserFileManager.DELETEURL not implemented")
    }
    
    
    
}

/**
 *  A representation of the local content that may not exist in the Amazon S3 bucket yet. When uploading data to an S3 bucket, you first need to create an instance of this class.
 */
public class AWSLocalContent: AWSContent {

    var data: NSData?

    init(data: NSData, key: String) {
        super.init()
        self.data = data
        self.key = key
    }
    init(manager:AWSContentManager, data: NSData, key: String) {
        super.init(manager: manager)
        self.data = data
        self.key = key
    
    }
    /**
        Uploads data associated with the local content.
        @param pinOnCompletion   When set to `YES`, it pins the content after finishing uploading it.
     */
     func uploadWithData(data: NSData, forKey key: String) {
        if let userFilemanager = AWSUserFileManager.UserFileManager(forKey: key) {
            let localContent = userFilemanager.localContentWithData(data: data, key: key)
            localContent.uploadWithPinOnCompletion(pinOnCompletion: false, progressBlock: {(content: AWSLocalContent?, progress: Progress?) -> Void in
                // handle progress here
            }, completionHandler: {(content: AWSContent?, error: NSError?) -> Void in
                if let error = error {
                    // handle error here
                    print("Error occured in uploading: \(error)")
                    return
                }
                // handle successful upload here
            })
        } else {
            print("In AWSLocalContent.uploadWithData, did not find AWSUserFileManager for key \(key)")
        }
     }
    /**
     Uploads data associated with the local content.
     func uploadWithData(data: NSData, forKey key: String) {
        let userFilemanager = AWSUserFileManager(forKey: "KeyUsedToRegister")
        let localContent = userFilemanager.localContentWithData(data, key: key)
        localContent.uploadWithPinOnCompletion(false, progressBlock: {(content: AWSLocalContent?, progress: NSProgress?) -> Void in
            // handle progress here
        }, completionHandler: {(content: AWSContent?, error: NSError?) -> Void in
            if let error = error {
                // handle error here
                print("Error occured in uploading: \(error)")
            return
        }
        // handle successful upload here
     })
 }
 */
     /*
     @param pinOnCompletion   When set to `YES`, it pins the content after finishing uploading it.
     @param progressBlock     The upload progress block.
     @param completionHandler The completion handler block.
     */
    public func uploadWithPinOnCompletion(pinOnCompletion: Bool, progressBlock: ((AWSLocalContent, Progress) -> Void)?, completionHandler: ((AWSLocalContent?, NSError?) -> Void)?) {
    }
}
public class AWSUserFileManagerConfiguration: NSObject {
    var bucketName: String
    private var _serviceConfiguration: AWSServiceConfiguration? = nil
    /**
     Returns an instance of `AWSUserFileManagerConfiguration`. Use this as the configuration object for AWSUserFileManager.
     let credentialProvider = AWSCognitoCredentialsProvider(regionType: .USEast1, identityPoolId: "YourIdentityPoolId")
     let configuration = AWSServiceConfiguration(region: .USWest2, credentialsProvider: credentialProvider)
     let userFileManagerConfiguration = AWSUserFileManagerConfiguration(bucketName: "myBucket", serviceConfiguration: configuration)
     AWSUserFileManager.registerUserFileManagerWithConfiguration(userFileManagerConfiguration, forKey: "USWest2BucketManager")
     @param  bucketName              Name of the bucket
     @param  serviceConfiguration    AWSServiceConfiguration object; nil for default configuration
     @return an instance of AWSUserFileManagerConfiguration
     
     */
    init(bucketName: String, serviceConfiguration: AWSServiceConfiguration) {
        self.bucketName = bucketName
        self._serviceConfiguration = serviceConfiguration
        super.init()
    }
    /**
    Returns an instance of `AWSUserFileManagerConfiguration` using the default service configuration. Use this as the configuration object for AWSUserFileManager.
     let credentialProvider = AWSCognitoCredentialsProvider(regionType: .USEast1, identityPoolId: "YourIdentityPoolId")
     let configuration = AWSServiceConfiguration(region: .USWest2, credentialsProvider: credentialProvider)
     AWSServiceManager.defaultServiceManager().defaultServiceConfiguration = configuration
     let userFileManagerConfiguration = AWSUserFileManagerConfiguration(bucketName: "myBucket")
     AWSUserFileManager.registerUserFileManagerWithConfiguration(userFileManagerConfiguration, forKey: "USWest2BucketManager")
    */
    /*
     @param  bucketName              Name of the bucket
     @return an instance of AWSUserFileManagerConfiguration
     */
    init(bucketName: String) {
        self.bucketName = bucketName
        self._serviceConfiguration = nil
        super.init()
    }
    var serviceConfiguration: AWSServiceConfiguration {
        get {
            if let configuration = self._serviceConfiguration { return configuration }
            return AWSServiceManager.default().defaultServiceConfiguration
        }
    }
    
}
