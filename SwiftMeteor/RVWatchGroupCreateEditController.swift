//
//  RVWatchGroupCreateEditController.swift
//  SwiftMeteor
//
//  Created by Neil Weintraut on 1/27/17.
//  Copyright © 2017 Neil Weintraut. All rights reserved.
//

import UIKit
import Toast_Swift


class RVWatchGroupCreateEditController: RVBaseTableViewController {
    
    let camera = RVCamera()
    var newImage: UIImage? = nil
    
    @IBOutlet weak var watchGroupTitleTextField: UITextField!
    @IBOutlet weak var watchGroupDescriptionTextField: UITextField!
    @IBOutlet weak var watchGroupManagerLabel: UILabel!
    @IBOutlet weak var saveBarButtonItem: UIBarButtonItem!
    @IBOutlet weak var undoBarButtonItem: UIBarButtonItem!
    @IBOutlet weak var watchGroupImage: UIImageView!
    
    @IBAction func saveButtonTouched(_ sender: UIBarButtonItem) {
        if let _ = self.carrier.incoming as? RVWatchGroup {
            
        } else {
            createNewWatchGroup()
        }
    }
    @IBAction func cancelButtonTouched(_ sender: UIBarButtonItem) {
    }
    
    @IBAction func doneButtonTouched(_ sender: UIBarButtonItem) {
        dismiss(animated: true) { }
    }
    
    @IBAction func changePictureButtonTouched(_ sender: UIButton) {
        showCameraMenu()
    }
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        configure()
    }
    override func configure() {
        if let incoming = carrier.incoming {
            setTextFieldText(textField: watchGroupTitleTextField, text: incoming.title)
            setTextFieldText(textField: watchGroupDescriptionTextField, text: incoming.regularDescription)
            setLabelText(label: watchGroupManagerLabel, text: incoming.handle)
            showImage(rvImage: incoming.image, imageView: watchGroupImage)
        } else {
            setTextFieldText(textField: watchGroupTitleTextField)
            setTextFieldText(textField: watchGroupDescriptionTextField)
            setLabelText(label: watchGroupManagerLabel)
            showImage(rvImage: nil, imageView: watchGroupImage)
        }
    }
    
    func showCameraMenu() {
        
        let alertVC = UIAlertController(title: title, message: "Get Picture from...", preferredStyle: .alert)
        let cameraAction = UIAlertAction(title: "Camera", style: .default) { (action: UIAlertAction) in
            self.camera.delegate = self
            self.camera.shootPhoto()
        }
        let albumAction = UIAlertAction(title: "Album", style: .default) { (action) in
            self.camera.delegate = self
            self.camera.showPhotoLibrary()
        }
        alertVC.addAction(cameraAction)
        alertVC.addAction(albumAction)
        self.present(alertVC, animated: true) { }
    }
    func createNewWatchGroup() {
        if let title = getTextFieldText(textField: watchGroupTitleTextField) {
            let title = title.trimmingCharacters(in: .whitespacesAndNewlines)
            if title.characters.count > 0 {
                if let userProfile = self.userProfile {
                    if let domain = self.domain {
                        let uiImage = self.newImage != nil ? self.newImage! : RVCoreInfo.sharedInstance.watchGroupImagePlaceholder
                        let group = RVWatchGroup()
                        group.title = title
                        group.setOwner(owner: userProfile)
                        if let fullName = userProfile.fullName {
                            group.handle = fullName
                            group.fullName = fullName
                        }
                        group.domainId = domain.localId
                        if let desc = getTextFieldText(textField: watchGroupDescriptionTextField) {
                            let desc = desc.trimLeadingAndTrailingSpaces()
                            if desc.characters.count > 0 {
                                group.regularDescription = desc
                            }
                        }
                        RVImage.saveImage(image: uiImage, path: "watchGroup", filename: "title", filetype: RVFileType.jpeg, parent: group, params: [.title: title as AnyObject], callback: { (rvImage, error) in
                            if let error = error {
                                error.printError()
                                if let tableView = self.tableView { tableView.makeToast("Failed to upload image :-(", duration: 2.0, position: .center) }
                            } else if let rvImage = rvImage {
                                group.image = rvImage
                                group.create(callback: { (newGroup, error) in
                                    if let error = error {
                                        error.printError()
                                        if let tableView = self.tableView { tableView.makeToast("Failed to create record for Group :-(", duration: 2.0, position: .center) }
                                    } else if let newGroup = newGroup {
                                        self.carrier.incoming = newGroup
                                        if let tableView = self.tableView { tableView.makeToast("Successfully created new WatchGroup called \(title)", duration: 3.0, position: .center) }
                                    } else {
                                        if let tableView = self.tableView { tableView.makeToast("No Group returned from server :-(", duration: 2.0, position: .center) }
                                    }
                                })
                                return
                            } else {
                                if let tableView = self.tableView { tableView.makeToast("No Image Model returned from server :-(", duration: 2.0, position: .center) }
                            }
                        })
                        return
                    } else {
                        if let tableView = self.tableView { tableView.makeToast("No Domain to serve to :-(", duration: 2.0, position: .center) }
                    }
                } else {
                    if let tableView = self.tableView { tableView.makeToast("No userProfile. didn't save :-(", duration: 2.0, position: .center) }
                }
            } else {
                if let tableView = self.tableView { tableView.makeToast("Need to have a title, not just spaces!", duration: 2.0, position: .center) }
            }
        } else {
             if let tableView = self.tableView { tableView.makeToast("Need to have a title!", duration: 2.0, position: .center) }
        }
    }
}
extension RVWatchGroupCreateEditController: RVCameraDelegate {
    @objc func finishedWritingToAlbum(image: UIImage, error: NSError?, contextInfo: UnsafeRawPointer) {
        if let error = error {
            let rvError = RVError(message: "In \(instanceType).finishedWriting got erro", sourceError: error , lineNumber: #line, fileName: "")
            rvError.printError()
        } else {
            print(contextInfo)
            dismiss(animated: true, completion: { })
        }
    }
    func didFinishPicking(picker: UIImagePickerController, info: [String: Any]) -> Void {
        if let uiImage = info[UIImagePickerControllerOriginalImage] as? UIImage {
            camera.saveImageToDisk(uiImage: uiImage, filename: "text", callback: { (url , error) in
                if let error = error {
                    error.printError()
                } else if let url = url {
                    print(url.absoluteString)
                }
                self.dismiss(animated: true , completion: {})
            })
            //UIImageWriteToSavedPhotosAlbum(uiImage , self, #selector(RVWatchGroupCreateEditController.finishedWritingToAlbum(image:error:contextInfo:)), &contextInfo)
        } else {
            dismiss(animated: true, completion: { })
        }
        

    }
    func pickerCancelled(picker: UIImagePickerController) -> Void {
        dismiss(animated: true) {}
    }
    
}
