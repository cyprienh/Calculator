//
//  PreferencesController.swift
//  Calculator
//
//  Created by Cyprien Heusse on 28/09/2021.
//

import Cocoa

class PreferencesController: NSViewController, NSTextFieldDelegate, NSWindowDelegate {
    
    var wantedSeparator: Int = 0
    
    @IBOutlet weak var DigitsInput: NSTextField!
    @IBOutlet weak var CommaSeparator: NSButton!
    @IBOutlet weak var DotSeparator: NSButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.view.window?.delegate = self
        
        self.DigitsInput.delegate = self
        self.DigitsInput.stringValue = String(AppVariables.digits)
        
        let pstyle = NSMutableParagraphStyle()
        self.DotSeparator.attributedTitle = NSAttributedString(string: "Dot (.)", attributes: [ NSAttributedString.Key.foregroundColor : NSColor.white, NSAttributedString.Key.paragraphStyle : pstyle ])
        self.CommaSeparator.attributedTitle = NSAttributedString(string: "Comma (,)", attributes: [ NSAttributedString.Key.foregroundColor : NSColor.white, NSAttributedString.Key.paragraphStyle : pstyle ])
        
        if AppVariables.separator == 0 {
            self.DotSeparator.state = NSControl.StateValue(rawValue: 1)
        } else {
            self.CommaSeparator.state = NSControl.StateValue(rawValue: 1)
        }
    }
    
    override func viewDidDisappear() {
        updateSettings()
    }
    
    func control(_ control: NSControl, textView: NSTextView, doCommandBy commandSelector: Selector) -> Bool {
        if (commandSelector == #selector(NSResponder.insertNewline(_:))) {
            updateSettings()
            return true
        }
        return false
    }
    
    @IBAction func DecimalSeparator(_ sender: Any) {
        wantedSeparator = (sender as! NSButton).tag
    }
    
    
    func updateSettings() {
        let defaults = UserDefaults.standard
        if DigitsInput.stringValue.isInteger {
            defaults.set(Int(DigitsInput.stringValue) ?? 4, forKey: "Digits")
            AppVariables.digits = Int(DigitsInput.stringValue) ?? 4
        }
        defaults.set(wantedSeparator, forKey: "Separator")
        AppVariables.separator = wantedSeparator
        NotificationCenter.default.post(name: Notification.Name(rawValue: "updateCalculator"), object: nil)
        self.view.window?.close()
    }
    
}
