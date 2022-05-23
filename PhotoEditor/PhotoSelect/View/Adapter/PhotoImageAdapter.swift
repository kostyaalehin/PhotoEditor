//
//  PhotoImageAdapter.swift
//  PhotoEditor
//
//  Created by Константин Алехин on 20.05.2022.
//

import Foundation
import UIKit

class PhotoImageAdapter: NSObject,
                         UICollectionViewDelegate,
                         UICollectionViewDataSource,
                         UICollectionViewDelegateFlowLayout {
    private var images: [UIImage] = [UIImage]()

    var side: CGFloat = 120.0

    weak var photoHolder: PhotoHolderProtocol?

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return photoHolder?.assets?.count ?? 0
    }

    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }

    func collectionView(_ collectionView: UICollectionView,
                        cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView
            .dequeueReusableCell(
                withReuseIdentifier: ImageCell.cellId,
                for: indexPath) as? ImageCell else {
            return UICollectionViewCell()
        }
        photoHolder?.loadImageForAsset(index: indexPath.row,
                                       size: CGSize(width: side, height: side),
                                       success: { image in
            cell.setupOutputImage(image: image)
        })

        return cell
    }

    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: side, height: side)
    }

    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 10.0
    }

    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 10.0
    }

}
