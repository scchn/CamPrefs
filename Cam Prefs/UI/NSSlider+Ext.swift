//
//  NSSlider+Ext.swift
//  Cam Prefs
//
//  Created by scchn on 2021/6/29.
//

import Cocoa

extension NSSlider {
    
    var range: ClosedRange<Int> {
        Int(minValue)...Int(maxValue)
    }
    
    func setRange(_ range: ClosedRange<Int>, value: Int? = nil) {
        minValue = Double(range.lowerBound)
        maxValue = Double(range.upperBound)
        
        if let value = value {
            integerValue = value
        }
    }
    
}
