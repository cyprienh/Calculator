//
//  AppDelegate.swift
//  Calculator
//
//  Created by Cyprien Heusse on 09/09/2021.
//

import Cocoa

@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate {

    var mainWindowController: WindowController?
    
    func applicationDidFinishLaunching(_ aNotification: Notification) {
        // Insert code here to initialize your application
    }
    
    func applicationWillTerminate(_ aNotification: Notification) {
        // Insert code here to tear down your application
    }
    
    func applicationShouldTerminate(_ sender: NSApplication)-> NSApplication.TerminateReply {
        return .terminateNow
    }

}
