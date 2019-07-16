//
//  ContentView.swift
//  SwiftUI-ImageAPIDemo
//
//  Created by Russell Archer on 13/07/2019.
//  Copyright © 2019 Russell Archer. All rights reserved.
//

import SwiftUI

struct ContentView : View {
    @ObjectBinding var pixabayHelper = PixabayHelper()  // When our data model changes the View is invalidated and re-rendered
    @ObjectBinding var searchText = SearchText()
    
    var body: some View {
        pixabayHelper.loadImages(searchFor: searchText.text)
        
        return NavigationView {
                VStack {
                TextField("Search", text: self.$searchText.text)
                    .padding()

                List(pixabayHelper.imageData) { dataItem in
                    NavigationLink(destination: Image(uiImage: self.createImage(url: dataItem.webformatURL))) {
                        Image(uiImage: self.createImage(url: dataItem.previewURL))
                            .resizable()
                            .frame(width: (CGFloat)(dataItem.previewWidth), height: (CGFloat)(dataItem.previewHeight))
                            .aspectRatio(contentMode: .fit)
                            .cornerRadius(10)
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
