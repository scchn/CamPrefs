//
//  AppDelegate.swift
//  Cam Prefs
//
//  Created by chen on 2021/6/28.
//

import Cocoa

@main
class AppDelegate: NSObject, NSApplicationDelegate {
    
    var statusItem: StatusItem!
    
    func applicationDidFinishLaunching(_ notification: Notification) {
        statusItem = StatusItem()
    }

}

