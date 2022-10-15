//
//  CalcTextField.swift
//  Calculator
//
//  Created by Cyprien Heusse on 17/09/2021.
//

import Cocoa

class CalcTextField: NSTextField {

    override func viewWillDraw() {
        
        isHorizontallyResizable = true
        isVerticallyResizable = true
        
        isRichText = false
    }
}
