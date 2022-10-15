//
//  CalcTextView.swift
//  Calculator
//
//  Created by Cyprien Heusse on 12/10/2021.
//

import Cocoa

class CalcTextView: NSTextView {

    init() {
        super.init(frame: NSRect.zero)
    }
    
    required init(coder: NSCoder) {
        super.init(coder: coder)!

        let textStorage = NSTextStorage()
        let layoutManager = NSLayoutManager()
        textStorage.addLayoutManager(layoutManager)
            // By default, NSTextContainers do not track the bounds of the NSTextview
        let textContainer = NSTextContainer(containerSize: CGSize.zero)
        textContainer.widthTracksTextView = true
        textContainer.heightTracksTextView = true
        
        layoutManager.addTextContainer(textContainer)
        replaceTextContainer(textContainer)
    }

}
