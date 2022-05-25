//
//  ImagePickerVC.swift
//  PhotoEditor
//
//  Created by Константин Алехин on 19.05.2022.
//

import UIKit

class ImagePickerVC: UIViewController {

    @IBOutlet weak var imageList: UICollectionView!
    private lazy var adapter: PhotoImageAdapter = {
        PhotoImageAdapter()
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        let side = (UIScreen.main.bounds.size.width - 40) / 3
        self.adapter.side = side
        self.adapter.listOwner = self
        imageList.register(UINib(nibName: ImageCell.cellId, bundle: nil), forCellWithReuseIdentifier: ImageCell.cellId)
        self.imageList.dataSource = adapter
        self.imageList.delegate = adapter
        self.adapter.photoHolder = PhotoImageHelper.shared
        PhotoImageHelper.shared.loadAsserts { [weak self] _ in
            guard let self = self else {return}
            DispatchQueue.main.async {
                self.imageList.reloadData()
            }
        } failure: {

        }
    }
}

extension ImagePickerVC: ListOwner {
    func selectImages(index: Int) {
        PhotoImageHelper.shared.selectAsset(index: index)
        self.navigationController?.pushViewController(ImageSettingsVC(), animated: true)
    }
}
