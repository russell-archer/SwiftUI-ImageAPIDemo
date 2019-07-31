//
//  ContentView.swift
//  SwiftUI-ImageAPIDemo
//
//  Created by Russell Archer on 13/07/2019.
//  Copyright © 2019 Russell Archer. All rights reserved.
//
//  Updated for Xcode Beta 5
//      -   @ObjectBinding deprecated for @ObservedObject
//      -   BindableObject protocol deprecated for ObservableObject in PixabayHelper
//      -   Refactored PixabayHelper.loadImages(searchFor:) to use the Combine framework extension dataTaskPublisher on URLSession
//      -   Refactored PixabayHelper to @Published imageData

import SwiftUI

struct ContentView : View {
    @ObservedObject var pixabayHelper = PixabayHelper()  // When our data model changes the View is invalidated and re-rendered
    @State fileprivate var searchText = ""
    
    var body: some View {
        NavigationView {
            VStack {
                HStack {
                    TextField("Enter search term", text: $searchText).padding()
                    
                    Button(action: {
                        self.pixabayHelper.loadImages(searchFor: self.searchText)
                    }) {
                        Image(systemName: "magnifyingglass").font(.largeTitle)
                    }
                    .padding()
                }
                
                List(pixabayHelper.imageData) { dataItem in
                    NavigationLink(destination: Image(uiImage: self.createImage(url: dataItem.webformatURL))) {
                        Image(uiImage: self.createImage(url: dataItem.previewURL))
                            .resizable()
                            .frame(width: (CGFloat)(dataItem.previewWidth), height: (CGFloat)(dataItem.previewHeight))
                            .aspectRatio(contentMode: .fit)
                    }
                }
            }
            .navigationBarTitle(Text("Pixabay API"))
        }
    }
    
    /// Helper function that returns a UIImage from a URL. If the URL is invalid a default image is returned.
    /// - Parameter url: URL of a Pixabay image preview
    fileprivate func createImage(url: String) -> UIImage {
        if let imageUrl = URL(string: url), let imageData = try? Data(contentsOf: imageUrl) {
            return UIImage(data: imageData)!
        }
        
        return UIImage(named: "OwlSmall")!  // Return a default image
    }
}

#if DEBUG
struct ContentView_Previews : PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
#endif
