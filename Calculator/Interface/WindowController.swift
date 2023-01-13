//
//  WindowController.swift
//  Calculator
//
//  Created by Cyprien Heusse on 20/06/2022.
//

import Cocoa

class WindowController: NSWindowController, NSWindowDelegate {
    
    override func windowDidLoad() {
        super.windowDidLoad()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        shouldCascadeWindows = true
    }
    
}

extension Notification.Name {
    static let newDocumentToAdd = Notification.Name("newDocumentToAdd")
}
