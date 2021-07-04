//
//  UVCDevicePanel.swift
//  Cam Prefs
//
//  Created by scchn on 2021/6/29.
//

import Cocoa
import AVFoundation

class UVCDevicePanel {
    
    private let uvcDevice: UVCDevice
    private var windowController: UVCDeviceWindowController?
    
    let captureDevice: AVCaptureDevice
    
    deinit {
        windowController?.close()
    }
    
    init?(captureDevice: AVCaptureDevice) {
        guard let vid = captureDevice.vendorID, let pid = captureDevice.productID,
              let uvcDevice = UVCContext.shared.findDevice(vid: vid, pid: pid)
        else { return nil }
        
        self.uvcDevice = uvcDevice
        self.captureDevice = captureDevice
    }
    
    func open() {
        let windowController: UVCDeviceWindowController
        
        if let controller = self.windowController {
            windowController = controller
        } else {
            windowController = UVCDeviceWindowController()
            windowController.windowModel = UVCDeviceWindowModel(captureDevice: captureDevice, uvcDevice: uvcDevice)
            windowController.willClose = { [weak self] in
                guard let self = self else { return }
                self.windowController = nil
            }
            self.windowController = windowController
        }
        
        windowController.showWindow(nil)
        
        NSApp.activate(ignoringOtherApps: true)
    }
    
    func close() {
        windowController?.close()
    }
    
}
