//
//  SearchText.swift
//  SwiftUI-ImageAPIDemo
//
//  Created by Russell Archer on 14/07/2019.
//  Copyright © 2019 Russell Archer. All rights reserved.
//

import Foundation
import SwiftUI
import Combine

/// An ObservableObject that allows us to subscribe to changes to a String that is bound to a TextField.
/// A simpler approach would be to have a @State String var with a didSet property observer. However,
/// this doesn't seem to be supported (the didSet is never called) in SwiftUI currently (Xcode 11 Beta 5)
class SearchText: ObservableObject {
    //public var didChange = PassthroughSubject<Void, Never>()
    
    @Published public var text = "kittens"
}
