//
//  CalculatorWindow.swift
//  Calculator
//
//  Created by Cyprien Heusse on 01/10/2021.
//

import Cocoa

class CalculatorWindow: NSWindow {
    
    override init(contentRect: NSRect, styleMask style: NSWindow.StyleMask, backing backingStoreType: NSWindow.BackingStoreType, defer flag: Bool) {
        
        super.init(contentRect: contentRect, styleMask: style, backing: backingStoreType, defer: flag)
        backgroundColor = NSColor(red: 30/255, green: 30/255, blue: 30/255, alpha: 1.0)
        
        self.titleVisibility = NSWindow.TitleVisibility.hidden;
        self.titlebarAppearsTransparent = true;
        //self.styleMask |= NSFullSizeContentViewWindowMask;
        
    }
    
}
