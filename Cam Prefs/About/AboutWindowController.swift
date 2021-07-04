//
//  AboutWindowController.swift
//  Cam Prefs
//
//  Created by scchn on 2021/6/30.
//

import Cocoa

class AboutWindowController: NSWindowController, NSWindowDelegate {
    
    override func windowDidLoad() {
        super.windowDidLoad()
        window?.delegate = self
        window?.center()
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
    
    func windowShouldClose(_ sender: NSWindow) -> Bool {
        defer { cancel(nil) }
        return false
    }
    
}

class AboutViewController: NSViewController {
    
    @IBOutlet weak var versionLabel: NSTextField!
    
    override func viewWillAppear() {
        super.viewWillAppear()
        
        view.window?.isMovableByWindowBackground = true
        
        if let version = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String {
            versionLabel.stringValue = "v" + version
        } else {
            versionLabel.stringValue = "v1.0"
        }
    }
    
}
