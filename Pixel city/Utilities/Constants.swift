//
//  Constants.swift
//  Pixel city
//
//  Created by Massimiliano Abeli on 19/08/2018.
//  Copyright © 2018 Massimiliano Abeli. All rights reserved.
//

import UIKit

// REST
let API_KEY = "b9704bf0d2952258934e8a6a2cb6ce38"
let BASE_URL = "https://api.flickr.com/services/rest/?"
let METHOD = "flickr.photos.getRecent"
func flickrUrlSearch(forAnnotation annotation: DroppablePin, numberOfPhotos number: Int) -> String {
    return "\(BASE_URL)method=\(METHOD)&api_key=\(API_KEY)&lat=\(annotation.coordinate.latitude)&lon\(annotation.coordinate.longitude)&radius=\(regionRadius)&radius_units=Km&per_page=\(number)&format=json&nojsoncallback=1"
}

// Identifier
let photoCellReuseIdentifier = "photogalleryCell"
let pinIdentifier = "droppablePin"

// Constant number
let regionRadius: Double = 200

// UI
let DEFAULT_FONT = "KohinoorDevanagari-Regular"
let DEFAULT_COLOR = #colorLiteral(red: 0.3843137255, green: 0.5215686275, blue: 0.7176470588, alpha: 1)

