//
//  RVSlackTypingIndicatorView.swift
//  SwiftMeteor
//
//  Created by Neil Weintraut on 1/6/17.
//  Copyright © 2017 Neil Weintraut. All rights reserved.
//

import UIKit
import SlackTextViewController

class RVSlackTypingIndicatorView: UIView {
    private var _thumbnailView: UIImageView? = nil
    var thumbnailView: UIImageView {
        get {
            if let view = _thumbnailView { return view }
            let view = UIImageView()
            view.translatesAutoresizingMaskIntoConstraints = false
            view.isUserInteractionEnabled = false
            view.backgroundColor = UIColor.gray
            view.contentMode = UIViewContentMode.topLeft
            view.layer.cornerRadius = typingIndicatorViewHeight.avator.rawValue / 2.0
            view.layer.masksToBounds = true
            _thumbnailView = view
            return view
        }
    }
    private var _titleLabel: UILabel? = nil
    var titleLabel: UILabel {
        get {
            if let label = self._titleLabel { return label }
            let view = UILabel()
            view.translatesAutoresizingMaskIntoConstraints = false
            view.isUserInteractionEnabled = false
            view.backgroundColor = UIColor.clear
            view.numberOfLines = 1
            view.contentMode = UIViewContentMode.topLeft
            view.font = UIFont(descriptor: UIFontDescriptor(), size: 12.0)
            view.textColor = UIColor.lightGray
            _titleLabel = view
            return view
        }
    }
    private var _backgroundGradient: CAGradientLayer? = nil
    var _visible: Bool = false
    var backgroundGradient: CAGradientLayer {
        if _backgroundGradient == nil {
            let gradient = CAGradientLayer(layer: self.layer)
            _backgroundGradient = gradient
            gradient.frame = CGRect(x: 0.0, y: 0.0, width: SLKKeyWindowBounds().width, height: self.height)

            gradient.colors = [UIColor(white: 1.0, alpha: 0.0).cgColor, UIColor(white: 1.0, alpha: 0.9).cgColor, UIColor(white: 1.0, alpha: 1.0).cgColor]
            gradient.locations = [0.0, 0.5, 1.0]
            return gradient
        } else {
            return _backgroundGradient!
        }
    }

    enum typingIndicatorViewHeight: CGFloat {
        case minimum = 80.0
        case avator = 30.0
    }

    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        self.configureSubviews()
    }
    /*
    func intrinsicContentSize() -> CGSize {
        return CGSize(width: UIViewNoIntrinsicMetric, height: self.height)
    }
 */
    var height: CGFloat {
        get {
            var h: CGFloat = 13.0
            h = h + self.titleLabel.font.lineHeight
            return h
        }
    }
    override func layoutSubviews() {
        super.layoutSubviews()
        self.backgroundGradient.frame = self.bounds
    }
    func configureSubviews() {
        let thumb = "thumbnailView"
        let title = "title"
        var views = [String: UIView]()
            self.addSubview(thumbnailView)
            views[thumb] = thumbnailView

            self.addSubview(titleLabel)
            views[title] = titleLabel


            self.layer.insertSublayer(backgroundGradient , at: 0)
   //     let metrics = ["invertedThumbSize" : typingIndicatorViewHeight.avator.rawValue / 2.0]
//        var constraint = NSLayoutConstraint(item: thumb, attribute: NSLayoutAttribute.height, relatedBy: NSLayoutRelation.greaterThanOrEqual, toItem: title, attribute: <#T##NSLayoutAttribute#>, multiplier: <#T##CGFloat#>, constant: <#T##CGFloat#>)
    }
    func presentIndicator(name: String, image: UIImage?) -> Void {
        if self.isVisible || name.characters.count == 0 || (image != nil) {
            return
        } else {
            let text = "\(name) is typing..."
            let aString = NSAttributedString(string: text)
            var range = NSString(string: text).range(of: name)
            aString.attribute(UIFont.boldSystemFont(ofSize: 12.0).fontName, at: 0, effectiveRange: &range)
            self.titleLabel.attributedText = aString
            self.thumbnailView.image = image
            self.isVisible = true
        }
       
    }
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesBegan(touches , with: event)
        self.dismissIndicator()
    }
    deinit {
        _thumbnailView = nil
        _titleLabel = nil
        _backgroundGradient = nil
    }

}
extension RVSlackTypingIndicatorView: SLKTypingIndicatorProtocol {
    
    /**
     Returns YES if the indicator is visible.
     SLKTextViewController depends on this property internally, by observing its value changes to update the typing indicator view's constraints automatically.
     You can simply @synthesize this property to make it KVO compliant, or override its setter method and wrap its implementation with -willChangeValueForKey: and -didChangeValueForKey: methods, for more complex KVO compliance.
     */
    public var isVisible: Bool {
        get {
            return _visible
        }
        @objc(setVisible:) set{
            _visible = newValue
        }
    }

    func dismissIndicator() {
        if (self.isVisible) {
            self.isVisible = false
        }
    }

}
