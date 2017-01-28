//
//  PHPhotoLibrary+Extension.swift
//  SwiftMeteor
//
//  Created by Neil Weintraut on 1/27/17.
//  Copyright © 2017 Neil Weintraut. All rights reserved.
//

import Photos
extension PHPhotoLibrary {
    
    typealias PhotoAsset = PHAsset
    typealias PhotoAlbum = PHAssetCollection
    
    static func saveImage(image: UIImage, albumName: String, completion: @escaping (PHAsset?)->()) {
        if let album = self.findAlbum(albumName: albumName) {
            PHPhotoLibrary.saveImage(image, album, completion: { (asset) in
                completion(asset)
            })
            return
        }
        createAlbum(albumName: albumName) { album in
            if let album = album {
                self.saveImage(image, album, completion: { (asset) in
                    completion(asset)
                })
            }
            else {
                assert(false, "Album is nil")
            }
        }
    }
    
    static private func saveImage(_ image: UIImage, _ album: PhotoAlbum, completion: @escaping (PHAsset?)->()) {
        var placeholder: PHObjectPlaceholder?
        PHPhotoLibrary.shared().performChanges({
            // Request creating an asset from the image
            let createAssetRequest = PHAssetChangeRequest.creationRequestForAsset(from: image)
            // Request editing the album
            guard let albumChangeRequest = PHAssetCollectionChangeRequest(for: album) else {
                assert(false, "Album change request failed")
                return
            }
            // Get a placeholder for the new asset and add it to the album editing request
            
            guard let photoPlaceholder = createAssetRequest.placeholderForCreatedAsset else {
                assert(false, "Placeholder is nil")
                return
            }
            placeholder = photoPlaceholder
            let array: NSArray = [photoPlaceholder]
            albumChangeRequest.addAssets(array)
        }, completionHandler: { success, error in
            guard let placeholder = placeholder else {
                assert(false, "Placeholder is nil")
                completion(nil)
                return
            }
            
            if success {
                let phAssets = PHAsset.fetchAssets(withLocalIdentifiers: [placeholder.localIdentifier], options: nil)
                if phAssets.count > 0 {
                    completion(phAssets[0])
                    
                } else {
                    completion(nil)
                }


            }
            else {

                if let error = error {
                    print(error)
                }
                completion(nil)
            }
        })
    }
    
    static func findAlbum(albumName: String) -> PhotoAlbum? {
        let fetchOptions = PHFetchOptions()
        fetchOptions.predicate = NSPredicate(format: "title = %@", albumName)
        let fetchResult = PHAssetCollection.fetchAssetCollections(with: .album, subtype: .albumRegular, options: fetchOptions)
        guard let photoAlbum = fetchResult.firstObject else {
            return nil
        }
        return photoAlbum
    }
    
    static func createAlbum(albumName: String, completion: @escaping (PhotoAlbum?)->()) {
        var albumPlaceholder: PHObjectPlaceholder?
        PHPhotoLibrary.shared().performChanges({
            // Request creating an album with parameter name
            let createAlbumRequest = PHAssetCollectionChangeRequest.creationRequestForAssetCollection(withTitle: albumName)
            // Get a placeholder for the new album
            albumPlaceholder = createAlbumRequest.placeholderForCreatedAssetCollection
        }, completionHandler: { success, error in
            guard let placeholder = albumPlaceholder else {
                assert(false, "Album placeholder is nil")
                completion(nil)
                return
            }
            
            let fetchResult = PHAssetCollection.fetchAssetCollections(withLocalIdentifiers: [placeholder.localIdentifier], options: nil)
            guard let album = fetchResult.firstObject else {
                assert(false, "FetchResult has no PHAssetCollection")
                completion(nil)
                return
            }
            
            if success {
                completion(album)
            }
            else {
                if let error = error {
                    print(error)
                }

                completion(nil)
            }
        })
    }
    
    static func loadThumbnailFromLocalIdentifier(localIdentifier: String, completion: @escaping (UIImage?)->()) {
        let assets = PHAsset.fetchAssets(withLocalIdentifiers: [localIdentifier], options: nil)
        if assets.count > 0 {
            loadThumbnailFromAsset(asset: assets[0], completion: completion)
            return
        } else {
            completion(nil)
            return
        }

    }
    
    static func loadThumbnailFromAsset(asset: PhotoAsset, completion: @escaping (UIImage?)->()) {
        PHImageManager.default().requestImage(for: asset, targetSize: CGSize(width: 100.0, height: 100.0), contentMode: .aspectFit, options: PHImageRequestOptions(), resultHandler: { result, info in
            completion(result)
        })
    }
    
}
