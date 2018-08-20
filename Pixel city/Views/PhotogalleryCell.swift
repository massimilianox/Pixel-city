//
//  PhotogalleryCell.swift
//  Pixel city
//
//  Created by Massimiliano Abeli on 19/08/2018.
//  Copyright © 2018 Massimiliano Abeli. All rights reserved.
//

import UIKit

class PhotogalleryCell: UICollectionViewCell {
    
    let imageView = UIImageView()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.addSubview(imageView)
        self.clipsToBounds = true
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setupPhotogalleryCell(forImage image: UIImage, withSide side: CGFloat ) {
        imageView.image = image
        imageView.frame = CGRect(x: 0, y: 0, width: side, height: side*0.75)
        imageView.contentMode = .scaleAspectFill
    }
    
}
