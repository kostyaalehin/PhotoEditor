//
//  FilterManager.swift
//  PhotoEditor
//
//  Created by Константин Алехин on 25.05.2022.
//

import Foundation
import CoreImage
import UIKit

class FilterManager: NSObject {
    static let shared = FilterManager()

    var defaltImage: UIImage?
    var selectedImage: UIImage?
    var currentFilter: CIFilter?
    var selectFilter: CIFilter?

    let context = CIContext()

    lazy var filterList = ["CISepiaTone",
                           "CIPhotoEffectChrome",
                           "CIPixellate",
                           "CITwirlDistortion",
                           "CIUnsharpMask",
                           "CIVignette",
                           "CIColorMonochrome",
                           "CIGaussianBlur",
                           "CIBumpDistortion",
                           "CIPhotoEffectFade",
                           "CIPhotoEffectInstant",
                           "CIPhotoEffectMono",
                           "CIPhotoEffectNoir",
                           "CIPhotoEffectProcess",
                           "CIPhotoEffectTonal",
                           "CIPhotoEffectTransfer"]

    func prepareImages() async -> [ImageItem] {
        var images = [ImageItem]()
        await withTaskGroup(of: ImageItem?.self, body: { group in
            for index in 0..<filterList.count {
                group.addTask {
                    if let image = await self.setFilterToDefault(index: index) {
                    return ImageItem(image: image, order: index)
                    } else {
                        return nil
                    }
                }
            }
            for await image in group {
                if let image = image {
                    images.append(image)
                }
            }
        })
        return images
    }

    func setSelectedFilter(index: Int, image: UIImage, intencity: Int = 0) async -> UIImage? {
        self.selectedImage = image
        guard let defaltImage = defaltImage else {
            return nil
        }

        self.selectFilter = CIFilter(name: filterList[index])
        guard let filter = self.selectFilter else {return nil}
        let ciImage = CIImage(image: defaltImage)
        filter.setValue(ciImage, forKey: kCIInputImageKey)

        return try? await applyProcessing(filter: filter, image: image, intencity)
    }

    func setFilterToDefault(index: Int) async -> UIImage? {
        guard let defaltImage = defaltImage else {
            return nil
        }

        currentFilter = CIFilter(name: filterList[index])
        guard let currentFilter = currentFilter else {
            return nil
        }

        let ciImage = CIImage(image: defaltImage)
        currentFilter.setValue(ciImage, forKey: kCIInputImageKey)

        return try? await applyProcessing(filter: currentFilter, image: defaltImage)
    }

    func applyProcessing(filter: CIFilter, image: UIImage, _ baseIntencity: Int = 0) async throws -> UIImage? {

        return await withCheckedContinuation { continuation in
            let inputKeys = filter.inputKeys

        if inputKeys.contains(kCIInputIntensityKey) {
            let intensity = baseIntencity
            filter.setValue(intensity, forKey: kCIInputIntensityKey) }
        if inputKeys.contains(kCIInputRadiusKey) {
            let intensity = baseIntencity * 200
            filter.setValue(intensity, forKey: kCIInputRadiusKey) }
        if inputKeys.contains(kCIInputScaleKey) {
            let intensity = baseIntencity * 10
            filter.setValue(intensity, forKey: kCIInputScaleKey) }
        if inputKeys.contains(kCIInputCenterKey) {
            filter.setValue(CIVector(x: image.size.width / 2, y: image.size.height / 2),
                            forKey: kCIInputCenterKey) }

            if let outputImage = filter.outputImage,
               let cgimg = context.createCGImage(outputImage, from: filter.outputImage!.extent) {
            let processedImage = UIImage(cgImage: cgimg)
                continuation.resume(returning: processedImage)
            } else {
                continuation.resume(returning: nil)
            }
        }
    }
}
