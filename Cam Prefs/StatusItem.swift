//
//  StatusItem.swift
//  Cam Prefs
//
//  Created by scchn on 2021/6/29.
//

import Cocoa
import AVFoundation

class StatusItem {
    
    private let statusItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.variableLength)
    private let menu = NSMenu()
    private var uvcDevicePanels: [UVCDevicePanel] = []
    
    lazy
    private var aboutWindowController = AboutWindowController.instantiate(from: .main)
    
    init() {
        let image = #imageLiteral(resourceName: "status_item")
        image.isTemplate = true
        
        self.statusItem.button?.image = image
        self.statusItem.menu = menu
        
        let captureDevices = AVCaptureDevice
            .DiscoverySession(deviceTypes: [.externalUnknown], mediaType: .video, position: .unspecified)
            .devices
        
        if captureDevices.isEmpty {
            refreshMenu()
        } else {
            captureDevices.forEach(deviceWasConnected(_:))
        }
        
        setupObservers()
    }
    
    private func setupObservers() {
        let center = NotificationCenter.default
        
        center.addObserver(forName: .AVCaptureDeviceWasConnected, object: nil, queue: .main) { noti in
            guard let device = noti.object as? AVCaptureDevice else { return }
            self.deviceWasConnected(device)
        }
        
        center.addObserver(forName: .AVCaptureDeviceWasDisconnected, object: nil, queue: .main) { noti in
            guard let device = noti.object as? AVCaptureDevice else { return }
            self.deviceWasDisconnected(device)
        }
    }
    
    /// 更新主選單
    private func refreshMenu() {
        menu.removeAllItems()
        
        // Camera
        let cameraImage = #imageLiteral(resourceName: "camera")
        cameraImage.isTemplate = true
        
        if !uvcDevicePanels.isEmpty {
            for device in uvcDevicePanels.map(\.captureDevice) {
                let title = device.localizedName
                let action = #selector(deviceMenuItemAction(_:))
                let item = menu.addItem(withTitle: title, action: action, keyEquivalent: "")
                item.target = self
                item.representedObject = device
                item.image = cameraImage
            }
        } else {
            let title = NSLocalizedString("No_Devices", comment: "未找到裝置")
            let item = menu.addItem(withTitle: title, action: nil, keyEquivalent: "")
            item.isEnabled = false
            item.image = cameraImage
        }
        
        menu.addItem(.separator())
        
        // About
        let aboutImage = #imageLiteral(resourceName: "about")
        let aboutTitle = NSLocalizedString("About_This_App", comment: "關於")
        let about = menu.addItem(withTitle: aboutTitle, action: #selector(showAbout), keyEquivalent: "")
        about.target = self
        aboutImage.isTemplate = true
        about.image = aboutImage
        
        // Quit
        let quitImage = #imageLiteral(resourceName: "quit")
        let quitTitle = NSLocalizedString("Quit_App", comment: "結束程式")
        let quit = menu.addItem(withTitle: quitTitle, action: #selector(NSApplication.terminate(_:)), keyEquivalent: "")
        quitImage.isTemplate = true
        quit.image = quitImage
    }
    
    /// 攝影機連線事件
    private func deviceWasConnected(_ device: AVCaptureDevice) {
        if let panel = UVCDevicePanel(captureDevice: device) {
            uvcDevicePanels.append(panel)
        }
        refreshMenu()
    }
    
    /// 攝影機斷線事件
    private func deviceWasDisconnected(_ device: AVCaptureDevice) {
        if let index = uvcDevicePanels.firstIndex(where: { $0.captureDevice == device }) {
            uvcDevicePanels.remove(at: index)
        }
        refreshMenu()
    }
    
    // MARK: - UI Actions
    
    /// 裝置選項事件
    @objc
    private func deviceMenuItemAction(_ sender: NSMenuItem) {
        guard let captureDevice = sender.representedObject as? AVCaptureDevice,
              let panel = uvcDevicePanels.first(where: { $0.captureDevice == captureDevice })
        else { return }
        panel.open()
    }
    
    /// 顯示關於視窗
    @objc
    private func showAbout() {
        aboutWindowController.showWindow(nil)
        NSApp.activate(ignoringOtherApps: true)
    }
    
}
