//
//  MapVC.swift
//  Pixel city
//
//  Created by Massimiliano Abeli on 18/08/2018.
//  Copyright © 2018 Massimiliano Abeli. All rights reserved.
//

import UIKit
import MapKit
import CoreLocation

class MapVC: UIViewController {

    @IBOutlet weak var mapView: MKMapView!
    
    var locationManager = CLLocationManager()
    
    let authorizationStatus = CLLocationManager.authorizationStatus()
    let regionRadius: Double = 3000
    
    override func viewDidLoad() {
        super.viewDidLoad()
        mapView.delegate = self
        
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.startUpdatingLocation()
        configureLocationService()
    }
    
    @IBAction func centerBtnPressed(_ sender: Any) {
        if authorizationStatus == .authorizedWhenInUse {
            centerMapOnUserLocation()
        }
    }
    
}

// Extension to handle Map View delegate
extension MapVC: MKMapViewDelegate {
    
    func centerMapOnUserLocation() {
        guard let coordinate = locationManager.location?.coordinate else { return }
        
        // MKCoordinateRegion use latitude and longitude
        // let coordinateRegion = MKCoordinateRegion(center: coordinate, span: MKCoordinateSpan(latitudeDelta: regionRadius, longitudeDelta: regionRadius))
        
        // MKCoordinateRegionMakeWithDistance use kilometre
        let coordinateRegion = MKCoordinateRegionMakeWithDistance(coordinate, regionRadius, regionRadius)
        
        mapView.setRegion(coordinateRegion, animated: true)
    }
    
}

// Extension to handle Location View delegate
extension MapVC: CLLocationManagerDelegate {
    
    func configureLocationService() {
        if authorizationStatus == .notDetermined {
            // locationManager.requestAlwaysAuthorization()
            locationManager.requestWhenInUseAuthorization()
        } else {
            return
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        centerMapOnUserLocation()
    }
    
}

