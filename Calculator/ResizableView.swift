//
//  ResizableView.swift
//  Calculator
//
//  Created by Cyprien Heusse on 17/09/2021.
//

import Cocoa

class ResizeView: NSView {
        
    @IBOutlet var contentView: NSView!

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override func viewDidEndLiveResize() {
        print("hey")
    }
}
