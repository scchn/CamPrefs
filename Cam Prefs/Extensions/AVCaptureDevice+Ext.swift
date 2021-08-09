//
//  AVCaptureDevice+Ext.swift
//  Cam Prefs
//
//  Created by chen on 2021/6/29.
//

import Foundation
import AVFoundation

extension AVCaptureDevice {
    
    var vendorID: Int? {
        if #available(macOS 12, *) {
            let components = self.uniqueID.components(separatedBy: "-")
            guard components.count >= 5 else { return nil }
            return Int(components[3], radix: 16)
        } else {
            guard uniqueID.count >= 8 else { return nil }
            let end = uniqueID.index(uniqueID.endIndex, offsetBy: -4)
            let start = uniqueID.index(end, offsetBy: -4)
            return Int(uniqueID[start..<end], radix: 16)
        }
    }
    
    var productID: Int? {
        if #available(macOS 12, *) {
            let components = self.uniqueID.components(separatedBy: "-")
            guard components.count >= 5, components[4].count >= 8 else { return nil }
            let pID = components[4]
            let range = pID.startIndex...pID.index(pID.startIndex, offsetBy: 7)
            return Int(pID[range], radix: 16)
        } else {
            guard uniqueID.count >= 8 else { return nil }
            let end = uniqueID.endIndex
            let start = uniqueID.index(end, offsetBy: -4)
            return Int(uniqueID[start..<end], radix: 16)
        }
    }
    
}
