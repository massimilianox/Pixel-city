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
        // mapView.showsZoomControls = true
        
        
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.startUpdatingLocation()
        configureLocationService()
        
        addTapGestureRecognizer()
        
    }
    
    @IBAction func centerBtnPressed(_ sender: Any) {
        if authorizationStatus == .authorizedWhenInUse {
            centerMapOnUserLocation()
        }
    }
    
    func addTapGestureRecognizer() {
        let tap = UITapGestureRecognizer(target: self, action: #selector(dropApin(sender:)))
        mapView.addGestureRecognizer(tap)
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
    
    // Guaranty the initial centering to current location
    func mapView(_ mapView: MKMapView, didUpdate userLocation: MKUserLocation) {
        centerMapOnUserLocation()
    }
    
    @objc func dropApin(sender: UITapGestureRecognizer) {
        
        removePin()
        
        // get the coordinate of tap gesture
        let touchPoint = sender.location(in: mapView) as CGPoint
        let touchCoordinate = mapView.convert(touchPoint, toCoordinateFrom: mapView)
        
        // create a marker on the map
        let annotation = DroppablePin(coordinate: touchCoordinate, identifier: "droppablePin")
        mapView.addAnnotation(annotation)
        
        // zoom and center the new marker
        let coordinateRegion = MKCoordinateRegionMakeWithDistance(touchCoordinate, regionRadius, regionRadius)
        mapView.setRegion(coordinateRegion, animated: true)
        
    }
    
    func removePin() {
        for annotation in mapView.annotations {
            mapView.removeAnnotation(annotation)
        }
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

