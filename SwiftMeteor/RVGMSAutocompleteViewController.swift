//
//  RVGMSAutocompleteViewController.swift
//  SwiftMeteor
//
//  Created by Neil Weintraut on 1/26/17.
//  Copyright © 2017 Neil Weintraut. All rights reserved.
//

import Foundation
import GooglePlaces
class RVGMSAutocompletePrediction: GMSAutocompletePrediction {
    var prediction: GMSAutocompletePrediction
    init(prediction: GMSAutocompletePrediction){
        self.prediction = prediction
        super.init()
    }
    /**
     * The full description of the prediction as a NSAttributedString. E.g., "Sydney Opera House,
     * Sydney, New South Wales, Australia".
     *
     * Every text range that matches the user input has a |kGMSAutocompleteMatchAttribute|.  For
     * example, you can make every match bold using enumerateAttribute:
     * <pre>
     *   UIFont *regularFont = [UIFont systemFontOfSize:[UIFont labelFontSize]];
     *   UIFont *boldFont = [UIFont boldSystemFontOfSize:[UIFont labelFontSize]];
     *
     *   NSMutableAttributedString *bolded = [prediction.attributedFullText mutableCopy];
     *   [bolded enumerateAttribute:kGMSAutocompleteMatchAttribute
     *                      inRange:NSMakeRange(0, bolded.length)
     *                      options:0
     *                   usingBlock:^(id value, NSRange range, BOOL *stop) {
     *                     UIFont *font = (value == nil) ? regularFont : boldFont;
     *                     [bolded addAttribute:NSFontAttributeName value:font range:range];
     *                   }];
     *
     *   label.attributedText = bolded;
     * </pre>
     */
    override var attributedFullText: NSAttributedString {
        get {
            return prediction.attributedFullText
        }
    }
    
    
    /**
     * The main text of a prediction as a NSAttributedString, usually the name of the place.
     * E.g. "Sydney Opera House".
     *
     * Text ranges that match user input are have a |kGMSAutocompleteMatchAttribute|,
     * like |attributedFullText|.
     */
    override var attributedPrimaryText: NSAttributedString { get { return prediction.attributedPrimaryText } }
    
    
    /**
     * The secondary text of a prediction as a NSAttributedString, usually the location of the place.
     * E.g. "Sydney, New South Wales, Australia".
     *
     * Text ranges that match user input are have a |kGMSAutocompleteMatchAttribute|, like
     * |attributedFullText|.
     *
     * May be nil.
     */
    override var attributedSecondaryText: NSAttributedString? { get {return prediction.attributedSecondaryText} }
    
    
    /**
     * An optional property representing the place ID of the prediction, suitable for use in a place
     * details request.
     */
    override var placeID: String? { get {return prediction.placeID}}
    
    
    /**
     * The types of this autocomplete result.  Types are NSStrings, valid values are any types
     * documented at <https://developers.google.com/places/ios-api/supported_types>.
     */
    override var types: [String] { get{return prediction.types} }
    
    
    
}
class RVGMSAutocompleteViewController: GMSAutocompleteViewController {
    private var _rvDelegate: RVGMSAutocompleteViewControllerDelegate? = nil
    var rvDelegate: RVGMSAutocompleteViewControllerDelegate? {
        get {
            return _rvDelegate
        }
        set {
            self._rvDelegate = newValue
            if let delegate = newValue {
                self.delegate = RVGMSDelegate(delegate: delegate, controller: self)
            }
        }
    }
    override func viewDidLoad() {
        let filter = GMSAutocompleteFilter()
        filter.country = "USA"
        self.autocompleteFilter = filter
    }
    
}
class RVGMSDelegate: NSObject {
    var delegate: RVGMSAutocompleteViewControllerDelegate
    weak var controller: RVGMSAutocompleteViewController? = nil
    init(delegate: RVGMSAutocompleteViewControllerDelegate, controller: RVGMSAutocompleteViewController) {
        self.delegate = delegate
        self.controller = controller
    }

}
extension RVGMSDelegate: GMSAutocompleteViewControllerDelegate {
    // Handle the user's selection
    func viewController(_ viewController: GMSAutocompleteViewController, didAutocompleteWith place: GMSPlace) {
        if let controller = self.controller {
            delegate.didAutocomplete(controller: controller, place: RVLocation(googlePlace: place))
        }
    }
    func viewController(_ viewController: GMSAutocompleteViewController, didFailAutocompleteWithError error: Error) {
        let rvError = RVError(message: "RVGMSAutocompleteViewController got didFail error", sourceError: error , lineNumber: #line, fileName: "")

            if let controller = self.controller {
                delegate.didFailAutocomplete(controller: controller, error: rvError)
            }
    
    }
    func viewController(_ viewController: GMSAutocompleteViewController, didSelect prediction: GMSAutocompletePrediction) -> Bool {
        if let controller = self.controller {
            return delegate.didSelect(controller: controller , prediction: RVGMSAutocompletePrediction(prediction: prediction))
        } else {
            return true
        }
    }
    func wasCancelled(_ viewController: GMSAutocompleteViewController) {
        if let controller = self.controller {
            delegate.wasCancelled(controller: controller)
        }
    }
    func didRequestAutocompletePredictions(_ viewController: GMSAutocompleteViewController) {
        if let controller = self.controller { delegate.didRequestAutocompletePredictions(controller: controller)}
    }
    func didUpdateAutocompletePredictions(_ viewController: GMSAutocompleteViewController) {
        if let controller = self.controller { delegate.didUpdateAutocompletePredictions(controller: controller)}
    }
}

protocol RVGMSAutocompleteViewControllerDelegate: class {
    func didAutocomplete(controller: RVGMSAutocompleteViewController, place: RVLocation) -> Void
    func didFailAutocomplete(controller: RVGMSAutocompleteViewController, error: RVError) -> Void
    func didSelect(controller: RVGMSAutocompleteViewController, prediction: RVGMSAutocompletePrediction) -> Bool
    func wasCancelled(controller: RVGMSAutocompleteViewController) -> Void
    func didRequestAutocompletePredictions(controller: RVGMSAutocompleteViewController) -> Void
    func didUpdateAutocompletePredictions(controller: RVGMSAutocompleteViewController) -> Void
}

// https://developers.google.com/places/ios-api/autocomplete#add_an_autocomplete_ui_control
extension RVGMSAutocompleteViewController: GMSAutocompleteViewControllerDelegate {
    // Handle the user's selection
    func viewController(_ viewController: GMSAutocompleteViewController, didAutocompleteWith place: GMSPlace) {
        if let rvDelegate = rvDelegate {
            rvDelegate.didAutocomplete(controller: self, place: RVLocation(googlePlace: place))
        }
    }
    func viewController(_ viewController: GMSAutocompleteViewController, didFailAutocompleteWithError error: Error) {
        let rvError = RVError(message: "RVGMSAutocompleteViewController got didFail error", sourceError: error , lineNumber: #line, fileName: "")
        if let delegate = rvDelegate {
            delegate.didFailAutocomplete(controller: self, error: rvError)
        }
    }
    func viewController(_ viewController: GMSAutocompleteViewController, didSelect prediction: GMSAutocompletePrediction) -> Bool {
        if let rvDelegate = self.rvDelegate {
            return rvDelegate.didSelect(controller: self , prediction: RVGMSAutocompletePrediction(prediction: prediction))
        } else {
            return true
        }
    }
    func wasCancelled(_ viewController: GMSAutocompleteViewController) {
        if let rvDelegate = self.rvDelegate {
            rvDelegate.wasCancelled(controller: self)
        }
    }
    func didRequestAutocompletePredictions(_ viewController: GMSAutocompleteViewController) {
        if let rvDelegate = self.rvDelegate{ rvDelegate.didRequestAutocompletePredictions(controller: self)}
    }
    func didUpdateAutocompletePredictions(_ viewController: GMSAutocompleteViewController) {
        if let rvDelegate = self.rvDelegate { rvDelegate.didUpdateAutocompletePredictions(controller: self)}
    }
}
