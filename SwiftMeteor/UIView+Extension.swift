//
//  UIView+Extension.swift
//  SwiftMeteor
//
//  Created by Neil Weintraut on 1/15/17.
//  Copyright © 2017 Neil Weintraut. All rights reserved.
//

import UIKit

extension UIView {
    
    func lock() {
        if let _ = viewWithTag(10) {
            //View is already locked
        }
        else {
            let lockView = UIView(frame: bounds)
            lockView.backgroundColor = UIColor(white: 0.0, alpha: 0.75)
            lockView.tag = 10
            lockView.alpha = 0.0
            let activity = UIActivityIndicatorView(activityIndicatorStyle: .white)
            activity.hidesWhenStopped = true
            activity.center = lockView.center
            lockView.addSubview(activity)
            activity.startAnimating()
            addSubview(lockView)
            
            UIView.animate(withDuration: 0.2) {
                lockView.alpha = 1.0
            }
        }
    }
    
    func unlock() {
        if let lockView = viewWithTag(10) {
            UIView.animate(withDuration: 0.2, animations: {
                lockView.alpha = 0.0
            }) { finished in
                lockView.removeFromSuperview()
            }
        }
    }
    
    func fadeOut(duration: TimeInterval) {
        UIView.animate(withDuration: duration) {
            self.alpha = 0.0
        }
    }
    
    func fadeIn(duration: TimeInterval) {
        UIView.animate(withDuration: duration) {
            self.alpha = 1.0
        }
    }
    
    class func viewFromNibName(name: String) -> UIView? {
        let views = Bundle.main.loadNibNamed(name, owner: nil, options: nil)
        if let views = views {
            if let view = views.first as? UIView {
                return view
            }
        }
        return nil
    }
    /**
     Given an Array of CGColor, it will:
     - Remove all sublayers of type CAGradientLayer.
     - Create and insert a new CAGradientLayer.
     
     - Parameters:
     - colors: An Array of CGColor with the colors for the gradient fill
     
     - Returns: The newly created gradient CAGradientLayer
     */
    // http://stackoverflow.com/questions/24380535/how-to-apply-gradient-to-background-view-of-ios-swift-app
    func layerGradient(colors c:[CGColor])->CAGradientLayer {
        self.layer.sublayers = self.layer.sublayers?.filter(){!($0 is CAGradientLayer)}
        let layer : CAGradientLayer = CAGradientLayer()
        layer.frame.size = self.frame.size
        layer.frame.origin = CGPoint(x: 0, y: 0)
        layer.colors = c
        self.layer.insertSublayer(layer, at: 0)
        return layer
    }
}
