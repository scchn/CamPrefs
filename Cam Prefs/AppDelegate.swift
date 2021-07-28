//
//  AppDelegate.swift
//  Cam Prefs
//
//  Created by chen on 2021/6/28.
//

import Cocoa
import AVFoundation

@main
class AppDelegate: NSObject, NSApplicationDelegate {
    
    var statusItem: StatusItem!
    
    func applicationDidFinishLaunching(_ notification: Notification) {
        AVCaptureDevice.requestAccess(for: .video) { ok in
            DispatchQueue.main.async {
                if ok {
                    self.statusItem = StatusItem()
                } else {
                    self.showAccessErrorAndQuit()
                }
            }
        }
    }
    
    private func showAccessErrorAndQuit() {
        let alert = NSAlert()
        alert.alertStyle = .critical
        alert.messageText = NSLocalizedString("Permission_Denied.Title", comment: "")
        alert.informativeText = NSLocalizedString("Permission_Denied.Message", comment: "")
        alert.addButton(withTitle: NSLocalizedString("Open_System_Preferences", comment: ""))
        alert.addButton(withTitle: NSLocalizedString("OK", comment: ""))
        
        if alert.runModal() == .alertFirstButtonReturn {
            let url = URL(string: "x-apple.systempreferences:com.apple.preference.security?Privacy_Camera")!
            NSWorkspace.shared.open(url)
        }
        
        NSApp.terminate(nil)
    }

}

