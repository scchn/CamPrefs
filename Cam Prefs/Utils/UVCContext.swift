//
//  UVCContext.swift
//  Cam Prefs
//
//  Created by scchn on 2021/6/29.
//

import Foundation

class UVCContext {
    
    static let shared = UVCContext()
    
    private var context: OpaquePointer
    
    deinit {
        uvc_exit(context)
    }
    
    private init() {
        var context: OpaquePointer?
        
        if uvc_init(&context, nil) == UVC_SUCCESS, let context = context {
            self.context = context
        } else {
            fatalError()
        }
    }
    
    func findDevice(vid: Int, pid: Int) -> UVCDevice? {
        var device: OpaquePointer?
        
        if uvc_find_device(context, &device, Int32(vid), Int32(pid), nil) == UVC_SUCCESS, let device = device {
            return UVCDevice(device: device)
        } else {
            return nil
        }
    }
    
}
