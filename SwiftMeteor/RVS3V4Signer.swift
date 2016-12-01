//
//  RVS3V4Signer.swift
//  SwiftMeteor
//
//  Created by Neil Weintraut on 11/30/16.
//  Copyright © 2016 Neil Weintraut. All rights reserved.
//

import Foundation
import AWSCore
import IDZSwiftCommonCrypto

class RVS3V4Signer {
    
    func test(pathToFile: String = "/swiftemeteor/ranch.jpg") {
        //let bodyDigest = FileHas
    }
    
    static let DefaultExpirationTimeInterval: TimeInterval = 60 * 60
    private var regionName: String
    private var accessKey: String
    private var secretKey: String
    private var serviceName: String
    var sessionToken: String = ""
    private var useHTTPS: Bool = true
    private let CC_SHA256_DIGEST_LENGTH = 32
    
    init(region: String, accessKey: String, secret: String, serviceName: String = "S3" ){
        self.regionName = region
        self.accessKey = accessKey
        self.secretKey = secret
        self.serviceName = serviceName
    }
    func signedHeaders(url: URL, bodyDigest: String, httpMethod: String = "PUT", date: Date = Date()) -> [String: String] {
        let datetime = timestamp(date: date)
        
        var headers = [
            "x-amz-content-sha256": bodyDigest,
            "x-amz-date": datetime,
            "x-amz-acl" : "public-read",
            "Host": url.host!,
            ]
        headers["Authorization"] = authorization(url: url, headers: headers, datetime: datetime, httpMethod: httpMethod, bodyDigest: bodyDigest)
        
        return headers
    }
    private func timestamp(date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyyMMdd'T'HHmmss'Z'"
        formatter.timeZone = TimeZone(abbreviation: "UTC")
        formatter.locale = Locale(identifier: "en_US_POSIX") // Locale(localeIdentifier: "en_US_POSIX")
        return formatter.string(from: date)
    }
    private func authorization(url: URL, headers: Dictionary<String, String>, datetime: String, httpMethod: String, bodyDigest: String) -> String {
        let cred = credential(datetime: datetime)
        let shead = signedHeaders(headers: headers)
        let sig = signature(url: url, headers: headers, datetime: datetime, httpMethod: httpMethod, bodyDigest: bodyDigest)
        
        return [
            "AWS4-HMAC-SHA256 Credential=\(cred)",
            "SignedHeaders=\(shead)",
            "Signature=\(sig)",
            ].joined(separator: ", ")
    }
    private func credential(datetime: String) -> String {
        return "\(accessKey)/\(credentialScope(datetime: datetime))"
    }
    private func signedHeaders(headers: [String:String]) -> String {
        var list = Array(headers.keys).map { $0.lowercased() }.sorted()
        if let itemIndex = list.index(of: "authorization") {
            list.remove(at: itemIndex)
        }
        return list.joined(separator: ";")
    }
    private func canonicalHeaders(headers: [String: String]) -> String {
        var list = [String]()
        let keys = Array(headers.keys).sorted {$0.localizedCompare($1) == ComparisonResult.orderedAscending}
        
        for key in keys {
            if key.caseInsensitiveCompare("authorization") != ComparisonResult.orderedSame {
                // Note: This does not strip whitespace, but the spec says it should
                list.append("\(key.lowercased()):\(headers[key]!)")
            }
        }
        return list.joined(separator: "\n")
    }
    
    private func signature(url: URL, headers: [String: String], datetime: String, httpMethod: String, bodyDigest: String) -> String? {
        if let secret = NSString(format: "AWS4%@", secretKey).data(using: String.Encoding.utf8.rawValue) {
            let index = datetime.index(datetime.startIndex, offsetBy: 8)
            let dateTimeString = datetime.substring(from: index)
            if let date = hmac(string: dateTimeString, key: secret) {
                if let region = hmac(string: regionName, key: date) {
                    if let service = hmac(string: serviceName, key: region) {
                        if let credentials = hmac(string: "aws4_request", key: service) {
                            if let string = stringToSign(datetime: datetime, url: url , headers: headers, httpMethod: httpMethod, bodyDigest: bodyDigest) {
                                if let sig = hmac(string: string, key: credentials) {
                                        return hexdigest(data: sig)
                                }

                            }
                        }

                    }

                }

            }

        }
        return nil
    }
    
    private func credentialScope(datetime: String) -> String {
        let index = datetime.index(datetime.startIndex, offsetBy: 8)
        let dateTimeString = datetime.substring(from: index)
        let strings = [
            dateTimeString,
            regionName,
            serviceName,
            "aws4_request"
            ]
        return self.joinStrings(strings: strings, with: "/")
    }
    private func pathForURL(url: URL) -> String? {
        var path = url.path
        if path == "" { path = "/" }
        return path
    }
    
    func sha256(str: String) -> String? {
        if let data = str.data(using: String.Encoding.utf8) {
           // let hash = [UInt8](repeating: 0, count: self.CC_SHA256_DIGEST_LENGTH)
            let sha256 = Digest(algorithm: .sha256)
            if let sha = sha256.update(data: data) {
                let stuff = sha.final()
                let res = Data(bytes: stuff)
                return hexdigest(data: res)
            }
        }
        return nil
    }
    
    private func hmac(string: String, key: Data) -> Data? {
       // let keyBytes = UnsafePointer<CUnsignedChar>(key.bytes)
        
      //  let data = string.cString(using: String.Encoding.utf8)
        
      //  let dataLen = Int(string.lengthOfBytes(using: String.Encoding.utf8))
     //   let digestLen = Int(CC_SHA256_DIGEST_LENGTH)
        
        if let hmac5 = HMAC(algorithm: .sha256, key: key).update(string: string) {
            let hmac5 = hmac5.final()
            //let result = UnsafeMutablePointer<CUnsignedChar>.alloc(digestLen)
            //CCHmac(CCHmacAlgorithm(kCCHmacAlgSHA256), keyBytes, key.length, data, dataLen, result);
            return Data(bytes: hmac5)
            //return Data(bytes: hmac5, length: digestLen)
        }
        return nil
    }
    
    private func hexdigest(data: Data) -> String {
        var hex = String()
        let bytes =  UnsafePointer<CUnsignedChar>(data.bytes)
        
        for i in 0 ..< data.count {
            hex += String(format: "%02x", bytes[i])
        }
        return hex
    }
    private func stringToSign(datetime: String, url: URL, headers: [String: String], httpMethod: String, bodyDigest: String) -> String? {
        if let request =  canonicalRequest(url: url, headers: headers, httpMethod: httpMethod, bodyDigest: bodyDigest) {
            if let sha256 = self.sha256(str: request) {
                let strings = [
                    "AWS4-HMAC-SHA256",
                    datetime,
                    credentialScope(datetime: datetime),
                    sha256,
                    ]
                return self.joinStrings(strings: strings, with: "\n")
            }
        }
        return nil

    }
    private func canonicalRequest(url: URL, headers: [String: String], httpMethod: String, bodyDigest: String) -> String? {
        let cHeaders = self.canonicalHeaders(headers: headers) + "\n"
        let query = url.query ?? ""
        if let path = pathForURL(url: url) {
            let strings = [
                httpMethod,                       // HTTP Method
                path,                  // Resource Path
                query,                  // Canonicalized Query String
                cHeaders, // Canonicalized Header String (Plus a newline for some reason)
                signedHeaders(headers: headers),           // Signed Headers String
                bodyDigest,                       // Sha265 of Body
            ]
            return self.joinStrings(strings: strings, with:"\n")
        }
        return nil
    }
    func joinStrings(strings: [String], with: String)-> String {
        let count = strings.count
        if count == 0 { return ""}
        var result = ""
        for i in 0..<strings.count {
            result = result + strings[i]
            if i < (count-1) { result = result + with }
        }
        return result
    }

}
