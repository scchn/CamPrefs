//
//  BaseWindowController.swift
//  
//
//  Created by scchn on 2021/4/15.
//

import Cocoa

open class BaseWindowController: NSWindowController {

    open override var windowNibName: NSNib.Name? { NSNib.Name("") }

    public init() {
        super.init(window: nil)
    }
    
    required public init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    open override func loadWindow() {
        fatalError("loadWindow must be overriden by subclasses")
    }
    
}
