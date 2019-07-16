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
