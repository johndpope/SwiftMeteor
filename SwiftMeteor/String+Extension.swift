//
//  String+Extension.swift
//  SwiftMeteor
//
//  Created by Neil Weintraut on 1/19/17.
//  Copyright © 2017 Neil Weintraut. All rights reserved.
//

import Foundation

extension String {
    //http://swiftdeveloperblog.com/email-address-validation-in-swift/
    func validEmail() -> Bool  {
        let email = self
        let emailRegEx = "[A-Z0-9a-z.-_]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,3}"
        do {
            let regex = try NSRegularExpression(pattern: emailRegEx, options: NSRegularExpression.Options.caseInsensitive)
            
            let match = regex.matches(in: email, options: NSRegularExpression.MatchingOptions.anchored, range: NSRange(location: 0, length: email.characters.count ) )
            if match.count == 0 { return false }
            return true
        } catch let error {
            print("In String Extension.validateEmail, go exception creating Regex \(error.localizedDescription)")
            return false
        }
    }
    func validPassword() -> Bool  {
        let password = self
        if password == "" { return false }
        if password.characters.count < 6 { return false }
        if password.contains(" ") { return false }
        return true
    }
    func index(from: Int) -> Index {
        return self.index(startIndex, offsetBy: from)
    }
    
    func substring(from: Int) -> String {
        let fromIndex = index(from: from)
        return substring(from: fromIndex)
    }
    
    func substring(to: Int) -> String {
        let toIndex = index(from: to)
        return substring(to: toIndex)
    }
    
    func substring(with r: Range<Int>) -> String {
        let startIndex = index(from: r.lowerBound)
        let endIndex = index(from: r.upperBound)
        return substring(with: startIndex..<endIndex)
    }
}
