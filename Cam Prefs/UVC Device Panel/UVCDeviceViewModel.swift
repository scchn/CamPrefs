//
//  UVCDeviceViewModel.swift
//  Cam Prefs
//
//  Created by scchn on 2021/6/29.
//

import Cocoa
import AVFoundation

import RxSwift
import RxCocoa

class UVCDeviceViewModel {
    
    enum Mode {
        case normal
        case preview
        
        var size: CGSize {
            switch self {
            case .normal:  return CGSize(width: 436, height: 450)
            case .preview: return CGSize(width: 436 + 517, height: 450)
            }
        }
        
        var image: NSImage {
            self == .preview ? #imageLiteral(resourceName: "preview_off") : #imageLiteral(resourceName: "preview_on")
        }
    }
    
    private let captureSession = AVCaptureSession()
    private let captureDevice: AVCaptureDevice
    private let uvcDevice: UVCDevice
    
    var title: String { uvcDevice.productName ?? "-" }
    
    lazy private(set)
    var previewLayer: CALayer? = createPreviewLayer()
    
    let mode = BehaviorRelay<Mode>(value: .normal)
    
    init(captureDevice: AVCaptureDevice, uvcDevice: UVCDevice) {
        self.captureDevice = captureDevice
        self.uvcDevice = uvcDevice
    }
    
    // MARK: - Preview
    
    private func createPreviewLayer() -> CALayer? {
        guard let input = try? AVCaptureDeviceInput(device: captureDevice),
              captureSession.canAddInput(input)
        else { return nil }
        captureSession.beginConfiguration()
        captureSession.addInput(input)
        captureSession.commitConfiguration()
        return AVCaptureVideoPreviewLayer(session: captureSession)
    }
    
    func togglePreview() {
        if captureSession.isRunning {
            captureSession.stopRunning()
            mode.accept(.normal)
        } else {
            captureSession.startRunning()
            mode.accept(.preview)
        }
    }
    
    // MARK: - Range Control
    
    func getRange(for control: UVCRangeControl) -> ClosedRange<Int>? {
        uvcDevice.getRange(control)
    }
    
    func getValue(for control: UVCRangeControl) -> Int? {
        uvcDevice.getValue(control)
    }
    
    @discardableResult
    func setValue(_ value: Int, for control: UVCRangeControl) -> Bool {
        uvcDevice.setValue(value, for: control)
    }
    
    // MARK: - State Control
    
    func getState(for control: UVCStateControl) -> Bool? {
        uvcDevice.getState(control)
    }
    
    @discardableResult
    func setState(_ state: Bool, for control: UVCStateControl)-> Bool {
        uvcDevice.setState(state, for: control)
    }
    
    // MARK: - Others
    
    func resetToDefault() {
        uvcDevice.resetAll()
    }
    
}
