//
//  PhotoImageHelper.swift
//  PhotoEditor
//
//  Created by Константин Алехин on 20.05.2022.
//

import Foundation
import UIKit
import Photos

class PhotoImageHelper: NSObject, PhotoHolderProtocol {
    var assets: PHFetchResult<AnyObject>?
    static let shared = PhotoImageHelper()

    var currentAssert: PHAsset?

    func saveImage(image: UIImage, successResult: @escaping() -> Void, failure: @escaping() -> Void) {
        _ = CGSize(width: currentAssert?.pixelWidth ?? 0, height: currentAssert?.pixelHeight ?? 0)
        PHPhotoLibrary.shared().performChanges {
            PHAssetChangeRequest.creationRequestForAsset(from: image)
        } completionHandler: { [weak self] success, _ in
            guard let self = self else {return}
            if success {
                self.currentAssert = nil
                successResult()
            } else {
                failure()
            }
        }
    }

    func loadAsserts(success: @escaping(PHFetchResult<AnyObject>) -> Void, failure: @escaping() -> Void) {
        if PHPhotoLibrary.authorizationStatus() == .authorized {

        } else {
            PHPhotoLibrary.requestAuthorization { status in
                if status == .authorized {
                    self.loadAsserts(success: success)
                } else {
                    failure()
                }
            }
        }
    }

    func loadAsserts(success: @escaping(PHFetchResult<AnyObject>) -> Void) {
        let fetchOptions = PHFetchOptions()
        fetchOptions.sortDescriptors = [NSSortDescriptor(key: "creationDate", ascending: false)]
        fetchOptions.fetchLimit = 20000
        assets = PHAsset.fetchAssets(with: PHAssetMediaType.image, options: fetchOptions) as? PHFetchResult<AnyObject>
        if let assets = assets {
            success(assets)
        }
    }

    func loadImageForCurrentAsset(success: @escaping(UIImage) -> Void) {
        let width = UIScreen.main.bounds.width
        let option = PHImageRequestOptions()
        option.deliveryMode = .highQualityFormat
        option.resizeMode = .fast
        if let item = currentAssert {
            let size = CGSize(width: width, height: width * 0.75)
            PHImageManager.default()
                .requestImage(
                    for: item,
                    targetSize: size,
                    contentMode: .aspectFill,
                    options: option
                ) { image, _ in
                    if let image = image {
                        success(image)
                    }
                }
        }
    }

    func loadImageForAsset(index: Int, size: CGSize, success: @escaping(UIImage) -> Void) {
        let option = PHImageRequestOptions()
        option.deliveryMode = .highQualityFormat
        option.resizeMode = .fast
        if let item = assets?[index] as? PHAsset {
            PHImageManager.default()
                .requestImage(
                    for: item,
                    targetSize: size,
                    contentMode: .aspectFill,
                    options: option
                ) { image, _ in
                    if let image = image {
                        success(image)
                    }
                }
        }
    }
}

protocol PhotoHolderProtocol: AnyObject {
    var assets: PHFetchResult<AnyObject>? {get set}

    func loadImageForAsset(index: Int, size: CGSize, success: @escaping(UIImage) -> Void)
}
