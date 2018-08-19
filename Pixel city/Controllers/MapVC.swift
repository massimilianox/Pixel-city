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

    // IBOutlet
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var photoView: UIView!
    @IBOutlet weak var photoViewHeightConstraint: NSLayoutConstraint!
    
    // Map view
    private var locationManager = CLLocationManager()
    private let authorizationStatus = CLLocationManager.authorizationStatus()
    
    var spinner: UIActivityIndicatorView = UIActivityIndicatorView()
    var progressLbl: UILabel = UILabel()
    
    // Photogallery
    var photogalleryCollectionViewFlowLayout: UICollectionViewFlowLayout = UICollectionViewFlowLayout()
    lazy var photogalleryCollectionView: UICollectionView = UICollectionView(frame: view.bounds, collectionViewLayout: photogalleryCollectionViewFlowLayout)
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Map view settings
        mapView.delegate = self
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.startUpdatingLocation()
        configureLocationService()
        
        // Gesture recognizer
        addTapGestureRecognizer()
        addSwipeGestureRecognizer()
        
        // Photogallery
        photogalleryCollectionView.register(PhotogalleryCell.self, forCellWithReuseIdentifier: photoCellReuseIdentifier)
        // photogalleryCollectionView.backgroundColor = #colorLiteral(red: 0.4666666687, green: 0.7647058964, blue: 0.2666666806, alpha: 1)
        photogalleryCollectionView.delegate = self
        photogalleryCollectionView.dataSource = self
        photoView.addSubview(photogalleryCollectionView)
        
        // Spinner
        spinner.isHidden = true
        photoView.addSubview(spinner)
        
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
    
    func addSwipeGestureRecognizer() {
        let swipeDown = UISwipeGestureRecognizer(target: self, action: #selector(animateViewDown))
        swipeDown.direction = .down
        photoView.addGestureRecognizer(swipeDown)
    }
    
    func animateViewUp() {
        photoViewHeightConstraint.constant = 300
        UIView.animate(withDuration: 0.3) {
            self.view.layoutIfNeeded()
        }
    }
    
    @objc func animateViewDown() {
        photoViewHeightConstraint.constant = 0
        UIView.animate(withDuration: 0.3) {
            self.view.layoutIfNeeded()
        }
    }
    
    func addSpinner() {
        spinner.activityIndicatorViewStyle = .whiteLarge
        spinner.color = DEFAULT_COLOR
        spinner.center = CGPoint(x: (self.view.frame.width / 2) - (spinner.frame.width / 2), y: 140 - (spinner.frame.height / 2))
        spinner.startAnimating()
        spinner.isHidden = false
    }
    
    func removeSpinner() {
        spinner.isHidden = true
//        if spinner != nil {
//            spinner.removeFromSuperview()
//        }
    }
    
    func addProgressLbl() {
        // progressLbl = UILabel()
        progressLbl.frame = CGRect(x: (self.view.frame.width / 2) - 130, y: 153, width: 260, height: 40)
        progressLbl.font = UIFont(name: DEFAULT_FONT, size: 13)
        progressLbl.textColor = DEFAULT_COLOR
        progressLbl.textAlignment = .center
        // progressLbl.text = "12 of 40 loaded"
        photoView.addSubview(progressLbl)
        
    }
    
    func removeProgressLbl() {
        progressLbl.removeFromSuperview()
//        if progressLbl != nil {
//            progressLbl?.removeFromSuperview()
//        }
    }
    
}


//::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::://
//::::::::::::::::::: Extension to handle Map View delegate ::::::::::::::::::::::://

extension MapVC: MKMapViewDelegate {
    
    // Guaranty the initial centering to current location
    func mapView(_ mapView: MKMapView, didUpdate userLocation: MKUserLocation) {
        centerMapOnUserLocation()
    }
    
    // Customize the pin
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        
        // return if annotation is user current location
        if annotation is MKUserLocation {
            return nil
        }
        
        // customize the pin
        let pinAnnotation = MKPinAnnotationView(annotation: annotation, reuseIdentifier: pinIdentifier)
        pinAnnotation.pinTintColor = DEFAULT_COLOR
        pinAnnotation.animatesDrop = true
        
        return pinAnnotation
    }
    
    func centerMapOnUserLocation() {
        guard let coordinate = locationManager.location?.coordinate else { return }
        
        // MKCoordinateRegion use latitude and longitude
        // let coordinateRegion = MKCoordinateRegion(center: coordinate, span: MKCoordinateSpan(latitudeDelta: regionRadius, longitudeDelta: regionRadius))
        
        // MKCoordinateRegionMakeWithDistance use kilometre
        let coordinateRegion = MKCoordinateRegionMakeWithDistance(coordinate, regionRadius, regionRadius)
        
        mapView.setRegion(coordinateRegion, animated: true)
    }
    
    @objc func dropApin(sender: UITapGestureRecognizer) {
        
        // some cleaning
        removePin()
        removeProgressLbl()
        self.addSpinner()
        self.addProgressLbl()
        
        // get the coordinate of tap gesture
        let touchPoint = sender.location(in: mapView) as CGPoint
        let touchCoordinate = mapView.convert(touchPoint, toCoordinateFrom: mapView)
        
        // create a marker on the map
        let annotation = DroppablePin(coordinate: touchCoordinate, identifier: pinIdentifier)
        mapView.addAnnotation(annotation)
        
        // zoom and center the new marker
        let coordinateRegion = MKCoordinateRegionMakeWithDistance(touchCoordinate, regionRadius, regionRadius)
        mapView.setRegion(coordinateRegion, animated: true)
        
        animateViewUp()
        
    }
    
    func removePin() {
        for annotation in mapView.annotations {
            mapView.removeAnnotation(annotation)
        }
    }

}



//::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::://
//:::::::::::::::::: Extension to handle Location View delegate ::::::::::::::::::://

extension MapVC: CLLocationManagerDelegate {
    
    func configureLocationService() {
        if authorizationStatus == .notDetermined {
            locationManager.requestWhenInUseAuthorization()
        } else {
            return
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        centerMapOnUserLocation()
    }
    
}


//::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::://
//:: Extension to handle UICollectionViewDelegate and UICollectionViewDataSource :://

extension MapVC: UICollectionViewDelegate, UICollectionViewDataSource {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 4
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if let cell = collectionView.dequeueReusableCell(withReuseIdentifier: photoCellReuseIdentifier, for: indexPath) as? PhotogalleryCell {
            return cell
        }
        return UICollectionViewCell()
    }
    
    
}

