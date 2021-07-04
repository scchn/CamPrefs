//
//  Storyboard.swift
//  
//
//  Created by scchn on 2021/4/15.
//

import Foundation

import Cocoa

public struct Storyboard : Hashable, Equatable, RawRepresentable {
    
    public static let main = Storyboard("Main")
    
    public var rawValue: String

    public init(_ rawValue: String) {
        self.rawValue = rawValue
    }

    public init(rawValue: String) {
        self.rawValue = rawValue
    }
    
    public var instance: NSStoryboard {
        .init(name: rawValue, bundle: nil)
    }
    
}

//

public protocol StoryboardInstantiable {
    
    static func instantiate(from storyboard: Storyboard) -> Self
    
}

extension StoryboardInstantiable {
    
    public static func instantiate(withIdentifier identifier: String, from storyboard: Storyboard) -> Self {
        storyboard.instance.instantiateController(withIdentifier: identifier) as! Self
    }
    
    public static func instantiate(from storyboard: Storyboard) -> Self {
        instantiate(withIdentifier: "\(self)", from: storyboard)
    }
    
}

//

extension NSViewController: StoryboardInstantiable { }

extension NSWindowController: StoryboardInstantiable { }
