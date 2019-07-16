# SwiftUI-ImageAPIDemo
Using SwiftUI to consume REST API with image data

![](./readme-assets/final01.png)

In this simple SwiftUI demo we create a simple iOS app that requests image data from Pixabay (https://pixabay.com) using its free REST-based API that returns JSON data.

___
## Get a free Pixabay account
First, register for an account at https://pixabay.com/en/accounts/register/

![](./readme-assets/img01.jpg)

Once you login to your account on Pixabay you’ll be able to see your API key in https://pixabay.com/api/docs/:

![](./readme-assets/img02.jpg)

Queries are very simple. The main parameters are:

**key** - Your API key<br>
**q** - What you’re searching for (URL encoded)<br>
**image_type** - The type of image you want ("all", "photo", "illustration", “vector")<br>

For example, we can look for "coffee" photos (the **q** parameter must be URL encoded) with:

https://pixabay.com/api/?key=your-api-key&q=coffee&image_type=photo

Note that there are also **page** and **per_page** parameters which we can use to implement lazily-loaded paginated data:

![](./readme-assets/img03.jpg)

We can test the query in an HTTP client such as **Paw** (https://paw.cloud/):

![](./readme-assets/img04.jpg)

Useful values returned in the response include:

**totalHits**
The number of images accessible through the API. By default, the API is limited to return a maximum of 500 images per query.

**hits**
A collection of image metadata, including URLs for a preview image, large image, etc.

___

## Create a new Xcode project
Create a new project in Xcode named **SwiftUI-ImageApiDemo**:

![](./readme-assets/img05.jpg)

The overall design for the app will be as follows:

* A struct named **PixabayData**
    * Conforms to the **Decodable** protocol. This allows us to to use Swift’s **JSONDecoder** to automatically decode JSON
    * Used as the model to map incoming raw JSON data from the Pixabay web API
    * The **hits** member of the struct will hold an array of image metadata (**PixabayImage**)

``` swift
public struct PixabayData: Decodable {
    public var totalHits: Int
    public var hits: [PixabayImage]
    public var total: Int
}
```

* A struct named **PixabayImage**
    * Conforms to the **Decodable** protocol
    * Models all the data for an individual Pixabay image

``` swift
public struct PixabayImage: Decodable, Identifiable {
    public var id: Int
    public var largeImageURL: String
    public var webformatHeight: Int
    :
    :
}
```

* A class named **PixabayHelper**
    * Used to make data requests to the REST API
    * Decode the incoming JSON data and store it in a **pixabayData** private property
    * Makes the **PixabayData.hits** array of **PixabayImage** data available via a public **imageData** property
    * Conforms to the SwiftUI **BindableObject** protocol. This allows it to notify subscribers when data has been downloaded from Pixabay

* Main **ContentView** struct
    * Will show a collection of preview images from the Pixabay data using a **List**
    * Also shows a **TextField** allowing a search term to by entered
    * Holds a **@ObjectBinding** var of **PixabayHelper**. When the data model (**imageData**) changes the **View** is invalidated and re-rendered

* We’ll store static query string elements in a .plist file and use a class **PropertyFileHelper** to help retrieve values. This avoids having to hard-code items like the unique API key
* When the user taps on a preview image we show the full image in a separate view
* The user can enter a search term for the images to be retrieved. Note that SwiftUI does not yet support the equivalent of **UISearchController** so we create our own simple alternative

___

## Configure access to Pixabay URL
First, the default security configuration for iOS will not allow requests to random URLs. You need to explicitly configure access to Pixabay by adding the following to your Info.plist:

```
<key>NSAppTransportSecurity</key>
<dict>
    <key>NSExceptionDomains</key>
    <dict>
        <key>pixabay.com</key>
        <dict>
            <key>NSExceptionAllowsInsecureHTTPLoads</key>
            <true/>
        </dict>
    </dict>
</dict>
```

___

## Create a Pixabay configuration plist and helper
Create a new .plist file named **Pixabay.plist**.  
Open it as source code and add the following:

```
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple Computer//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
    <key>PixabayUrl</key>
    <string>https://pixabay.com/api/?key=</string>
    <key>PixabayApiKey</key>
    <string>your-api-key-goes-here</string>
    <key>PixabayImageType</key>
    <string>image_type=photo</string>
</dict>
</plist>
```

Create a new .swift file named **PropertyFileHelper.swift** and add the following:

``` swift
//
//  PropertyFileHelper.swift
//  SwiftUI-ImageAPIDemo
//
//  Created by Russell Archer on 13/07/2019.
//  Copyright © 2019 Russell Archer. All rights reserved.
//

import Foundation
import UIKit

/*
 
 PropertyFileHelper reads the contents of a .plist file and allows you to read individual
 properties by their keys.
 
 Example usage:
 
 let _plistHelper = PropertyFileHelper(file: "MyPlistFile")  // Note: No .plist file extn
 guard _plistHelper.hasLoadedProperties else { return }
 guard var myValue = _plistHelper.readProperty(key: "MyKey") else { return }
 
 */

public class PropertyFileHelper {
    fileprivate var propertyFile: [String : AnyObject]?
    public var hasLoadedProperties: Bool { return propertyFile != nil ? true : false }
    
    /// Create a property list helper. Creating the helper also reads the contents of the property list.
    /// - Parameter file: The name of the property file, without the .plist extension
    init(file: String) {
        propertyFile = readPropertyFile(filename: file)
    }
    
    /// Read a property from a dictionary of values that was read from a plist.
    /// - Parameter key: Key that identifies an element in the property list
    public func readProperty(key: String) -> String? {
        guard propertyFile != nil else { return nil }
        if let value = propertyFile![key] as? String {
            return value
        }
        
        return nil
    }
    
    /// Read a plist property file and return a dictionary of values.
    /// - Parameter filename: The name of the property file, without the .plist extension
    fileprivate func readPropertyFile(filename: String) -> [String : AnyObject]? {
        if let path = Bundle.main.path(forResource: filename, ofType: "plist") {
            if let contents = NSDictionary(contentsOfFile: path) as? [String : AnyObject] {
                return contents
            }
        }
        
        return nil  // [:]
    }
}
```
