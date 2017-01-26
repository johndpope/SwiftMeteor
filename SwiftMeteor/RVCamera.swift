//
//  RVCamera.swift
//  SwiftMeteor
//
//  Created by Neil Weintraut on 1/25/17.
//  Copyright © 2017 Neil Weintraut. All rights reserved.
//

import UIKit
//import AVFoundation
import Photos

class RVCamera: NSObject {
    enum SourceType {
        case camera
        case photoLibrary
        case savePhotoAlbums
        
        var description: UIImagePickerControllerSourceType {
            switch (self) {
            case .camera:
                return UIImagePickerControllerSourceType.camera
            case .photoLibrary:
                return UIImagePickerControllerSourceType.photoLibrary
            case .savePhotoAlbums:
                return UIImagePickerControllerSourceType.savedPhotosAlbum
                
            }
        }
    }
    weak var delegate: RVCameraDelegate?
    let picker = UIImagePickerController()
    weak var anchorBarButtonItem: UIBarButtonItem? = nil
    var capturedImages = [UIImage]()
    override init() {
        super.init()
        picker.delegate = self
        
    }
    private func requestAuthorizationHandler(status: PHAuthorizationStatus) {
        DispatchQueue.main.async {
            switch (status) {
            case .authorized:
                self.show2(sourceType: .photoLibrary)
            default:
                self.noCamera(title: "Photo Library Not Yet Authorized", message: "Enable Photo Library permissions in settings")
            }
        }

    }
    func showPhotoLibrary() {
        if UIImagePickerController.isSourceTypeAvailable(UIImagePickerControllerSourceType.photoLibrary) {
            if PHPhotoLibrary.authorizationStatus() != .authorized {
                PHPhotoLibrary.requestAuthorization(requestAuthorizationHandler)
            } else {
              //  print("In \(self.classForCoder).showPhotoLibrary")
                show(sourceType: .photoLibrary)
            }
        } else {
            print("In \(self.classForCoder).showPhotoLibrary, PhotoLibraray not available")
        }
    }
    func shootPhoto() {
        //https://developer.apple.com/library/content/samplecode/PhotoPicker/Listings/PhotoPicker_APLViewController_m.html
        if UIImagePickerController.isSourceTypeAvailable(UIImagePickerControllerSourceType.camera) {
            let authStatus = AVCaptureDevice.authorizationStatus(forMediaType: AVMediaTypeVideo)
            if authStatus == AVAuthorizationStatus.denied {
                noCamera(title: "Unable to access the Camera", message: "To enable access go to Settings > Privacy > Camera > and turn on camera access for this app")
            } else if authStatus == AVAuthorizationStatus.notDetermined {
                AVCaptureDevice.requestAccess(forMediaType: AVMediaTypeVideo, completionHandler: { (granted: Bool ) in
                    if granted {
                        self.show(sourceType: .camera)
                    } else {
                        
                    }
                })
            } else {
                show(sourceType: .camera)
            }
        } else {
            noCamera(title: "No Camera", message: "Sorry, Camera is not available")
        }
    }
    private func noCamera(title: String, message: String) {
        if let delegate = self.delegate as? UIViewController {
            let alertVC = UIAlertController(title: title, message: message, preferredStyle: .alert)
            let okAction = UIAlertAction(title: "OK", style: .default) { (action: UIAlertAction) in
                
            }
            alertVC.addAction(okAction)
            
            delegate.present(alertVC, animated: true) {
                
            }
        }

    }
    private func show2(sourceType: RVCamera.SourceType) {
        if UIImagePickerController.isSourceTypeAvailable(UIImagePickerControllerSourceType.photoLibrary) {
            
            picker.allowsEditing = false
            picker.sourceType = .photoLibrary
            if let mediaTypes = UIImagePickerController.availableMediaTypes(for: .photoLibrary) {
                picker.mediaTypes = mediaTypes
            }
            picker.modalPresentationStyle = UIModalPresentationStyle.popover
            if let delegate = self.delegate as? UIViewController {
                delegate.present(picker, animated: true) {}
            }
        } else {
            print("In \(self.classForCoder).imageButtonTouched, PhotoLibraray not available")
        }
    }
    private func show(sourceType: RVCamera.SourceType) {
        picker.allowsEditing = false
        picker.sourceType = sourceType.description
        if sourceType == .camera {
            picker.cameraCaptureMode = UIImagePickerControllerCameraCaptureMode.photo
            picker.showsCameraControls = true
            //picker.modalPresentationStyle = UIModalPresentationStyle.currentContext
        } else {
         //   print("Not a camera")
        }


        picker.modalPresentationStyle = (sourceType == .camera) ? .fullScreen : .popover
      //  picker.showsCameraControls = true
        if let mediaTypes = UIImagePickerController.availableMediaTypes(for: .photoLibrary) {
            if sourceType == .photoLibrary { picker.mediaTypes = mediaTypes }
        }
        if let delegate = self.delegate as? UIViewController {
            //   if let imageView = self.profileImageView {if imageView.isAnimating {imageView.stopAnimating() } }
            if self.capturedImages.count > 0 { self.capturedImages.removeAll() }

          //  if sourceType == .camera { picker.showsCameraControls = false }  // The user wants to use the camera interface. Set up our custom overlay view for the camera.
            // get overlayview
            delegate.present(picker, animated: true) { }
            if let popoverController = picker.popoverPresentationController {
                if let anchor = anchorBarButtonItem {
                    popoverController.barButtonItem = anchor    // display popover form the UIBarButtonItem as the anchor
                }
                popoverController.permittedArrowDirections = UIPopoverArrowDirection.any
            }
        }
    }
}

extension RVCamera: UIImagePickerControllerDelegate {
    @objc func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        if let delegate = delegate { delegate.didFinishPicking(picker: picker, info: info) }

    }
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        if let delegate = self.delegate { delegate.pickerCancelled(picker: picker) }
    }

}
extension RVCamera: UINavigationControllerDelegate {}
protocol RVCameraDelegate: class {
    func didFinishPicking(picker: UIImagePickerController, info: [String: Any]) -> Void
    func pickerCancelled(picker: UIImagePickerController) -> Void
}
