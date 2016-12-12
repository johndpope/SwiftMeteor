//
//  RVS3Protocol.swift
//  SwiftMeteor
//
//  Created by Neil Weintraut on 11/30/16.
//  Copyright © 2016 Neil Weintraut. All rights reserved.
//

import UIKit
import AWSS3
//import AFNetworking

import AWSCore


class RVS3URLProtocol: URLProtocol {
    override class func canonicalRequest(for request: URLRequest) -> URLRequest {
        return request
    }
    override class func requestIsCacheEquivalent(_ a: URLRequest,
                                                to b: URLRequest) -> Bool {
        return super.requestIsCacheEquivalent(a , to: b)
    }

    override class func canInit(with task: URLSessionTask) -> Bool {
        // print("In RVS3URLProtocol can init with task")
        if let task = task as? URLSessionDataTask {
          //  print("In RVS3URLProtocl.canInit with taks, Have URLSessionDataTask")
            if let _ = task.originalRequest?.url?.host {
            //    print("In RVS3URLProtocol.canInit(with task, Host is \(host)")
                /*
                if let sourceHost = RVAWSDirect.baseURL.host {
                    print("Source Host is \(sourceHost)")
                    if host == sourceHost {
                        print("In RVS3URLProtocol, passed canInit with task \(host)")
                        return true
                    }
                }
 */
            }
            
            return false
        } else {
            return false
        }
    }
    

    override class func canInit(with request: URLRequest) -> Bool {
        // If the host is not Amazon S3 Server, return 'NO' to indicate default handling
        print("In RVS3URLProtocol")
        if let method = request.httpMethod {
            if method == "PUT" {return false}
        }
        if let url = request.url {
            print("&&&&&&&&&&&&&&&&&&&&&   In RVS3URLProtocol, url is \(url.absoluteString))")
            if let host = url.host {
                if let sourceHost = RVAWSDirect.baseURL.host {
                    if host == sourceHost {
                        //return false // NEIL PLUG FOR NOW
                       return true
                    } else {
                        return false
                    }
                }
                
            }
        }
        return false
    }
 
    override func startLoading() {
        // Extract the key from the request
        if let url = request.url {
            let path = url.path
            print("In RVS3URLProtocol, path is \(path)")
                getFile2(path: path)
                return
        } else {
            let error = NSError(domain: "io.rendevu", code: 404, userInfo: [NSLocalizedFailureReasonErrorKey: "No url"])
            self.client?.urlProtocol(self, didFailWithError: error)
            return
        }
    }
    override func stopLoading() {
        /*
        if let request = requestOperation {
            request.cancel()
            requestOperation = nil
        }
 */
    }
    func getFile2(path: String) {
        RVAWSDirect.sharedInstance.download2(path: path, completionHandler: {(data: Data?, response: URLResponse?, error: Error?) in
            if let client = self.client {
                if let error = error {
                    client.urlProtocol(self, didFailWithError: error)
                } else if let response = response {
                    if let response = response as? HTTPURLResponse {
                        client.urlProtocol(self, didReceive: response, cacheStoragePolicy: URLCache.StoragePolicy.allowed)
                        if response.statusCode == 200 {
                            if let data = data {
                                client.urlProtocol(self, didLoad: data)
                                client.urlProtocolDidFinishLoading(self)
                                return
                            }
                        }
                        
                    }
                }
                client.urlProtocolDidFinishLoading(self)
            }
        })
        
    }
//    var requestOperation: AFHTTPRequestOperation? = nil
    func getFile(path: String ) {
        
        /*
        let s3Manager = AFAmazonS3Manager(accessKeyID: RVAWS.sharedInstance.accessKey, secret: RVAWS.sharedInstance.secret)
        s3Manager.requestSerializer.region = AFAmazonS3USWest1Region
        s3Manager.requestSerializer.bucket = RVAWS.S3BucketName
        self.requestOperation = s3Manager.getObjectWithPath(path, progress: { (bytesJustSent: UInt, totalBytesSent: Int64, totalBytesExpected: Int64) -> Void in
            let percentage =  Int( (Double(totalBytesSent) / Double(totalBytesExpected) ) * 100.0 )
            let totalExpected = UInt(totalBytesExpected)
            NSNotificationCenter.defaultCenter().postNotificationName("RVS3URLProtocolProgress", object: self, userInfo: ["progress" : percentage, "totalBytesExpected": totalExpected, "path": path])
        }, success: { (responseObject: AnyObject!, data: NSData!) -> Void in
            if let responseObject = responseObject as? AFAmazonS3ResponseObject {
                if let originalResponse: NSHTTPURLResponse = responseObject.originalResponse {
                    dispatch_async(dispatch_get_main_queue(), { () -> Void in
                        self.client?.URLProtocol(self, didReceiveResponse: originalResponse , cacheStoragePolicy: NSURLCacheStoragePolicy.Allowed)
                        if let data = data {
                            self.client?.URLProtocol(self , didLoadData: data)
                            self.client?.URLProtocolDidFinishLoading(self)
                        }
                    })
                }
            }
        }) { (error: NSError!) -> Void in
            self.client?.URLProtocol(self, didFailWithError: error)
        }
 */
    }
}



/*
class RVAWSS3ManagerRequestSerializer: AFHTTPRequestSerializer {
    static let DefaultExpirationTimeInterval: TimeInterval = 60 * 60
    private var bucket: String
    private var region: AWSRegionType
    private var accessKey: String
    private var secret: String
    var sessionToken: String = ""
    private var useHTTPS: Bool = true
    /**
     A readonly endpoint URL created for the specified bucket, region, and TLS preference. `AFAmazonS3Manager` uses this as a `baseURL` unless one is manually specified.
     */
    /*
    public var endpointURL: URL {
        get {
            
        }
    }
 */
    init(bucket: String, region: AWSRegionType, accessKey: String, secret: String ){
        self.bucket = bucket
        self.region = region
        self.accessKey = accessKey
        self.secret = secret
        super.init()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    static func AFHMACSHA1EncodedDataFromStringWithKey(string: String, key: String) {
        if let data = string.data(using: String.Encoding.ascii) {
            if let keyCString = key.cString(using: String.Encoding.ascii) {
                if let hmacs5 = HMAC(algorithm: .sha1, key: string).update(data: data) {
                    let digest = Digest(algorithm: .sha1)
                  //  digest.update(data: hmacs5.)
                }
            }
            
        }
    }
    /**
     Returns a request with the necessary AWS authorization HTTP header fields from the specified request using the provided credentials.
     @param request The request.
     @param error The error that occured while constructing the request.
     @return The request with necessary `Authorization` and `Date` HTTP header fields.
     */
    public func requestBySettingAuthorizationHeader(request: URLRequest) -> (URLRequest?, Error?) {
        return (nil, nil)
    }
    /**
     Returns a request with pre-signed credentials in the query string.
     @param request The request. `HTTPMethod` must be `GET`.
     @param expiration The request expiration. If `nil`, defaults to 1 hour from when method is called.
     @param error The error that occured while constructing the request.
     @return The request with credentials signed in query string.
     */
    public func preSignedRequest(request: URLRequest, expiration: NSDate) -> (URLRequest?, Error?) {
        return (nil, nil)
    }
}
 */

