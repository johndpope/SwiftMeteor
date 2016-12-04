//
//  RVDownloadTask.swift
//  SwiftMeteor
//
//  Created by Neil Weintraut on 12/3/16.
//  Copyright © 2016 Neil Weintraut. All rights reserved.
//

import UIKit
class RVDataTask: NSObject {
    var isDownloading = false
    var progress: Float = 0.0
    var downloadTask: URLSessionDataTask?
    var resumeData: Data?
    
    init(downloadTask: URLSessionDataTask) {
        self.downloadTask = downloadTask
        super.init()
        if self.absoluteURLString() == nil {
            print("Error, no URL String for RVDownload Task")
        }

    }
    func absoluteURLString() -> String? {
        if let downloadTask = downloadTask {
            if let urlString = downloadTask.originalRequest?.url?.absoluteString {
                return urlString
            }
        }
        return nil
    }
}
