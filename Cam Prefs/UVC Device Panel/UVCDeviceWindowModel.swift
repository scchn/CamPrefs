//
//  UVCDeviceWindowModel.swift
//  Cam Prefs
//
//  Created by scchn on 2021/6/29.
//

import Foundation
import AVFoundation

extension UVCDeviceWindowModel {
    
    struct Input {
        
    }
    
    struct Output {
        
    }
    
}

class UVCDeviceWindowModel {
    
    private let captureDevice: AVCaptureDevice
    private let uvcDevice: UVCDevice
    
    let viewModel: UVCDeviceViewModel
    
    init(captureDevice: AVCaptureDevice, uvcDevice: UVCDevice) {
        self.captureDevice = captureDevice
        self.uvcDevice = uvcDevice
        self.viewModel = UVCDeviceViewModel(captureDevice: captureDevice, uvcDevice: uvcDevice)
    }
    
    func transform(_ input: Input) -> Output {
        return Output()
    }
    
}
