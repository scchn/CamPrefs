//
//  StatusItem.swift
//  Cam Prefs
//
//  Created by scchn on 2021/6/29.
//

import Cocoa
import AVFoundation

fileprivate extension NSImage {
    
    static var appStatusItem: NSImage {
        let image = #imageLiteral(resourceName: "status_item")
        image.isTemplate = true
        return image
    }
    
    static var camera: NSImage {
        let image = #imageLiteral(resourceName: "camera")
        image.isTemplate = true
        return image
    }
        
    static var about: NSImage {
        let image = #imageLiteral(resourceName: "about")
        image.isTemplate = true
        return image
    }
    
    static var quit: NSImage {
        let image = #imageLiteral(resourceName: "quit")
        image.isTemplate = true
        return image
    }
    
}

class StatusItem {
    
    private let statusItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.variableLength)
    private let menu = NSMenu()
    private var uvcDevicePanels: [UVCDevicePanel] = []
    
    lazy
    private var aboutWindowController = AboutWindowController.instantiate(from: .main)
    
    init() {
        statusItem.button?.image = .appStatusItem
        statusItem.menu = menu
        setupObservers()
        
        // Initial Refresh of Device List
        let discSess = AVCaptureDevice.DiscoverySession(
            deviceTypes: [.externalUnknown],
            mediaType: .video,
            position: .unspecified
        )
        
        devicesWasConnected(discSess.devices)
    }
    
    // MARK: - Device Observation
    
    private func setupObservers() {
        let center = NotificationCenter.default
        
        center.addObserver(forName: .AVCaptureDeviceWasConnected, object: nil, queue: .main) { noti in
            guard let device = noti.object as? AVCaptureDevice else { return }
            self.devicesWasConnected([device])
        }
        
        center.addObserver(forName: .AVCaptureDeviceWasDisconnected, object: nil, queue: .main) { noti in
            guard let device = noti.object as? AVCaptureDevice else { return }
            self.devicesWasDisconnected([device])
        }
    }
    
    private func devicesWasConnected(_ devices: [AVCaptureDevice]) {
        for device in devices {
            guard let panel = UVCDevicePanel(captureDevice: device) else { continue }
            uvcDevicePanels.append(panel)
        }
        refreshMenu()
    }
    
    private func devicesWasDisconnected(_ devices: [AVCaptureDevice]) {
        for device in devices {
            guard let index = uvcDevicePanels.firstIndex(where: { $0.captureDevice == device }) else { continue }
            uvcDevicePanels.remove(at: index)
        }
        refreshMenu()
    }
    
    /// 更新主選單
    private func refreshMenu() {
        menu.removeAllItems()
        
        // Camera
        if !uvcDevicePanels.isEmpty {
            for device in uvcDevicePanels.map(\.captureDevice) {
                let item = menu.addItem(withTitle: device.localizedName,
                                        action: #selector(deviceMenuItemAction(_:)),
                                        keyEquivalent: "")
                item.target = self
                item.representedObject = device
                item.image = .camera
            }
        } else {
            let item = menu.addItem(withTitle: NSLocalizedString("No_Devices", comment: "未找到裝置"),
                                    action: nil,
                                    keyEquivalent: "")
            item.isEnabled = false
            item.image = .camera
        }
        
        menu.addItem(.separator())
        
        // About
        let about = menu.addItem(withTitle: NSLocalizedString("About_This_App", comment: "關於"),
                                 action: #selector(showAbout),
                                 keyEquivalent: "")
        about.target = self
        about.image = .about
        
        // Quit
        let quit = menu.addItem(withTitle: NSLocalizedString("Quit_App", comment: "結束程式"),
                                action: #selector(NSApplication.terminate(_:)),
                                keyEquivalent: "")
        quit.image = .quit
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
