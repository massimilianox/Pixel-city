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
import Alamofire
import AlamofireImage

class MapVC: UIViewController {

    // IBOutlet
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var photoView: UIView!
    @IBOutlet weak var photoViewHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var closePhotoViewBtn: UIButton!
    
    // Map view
    private var locationManager = CLLocationManager()
    private let authorizationStatus = CLLocationManager.authorizationStatus()
    
    var spinner: UIActivityIndicatorView = UIActivityIndicatorView()
    var progressLbl: UILabel = UILabel()
    
    // Photogallery
    var photogalleryCollectionViewFlowLayout: UICollectionViewFlowLayout = UICollectionViewFlowLayout()
    lazy var photogalleryCollectionView: UICollectionView = UICollectionView(frame: view.bounds, collectionViewLayout: photogalleryCollectionViewFlowLayout)
    
    var photogalleryImgUrl = [String]()
    var photogalleryImg = [UIImage]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Map view settings
        mapView.delegate = self
        locationManager.delegate = self
        // locationManager.desiredAccuracy = kCLLocationAccuracyBest // Not necessary
        locationManager.startUpdatingLocation()
        configureLocationService()
        
        // Gesture recognizer
        addTapGestureRecognizer()
        // addSwipeGestureRecognizer()
        
        // Photogallery
        photogalleryCollectionView.delegate = self
        photogalleryCollectionView.dataSource = self
        photogalleryCollectionView.register(PhotogalleryCell.self, forCellWithReuseIdentifier: photoCellReuseIdentifier)
        photogalleryCollectionView.backgroundColor = #colorLiteral(red: 0, green: 0, blue: 0, alpha: 1)
        photogalleryCollectionView.frame = CGRect(
            origin: CGPoint(x: 0, y: 0),
            size: CGSize(width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.height / 2)
        )
        photoView.addSubview(photogalleryCollectionView)
        photogalleryCollectionViewFlowLayout.minimumLineSpacing = 1
        photogalleryCollectionViewFlowLayout.minimumInteritemSpacing = 1
        
        // Register for 3D Touch conform to protocol UIViewControllerPreviewingDelegate
        registerForPreviewing(with: self, sourceView: photogalleryCollectionView)
        
        // Spinner
        spinner.isHidden = true
        photoView.addSubview(spinner)
        
        closePhotoViewBtn.isHidden = true
        
    }
    
    @IBAction func centerBtnPressed(_ sender: Any) {
        if authorizationStatus == .authorizedWhenInUse {
            centerMapOnUserLocation()
        }
    }
    
    @IBAction func closePhotoViewPressed(_ sender: Any) {
        animateViewDown()
    }
    
    func addTapGestureRecognizer() {
        let tap = UITapGestureRecognizer(target: self, action: #selector(dropApin(sender:)))
        mapView.addGestureRecognizer(tap)
    }
    
//    func addSwipeGestureRecognizer() {
//        let swipeDown = UISwipeGestureRecognizer(target: self, action: #selector(animateViewDown))
//        swipeDown.direction = .down
//        photoView.addGestureRecognizer(swipeDown)
//    }

    func animateViewUp() {
        let delta = UIScreen.main.bounds.height / 2
        photoViewHeightConstraint.constant = delta
        UIView.animate(withDuration: 0.3) {
            self.view.layoutIfNeeded()
            self.closePhotoViewBtn.isHidden = false
        }
    }
    
    func animateViewDown() {
        cancellAllSession()
        photoViewHeightConstraint.constant = 0
        UIView.animate(withDuration: 0.3) {
            self.view.layoutIfNeeded()
            self.closePhotoViewBtn.isHidden = true
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
        progressLbl.frame = CGRect(x: (self.view.frame.width / 2) - 130, y: 153, width: 260, height: 40)
        progressLbl.font = UIFont(name: DEFAULT_FONT, size: 13)
        progressLbl.textColor = DEFAULT_COLOR
        progressLbl.textAlignment = .center
        progressLbl.text = "0 of \(self.photogalleryImgUrl.count) downloaded"
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
    
    // Centering map on update current user location
//    func mapView(_ mapView: MKMapView, didUpdate userLocation: MKUserLocation) {
//        centerMapOnUserLocation()
//    }
    
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
        cancellAllSession()
        photogalleryImgUrl = []
        photogalleryImg = []
        photogalleryCollectionView.reloadData()
        removePin()
        removeProgressLbl()
        addSpinner()
        
        // get the coordinate of tap gesture
        let touchPoint = sender.location(in: mapView) as CGPoint
        let touchCoordinate = mapView.convert(touchPoint, toCoordinateFrom: mapView)
        
        // create a marker on the map
        let annotation = DroppablePin(coordinate: touchCoordinate, identifier: pinIdentifier)
        mapView.addAnnotation(annotation)
        
        // load images
        retriveImgUrls(forAnnotation: annotation) { (success) in
            if success {
                self.addProgressLbl()
                self.retriveImgs(completion: { (success) in
                    if success {
                        print("image \(self.photogalleryImg.count) loaded")
                        if self.photogalleryImgUrl.count == self.photogalleryImg.count {
                            self.removeSpinner()
                            self.removeProgressLbl()
                        }
                        self.photogalleryCollectionView.reloadData()
                        
                        let indexPath = IndexPath(row: self.photogalleryImg.count - 1, section: 0)
                        self.photogalleryCollectionView.scrollToItem(at: indexPath, at: .bottom, animated: true)
                    }
                })
            }
        }
        
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
    
    func retriveImgUrls(forAnnotation annotation: DroppablePin, completion: @escaping (_ success: Bool) -> ()) {
        Alamofire.request(flickrUrlSearch(forAnnotation: annotation, numberOfPhotos: 40)).responseJSON { (response) in
            
            if response.result.error == nil {
                guard let json = response.result.value as? Dictionary<String, Any> else { return }
                guard let photosDict = json["photos"] as? Dictionary<String, Any> else { return }
                guard let photoDict = photosDict["photo"] as? [Dictionary<String, Any>] else { return }
                
                for var photo in photoDict {
                    let url = "https://farm\(photo["farm"]!).staticflickr.com/\(photo["server"]!)/\(photo["id"]!)_\(photo["secret"]!)_h_d.jpg"
                    self.photogalleryImgUrl.append(url)
                }
            }
            completion(true)
        }
    }
    
    func retriveImgs(completion: @escaping (_ success: Bool) -> ()) {
        for url in photogalleryImgUrl {
            Alamofire.request(url).responseImage { (image) in
                if image.result.error == nil {
                    guard let img = image.result.value else { return }
                    self.photogalleryImg.append(img)
                    self.progressLbl.text = "\(self.photogalleryImg.count) of \(self.photogalleryImgUrl.count) downloaded"
                    completion(true)
                }
            }
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

extension MapVC: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    
    // Not required
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return photogalleryImg.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if let cell = collectionView.dequeueReusableCell(withReuseIdentifier: photoCellReuseIdentifier, for: indexPath) as? PhotogalleryCell {
            
            if photogalleryImg.count > 0 {
                cell.setupPhotogalleryCell(forImage: photogalleryImg[indexPath.row], withSide: computeCellWidth())
                return cell
            }
            return UICollectionViewCell()
        }
        return UICollectionViewCell()
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let side = computeCellWidth()
        return CGSize(width: side, height: side*0.75)
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        guard let popVC = storyboard?.instantiateViewController(withIdentifier: "popVC") as? PopVC else { return }
        
        popVC.initData(withImage: photogalleryImg[indexPath.row])
        present(popVC, animated: true, completion: nil)
        
    }
    
    func cancellAllSession() {
        Alamofire.SessionManager.default.session.getTasksWithCompletionHandler { (sessionDataTask, sessionUploadTask, sessionDownloadTask) in
            sessionDataTask.forEach({ (dataTask) in
                dataTask.cancel()
            })
            sessionDownloadTask.forEach({ (downloadTask) in
                downloadTask.cancel()
            })
        }
    }
    
    // Consider to make a service
    func computeCellWidth() -> CGFloat {
        var columns: CGFloat = 3
        if UIScreen.main.bounds.width > 320 && UIScreen.main.bounds.width < 414 {
            columns = 4
        } else {
            columns = 5
        }
        let padding: CGFloat = 2
        let withinCells: CGFloat = 1
        return ((photogalleryCollectionView.frame.width - padding) - ((columns - 1) * withinCells)) / columns
    }
    
}


//::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::://
//::::::::::::::::::::::::: Extension to handle 3D Touch :::::::::::::::::::::::::://

extension MapVC: UIViewControllerPreviewingDelegate {
    
    func previewingContext(_ previewingContext: UIViewControllerPreviewing, viewControllerForLocation location: CGPoint) -> UIViewController? {
        
        guard let indexPath = photogalleryCollectionView.indexPathForItem(at: location) else { return nil }
        guard let cell = photogalleryCollectionView.cellForItem(at: indexPath) else { return nil }
        guard let popVC = storyboard?.instantiateViewController(withIdentifier: "popVC") as? PopVC else { return nil }
        popVC.initData(withImage: photogalleryImg[indexPath.row])
        
        previewingContext.sourceRect = cell.contentView.frame
        
        return popVC
    }
    
    func previewingContext(_ previewingContext: UIViewControllerPreviewing, commit viewControllerToCommit: UIViewController) {
        show(viewControllerToCommit, sender: self)
    }
    
    
}









