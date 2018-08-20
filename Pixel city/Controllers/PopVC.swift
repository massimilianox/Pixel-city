//
//  PopVC.swift
//  Pixel city
//
//  Created by Massimiliano Abeli on 20/08/2018.
//  Copyright © 2018 Massimiliano Abeli. All rights reserved.
//

import UIKit

class PopVC: UIViewController {

    @IBOutlet weak var popPhotogalleryImg: UIImageView!
    
    var image: UIImage!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        popPhotogalleryImg.image = image
        
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(dismissView))
        self.view.addGestureRecognizer(tap)
        
    }
    
    func initData(withImage image: UIImage) {
        self.image = image
    }
    
    @objc func dismissView() {
        dismiss(animated: true, completion: nil)
    }

}
