//
//  PixabayHelper.swift
//  SwiftUI-ImageAPIDemo
//
//  Created by Russell Archer on 13/07/2019.
//  Copyright © 2019 Russell Archer. All rights reserved.
//

import Foundation
import UIKit
import SwiftUI
import Combine

class PixabayHelper: BindableObject {
    fileprivate let plistHelper = PropertyFileHelper(file: "Pixabay")  // Allows us access to the Pixabay.plist config file
    fileprivate var pixabayData: PixabayData?  // Holds decoded JSON data loaded from Pixabay
    fileprivate var currentSearchText = ""
    
    public var didChange = PassthroughSubject<Void, Never>()  // Allows us to publish a change message to subscribers
    public var imageData: [PixabayImage] {  // Image data from Pixabay, or a default if no data has been loaded       
        return pixabayData == nil ? [PixabayImage(imageName: "OwlSmall")] : pixabayData!.hits
    }
    
    /// Gets image data from the Pixabay REST API. Notifies subscribers if data is successfully loaded
    /// - Parameter searchFor: The kind of image to search for
    public func loadImages(searchFor: String) {
        guard searchFor.count > 2 else { return }
        guard plistHelper.hasLoadedProperties else { return }
        
        if searchFor == currentSearchText { return }
        currentSearchText = searchFor
        
        print("Loading data from Pixabay...")

        // Example query: https://pixabay.com/api/?key=your-api-key&image_type=photo&q=coffee
        guard var pixabayUrl = plistHelper.readProperty(key: "PixabayUrl") else { return }
        guard let pixabayApiKey = plistHelper.readProperty(key: "PixabayApiKey") else { return }
        guard let pixabayImageType = plistHelper.readProperty(key: "PixabayImageType") else { return }
        
        pixabayUrl += pixabayApiKey + "&" + pixabayImageType + "&q=" + searchFor
        
        let url = URL(string: pixabayUrl)!
        let session = URLSession.shared
        let task = session.dataTask(with: url) { [weak self] (json, response, error) in
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
            
            guard self.pixabayData != nil else { return }
            

            DispatchQueue.main.async(execute: {
                // Let subscribers know the data has changed.
                // Because we're currently not running on the main thread we explicitly call
                // on the main thread in case they try to update the UI
                self.didChange.send()
            })
        }
        task.resume()
    }
}
