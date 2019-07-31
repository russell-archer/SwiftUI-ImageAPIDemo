//
//  PixabayHelper.swift
//  SwiftUI-ImageAPIDemo
//
//  Created by Russell Archer on 13/07/2019.
//  Copyright © 2019 Russell Archer. All rights reserved.
//
//  Example Pixabay query: https://pixabay.com/api/?key=key-here&image_type=photo&per_page=5&q=coffee
//

import Foundation
import UIKit
import SwiftUI
import Combine

class PixabayHelper: ObservableObject {
    fileprivate let plistHelper = PropertyFileHelper(file: "Pixabay")  // Allows us access to the Pixabay.plist config file
    fileprivate var pixabayData: PixabayData?  // Holds decoded JSON data loaded from Pixabay
    fileprivate var currentSearchText = ""
    fileprivate enum networkError: Error { case statusCodeIndicatesError }
    
    // Configuration data
    fileprivate var pixabayUrl: String
    fileprivate let pixabayApiKey: String
    fileprivate let pixabayImageType: String
    fileprivate let pixabayResultPerPage: String
    
    /// This published imageData ensures that when the data changes the View in ContentView is re-rendered
    @Published public var imageData: [PixabayImage] = [PixabayImage(imageName: "OwlSmall")]
    
    init() {
        pixabayUrl = plistHelper.readProperty(key: "PixabayUrl")!
        pixabayApiKey = plistHelper.readProperty(key: "PixabayApiKey")!
        pixabayImageType = plistHelper.readProperty(key: "PixabayImageType")!
        pixabayResultPerPage = plistHelper.readProperty(key: "PixabayResultsPerPage")!
    }
    
    /// Gets image data from the Pixabay REST API
    /// - Parameter searchFor: The kind of image to search for
    public func loadImages(searchFor: String) {
        if searchFor == currentSearchText { return }
        currentSearchText = searchFor

        pixabayUrl += pixabayApiKey + "&" + pixabayImageType + "&" + pixabayResultPerPage + "&q=" + searchFor
        
        let _ = URLSession.shared.dataTaskPublisher(for: URLRequest(url: URL(string: pixabayUrl)!))
            .receive(on: RunLoop.main)  // The whole chain fails without this!
            .tryMap { data, response -> Data in
                guard let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 else {
                    throw networkError.statusCodeIndicatesError
                }

                return data  // Pick off just the JSON data
            }
            .decode(type: PixabayData.self, decoder: JSONDecoder())  // Decode the JSON using our PixabayData model
            .sink(receiveCompletion: { _ in }, receiveValue: { decodedData in
                // Cache the received and decoded data
                self.pixabayData = decodedData
                self.imageData = self.pixabayData == nil ? [PixabayImage(imageName: "OwlSmall")] : self.pixabayData!.hits
            })
    }
}

/*
    Previous pre-Combine version of loadImages(searchFor:)
 
     public func loadImages(searchFor: String) {
         if searchFor == currentSearchText { return }
         currentSearchText = searchFor

         pixabayUrl += pixabayApiKey + "&" + pixabayImageType + "&" + pixabayResultPerPage + "&q=" + searchFor
         
         let task = session.dataTask(with: URL(string: pixabayUrl)!) { [weak self] (json, response, error) in
             guard let self = self else { return }
             guard json != nil else { return }
             let httpResponse = response as! HTTPURLResponse
             print("HTTP response status code: \(httpResponse.statusCode)")  // 200 == OK
 
             guard httpResponse.statusCode == 200 else {
                 print("The HTTP response status code indicates there was an error")
                 return
             }
 
             // This is the type-safe method of parsing the JSON.
             // See the model PixabayData used to map the JSON
             let decoder = JSONDecoder()
             let dataModelType = PixabayData.self
             self.pixabayData = try? decoder.decode(dataModelType, from: json!)
 
             DispatchQueue.main.async {
                 self.imageData = self.pixabayData == nil ? [PixabayImage(imageName: "OwlSmall")] : self.pixabayData!.hits
             }
         }
 
         task.resume()
     }
 
 */
