//
//  ViewController.swift
//  Pixel city
//
//  Created by Massimiliano Abeli on 18/08/2018.
//  Copyright © 2018 Massimiliano Abeli. All rights reserved.
//

import UIKit
import MapKit

class MapVC: UIViewController {

    @IBOutlet weak var mapView: MKMapView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
            mapView.delegate = self
    }
    
    @IBAction func centerBtnPressed(_ sender: Any) {
        
    }
    
}

// Extension to handle Map View delegate
extension MapVC: MKMapViewDelegate {
    
}

