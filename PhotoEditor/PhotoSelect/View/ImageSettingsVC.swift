//
//  ImageSetingsVC.swift
//  PhotoEditor
//
//  Created by Константин Алехин on 24.05.2022.
//

import UIKit

class ImageSettingsVC: UIViewController {

    private lazy var adapter: FilterImageAdapter = {
        return FilterImageAdapter()
    }()

    private var currentIndex: Int = -1

    @IBOutlet weak var intencitySlide: UISlider!
    @IBOutlet weak var filteredImageList: UICollectionView!
    @IBOutlet weak var defaltImageView: UIImageView!
    override func viewDidLoad() {
        super.viewDidLoad()

        PhotoImageHelper.shared.loadImageForCurrentAsset { [weak self] image in
            guard let self = self else {return}
            self.defaltImageView.image = image
            FilterManager.shared.defaltImage = image

            self.loadImages()
        }
        filteredImageList.register(UINib(nibName: ImageCell.cellId, bundle: nil),
                                   forCellWithReuseIdentifier: ImageCell.cellId)
        self.filteredImageList.dataSource = adapter
        self.filteredImageList.delegate = adapter
        self.adapter.listOwner = self

    }

    @MainActor
    func loadImages() {
        Task {
            let images = await FilterManager.shared.prepareImages()
            self.adapter.setupItems(items: images.sorted {$0.order > $1.order})
            self.filteredImageList.reloadData()
        }
    }

    @IBAction func onCancel(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }
    @IBAction func onSliderChanger(_ sender: Any) {
        let intencity = ((sender as? UISlider)?.value ?? 15.0)
    }
    @IBAction func onConfirm(_ sender: Any) {
    }

}

extension ImageSettingsVC: ListOwner {
    func selectImages(index: Int) {
        loadItem(index: index)
    }
    @MainActor
    func loadItem(index: Int) {
        let image = self.adapter.images[index].image
        self.defaltImageView.image = image

        Task {
            if let image = await FilterManager.shared.setSelectedFilter(index: index, image: image) {
                self.adapter.changeItem(index: index, item: ImageItem(image: image, order: index))
                self.filteredImageList.reloadData()
            }
        }
    }
}
