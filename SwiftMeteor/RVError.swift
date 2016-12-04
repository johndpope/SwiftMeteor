//
//  RVError.swift
//  SwiftMeteor
//
//  Created by Neil Weintraut on 11/29/16.
//  Copyright © 2016 Neil Weintraut. All rights reserved.
//

//
//  RVError.swift
//  rendevu
//
//  Created by Neil Weintraut on 7/15/16.
//  Copyright © 2016 Neil Weintraut. All rights reserved.
//

import UIKit


class RVError: NSError {
    static var domain: String = "RV"
    var sourceError: Error? = nil
    var messages = [String]()
    var fileName: String = ""
    var functionName: String = ""
    var time = NSDate()
    var lineNumber: Int = -1
    
    init(message: String, sourceError: Error? = nil) {
        super.init(domain: RVError.domain, code: 0, userInfo: ["message": message])
        self.messages = [message]
        if let error = sourceError { self.sourceError = error }
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    func append(message: String) {
        self.messages.insert(message, at: 0)
    }
    func output() -> String {
        var messages = ""
        for message in self.messages.enumerated() {
            messages += "\(message)\n"
        }
        var output = "Need to replace "
//        var output = "--- at \(RVDateFormatter.ddHHmmsssss.stringFromDate(time)) Error in \(fileName)\(functionName).\(lineNumber)\n\(messages)"
        if let error = self.sourceError {
            output += "\(error)"
        }
        output += "\n------------------------- End Error Message -----------------------------------"
        return output
    }
    func printError() {
        print(output())
    }
}
