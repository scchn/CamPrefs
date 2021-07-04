//
//  LinkButton.swift
//  Cam Prefs
//
//  Created by scchn on 2021/6/30.
//

import Cocoa

@IBDesignable
class LinkButton: NSButton {
    
    @IBInspectable var url: String? = nil
    
    override func resetCursorRects() {
        addCursorRect(bounds, cursor: .pointingHand)
    }
    
    override func sendAction(_ action: Selector?, to target: Any?) -> Bool {
        if let urlString = url, let url = URL(string: urlString) {
            NSWorkspace.shared.open(url)
        }
        return super.sendAction(action, to: target)
    }
    
}

