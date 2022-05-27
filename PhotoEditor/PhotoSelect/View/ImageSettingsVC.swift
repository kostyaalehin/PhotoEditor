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
        let intencity = ((sender as? UISlider)?.value ?? 15.0) * 100.0
        self.loadItem(index: Int(intencity))
    }

    @IBAction func onConfirm(_ sender: Any) {
            if let image = self.defaltImageView.image {
                PhotoImageHelper.shared.saveImage(image: image) {
                    DispatchQueue.main.async {
                        self.navigationController?.popViewController(animated: true)
                    }
                } failure: {

                }
            }
    }
}

extension ImageSettingsVC: ListOwner {
    func selectImages(index: Int) {
        self.currentIndex = index
        let intencity = self.intencitySlide.value * 100
        loadItem(index: self.currentIndex, intencity: Int(intencity))
    }
    @MainActor
    func loadItem(index: Int, intencity: Int = 0) {
        let image = self.adapter.images[index].image
        self.defaltImageView.image = image

        Task {
            if let image = await FilterManager.shared.setSelectedFilter(index: index,
                                                                        image: image,
                                                                        intencity: intencity) {
                self.defaltImageView.image = image
//                self.adapter.changeItem(index: index, item: ImageItem(image: image, order: index))
//                self.filteredImageList.reloadData()
            }
        }
    }
}
