//
//  RVWatchGroupView.swift
//  SwiftMeteor
//
//  Created by Neil Weintraut on 1/28/17.
//  Copyright © 2017 Neil Weintraut. All rights reserved.
//

import UIKit

class RVWatchGroupView: UIView {

    @IBOutlet weak var watchGroupImageView: UIImageView!
    @IBOutlet weak var watchGroupTitleLabel: UILabel!
    @IBOutlet weak var watchGroupDescriptionLabel: UILabel!
    override init(frame: CGRect) {
        super.init(frame: frame)
      //  loadFromNib()
    }
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
     //   loadFromNib()
    }
    var state: RVBaseAppState? { didSet { configure() }}
    
    class func loadFromNib(frame: CGRect) -> RVWatchGroupView? {
        if let views = Bundle.main.loadNibNamed("RVWatchGroupView", owner: nil, options: nil) {
            if let view = views.first as? RVWatchGroupView {
                view.frame = frame
                view.autoresizingMask = [.flexibleWidth, .flexibleHeight]
                return view
            }
        }
        return nil
    }
 
    func configure() {
        if let state = self.state {
            if let group = state.stack.last as? RVWatchGroup {
                setLabelText(label: watchGroupTitleLabel, text: group.title)
                setLabelText(label: watchGroupDescriptionLabel, text: group.regularDescription)
                showImage(imageView: watchGroupImageView, rvImage: group.image, defaultImage: nil, comparisonId: { () -> String? in
                    if let state = self.state {
                        if let group = state.stack.last as? RVWatchGroup { return group.localId }
                    }
                    return nil
                })
            } else {
                print("In \(self.classForCoder).configure() top of stack is \(state.stack.last ?? "vNo state.stack.last")")
            }
        } else {
            print("In \(self.classForCoder).configure() no state")
        }
    }
 
}
extension RVWatchGroupView {
    func setLabelText(label: UILabel?, text: String?, defaultText: String? = nil) {
        if let label = label {
            if let text = text { label.text = text }
            else { label.text = defaultText }
        } else {
            print("In \(self.classForCoder).setLabelText, don't have label")
        }
    }
    func showImage(imageView: UIImageView?, uiImage: UIImage?, defaultImage: UIImage? = nil) {
        if let imageView = imageView {
            if let uiImage = uiImage {
                imageView.image = uiImage
            } else if let defaultImage = defaultImage {
                imageView.image = defaultImage
            } else {
                imageView.image = RVCoreInfo.sharedInstance.watchGroupImagePlaceholder
            }
        }
    }
    func showImage(imageView: UIImageView?, rvImage: RVImage?, defaultImage: UIImage? = nil, comparisonId: @escaping () -> String?) {
        if let rvImage = rvImage {
            if let initialId = comparisonId() {
                rvImage.download(callback: { (uiImage , error) in
                    if let error = error {
                        error.append(message: "In \(self.classForCoder).showImage, got error")
                        error.printError()
                    } else if let uiImage = uiImage {
                        if let currentId = comparisonId() {
                            if currentId == initialId { self.showImage(imageView: imageView, uiImage: uiImage, defaultImage: defaultImage) }
                        }
                    } else {
                        print("In \(self.classForCoder).showImage no error no image")
                    }
                })
            }
        }
    }
}
