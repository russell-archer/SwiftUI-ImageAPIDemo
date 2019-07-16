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
