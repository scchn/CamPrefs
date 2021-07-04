//
//  UVCDeviceWindowController.swift
//  Cam Prefs
//
//  Created by scchn on 2021/6/29.
//

import Cocoa

class UVCDeviceWindowController: BaseWindowController {
    
    private let contentSize = CGSize(width: 480, height: 270)
    
    var windowModel: UVCDeviceWindowModel!
    
    var willClose: (() -> Void)?
    
    override func loadWindow() {
        let contentRect = CGRect(origin: .zero, size: contentSize)
        let styleMask: NSWindow.StyleMask = [.titled, .closable, .fullSizeContentView]
        let window = NSWindow(
            contentRect: contentRect,
            styleMask: styleMask,
            backing: .buffered,
            defer: false
        )
        
        window.titlebarAppearsTransparent = true
        window.tabbingMode = .disallowed
        window.isMovableByWindowBackground = true
        window.center()
        window.delegate = self
        
        self.window = window
    }
    
    override func windowDidLoad() {
        super.windowDidLoad()
        
        let contentViewController = UVCDeviceViewController.instantiate(from: .main)
        contentViewController.viewModel = windowModel.viewModel
        
        self.contentViewController = contentViewController
    }
    
    @objc
    func cancel(_ sender: Any?) {
        NSAnimationContext.beginGrouping()
        NSAnimationContext.current.completionHandler = { [weak self] in
            guard let self = self else { return }
            self.close()
            self.window?.alphaValue = 1
        }
        window?.animator().alphaValue = 0.0
        NSAnimationContext.endGrouping()
    }
    
}

extension UVCDeviceWindowController: NSWindowDelegate {
    
    func windowShouldClose(_ sender: NSWindow) -> Bool {
        defer { cancel(nil) }
        return false
    }
    
    func windowWillClose(_ notification: Notification) {
        willClose?()
    }
    
}
