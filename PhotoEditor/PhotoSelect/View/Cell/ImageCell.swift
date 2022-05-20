//
//  ImageCell.swift
//  PhotoEditor
//
//  Created by Константин Алехин on 20.05.2022.
//

import UIKit

class ImageCell: UICollectionViewCell {

    @IBOutlet weak var photoImageView: UIImageView!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    func setupOutputImage (image: UIImage) {
        self.photoImageView.image = image
    }

}
