//
//  ViewController.swift
//  Calculator
//
//  Created by Cyprien Heusse on 09/09/2021.
//

// FIND A WAY TO CREATE A SCROLL VIEW WITH 2 TEXTVIEWS INSIDE

import Cocoa
import Numerics
//import PerfectPCRE2

struct CalcVariable {
    let name: String
    var value: Double
    let line: Int
    var unit: [Unit] = []
}

struct CalcFunctions {
    let name: String
    var variable: String
    var calc: [CalcElement]
}

struct CalcFunctionsDef {
    let name: String
    var line: Int
}

struct Message {
    let type: Int
    let line: Int
    let content: String
}

struct AppVariables {
    static var digits = 4
    static var separator = 0
}

struct CalcElement {
    var string: String
    var unit: [Unit] = []
    var isComplex: Bool = false
    var complex: Complex<Double> = Complex(0, 0)
    //var value: Double
    var range: NSRange
}

struct ColorElement {
    var color: NSColor
    var range: NSRange
}

// a=10a shouldnt be possible lmao

class ViewController: NSViewController, NSTextViewDelegate {
    let functions = ["e", "exp", "sqrt", "root", "ln", "sinh", "cosh", "tanh", "asinh", "acosh", "atanh", "sin", "cos", "tan", "asin", "acos", "atan", "log", "round", "ceil", "floor", "abs", "arg"]
    let constants = ["pi", "c", "h", "Na"]
    let fontAttributes = [NSAttributedString.Key.font: NSFont(name: "Fira Code", size: 13.0)!]
    let greenColor = NSColor(red: 10/255, green: 190/255, blue: 50/255, alpha: 1)
    var lines: [String] = []                        // Contains the text of each line, raw
    var lines_color: [[ColorElement]] = []          // Coloring information for the line, to make it look pretty
    var prev_lines: [String] = []                   // Contains the test of each line, before the new modification, for comparison
    var prev_results: [String] = []                 // Contains the results of the last modification, if prev_lines[i] == lines[i] then results[i] = prev_results[i] i guess
    var results: [String] = []                      // Results of the calculation of each line -> probably should be more than just a string ?
    var messages: [Message] = []                    // To output something other than the result: error, ...
    var variables: [CalcVariable] = []              // List of user defined variables; a=2
    var funcs: [CalcFunctions] = []                 // List of user defined functions; f(x)=4x
    var contains_func_var: [Bool] = []                  // If line i contains function OR VARIABLE
    var prev_str = ""                               // Text of the whole previous text
    var prev_factors: [[NSRange]] = []              // ???
    var factors_range: [[NSRange]] = []             // ???
    var func_var_defs: [CalcFunctionsDef] = []      // Where variable or function are defined
    
    @IBOutlet weak var ScrollView: NSScrollView!
    @IBOutlet weak var ScrollViewResult: NSScrollView!
    @IBOutlet var InputField: NSTextView!
    @IBOutlet var ResultLabel: NSTextView!
    
    override var representedObject: Any? {
        didSet {
            // Pass down the represented object to all of the child view controllers.
            for child in children {
                child.representedObject = representedObject
            }
        }
    }
    
    weak var document: Document? {
        if let docRepresentedObject = representedObject as? Document {
            return docRepresentedObject
        }
        return nil
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let defaults = UserDefaults.standard
        AppVariables.separator = defaults.integer(forKey: "Separator")
        if isKeyPresentInUserDefaults(key: "Digits") {
            AppVariables.digits = defaults.integer(forKey: "Digits")
        }
        
        NotificationCenter.default.addObserver(self, selector: #selector(updateCalculatorNotification), name: Notification.Name(rawValue: "updateCalculator"), object: nil)
        
        ScrollView.contentView.postsBoundsChangedNotifications = true
        NotificationCenter.default.addObserver(self, selector: #selector(boundsDidChangeNotification), name: NSView.boundsDidChangeNotification, object: ScrollView.contentView)

        ScrollViewResult.contentView.postsBoundsChangedNotifications = true
        NotificationCenter.default.addObserver(self, selector: #selector(boundsDidChangeNotification), name: NSView.boundsDidChangeNotification, object: ScrollViewResult.contentView)
        
        InputField.delegate = self
        InputField.font = NSFont(name: "Fira Code", size: 13.0)
        InputField.textColor = .white
        ResultLabel.font = NSFont(name: "Fira Code SemiBold", size: 13.0)
        ResultLabel.alignment = .center
    }
    
    
    @objc func boundsDidChangeNotification(_ notification: Notification) {
        if notification.object as? NSClipView == ScrollView.contentView {
            synchronizeScrollView(ScrollViewResult, toScrollView: ScrollView)
        } else if notification.object as? NSClipView == ScrollViewResult.contentView {
            synchronizeScrollView(ScrollView, toScrollView: ScrollViewResult)
        }
    }
    
    @objc func updateCalculatorNotification(_ notification: Notification) {
        prev_lines = []
        prev_factors = []
        prev_results = []
        updateCalculator(prev_str)
    }
    
    override func viewDidLayout() {
        var max_size = CGFloat(0.0)
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.paragraphSpacing = 6
        let fontSuper:NSFont? = NSFont(name: "Fira Code SemiBold", size: 10)
        let font:NSFont? = NSFont(name: "Fira Code SemiBold", size: 12.8)
        let defaultAttributes = [.font:font!,.foregroundColor:greenColor,NSAttributedString.Key.paragraphStyle:paragraphStyle]
        let exponentAttributes = [.font:fontSuper!,.baselineOffset:3,.foregroundColor:greenColor,NSAttributedString.Key.paragraphStyle:paragraphStyle] as [NSAttributedString.Key : Any]
        let outText = NSMutableAttributedString(string: "")
        for (i, r) in results.enumerated() {
            let size = (lines[i] as NSString).size(withAttributes: fontAttributes)
            if size.width >= InputField.frame.size.width-9 {
                let attString: NSMutableAttributedString = NSMutableAttributedString(string: "\u{2028}", attributes: defaultAttributes)
                outText.append(attString)
            }
            if i > 0 {
                let attString: NSMutableAttributedString = NSMutableAttributedString(string: "\n"+r, attributes: defaultAttributes)
                for j in factors_range[i] {
                    var r = j
                    if i > 0 {
                        r.location += 1
                    }
                    attString.setAttributes(exponentAttributes, range: r)
                }
                outText.append(attString)
            } else {
                let attString: NSMutableAttributedString = NSMutableAttributedString(string: r, attributes: defaultAttributes)
                for j in factors_range[i] {
                    var r = j
                    if i > 0 {
                        r.location += 1
                    }
                    attString.setAttributes(exponentAttributes, range: r)
                }
                outText.append(attString)
            }
            let rsize = outText.size()
            if rsize.width > max_size {
                max_size = rsize.width
            }
        }
        ResultLabel.textStorage!.setAttributedString(outText)
        
        ScrollViewResult.frame.size.width = max_size + 30
        ScrollViewResult.frame.size.height = view.frame.size.height - 20
        ScrollViewResult.frame.origin.x = view.frame.size.width - max_size - 30
        ScrollViewResult.frame.origin.y = 10
        
        ScrollView.frame.origin.y = 10
        ScrollView.frame.origin.x = 15
        ScrollView.frame.size.width = view.frame.size.width - 10 - ResultLabel.frame.size.width
    }

    func synchronizeScrollView(_ scrollViewToScroll: NSScrollView, toScrollView scrolledView: NSScrollView) {
        var offset = scrollViewToScroll.documentVisibleRect.origin
        offset.y = scrolledView.documentVisibleRect.origin.y
        let size = NSPoint(x: 0, y: offset.y);
        scrollViewToScroll.contentView.scroll(to: size)
    }
    
    func textViewDidChangeSelection(_ obj: Notification) {
        let textField = obj.object as! NSTextView
        let str = (textField.textStorage as NSAttributedString?)!.string
        
        prev_str = str
        prev_lines = lines
        prev_factors = factors_range
        prev_results = results
        
        updateCalculator(str)
    }
    
    func updateCalculator(_ str: String) {
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.paragraphSpacing = 6
        InputField.textStorage!.addAttributes([NSAttributedString.Key.paragraphStyle : paragraphStyle], range: NSMakeRange(0, str.count))
        
        lines = str.components(separatedBy: "\n")
        results = []
        factors_range = []
        lines_color = []

        //var line_index = 0
        
        for i in 0...lines.count-1 {                    // Prepare the arrays for new line
            results.append("")                          // One (empty for now) result per line
            factors_range.append([])                    // ???
            if !contains_func_var.indices.contains(i) {
                contains_func_var.append(false)             // Same array as before, for now let's pretend no user function is defined on a new line
            }
            if !lines_color.indices.contains(i) {       // Prepare the coloring of the line
                lines_color.append([])
            }
        }
        
        print(contains_func_var)
        
        for f in func_var_defs {                        // For each variable/function defined, check if said definition still exists
                                                        // Delete function/variable if doesn't exist -- Should also remove from func_var_defs ?
            if f.line >= lines.count || lines[f.line].prefix(f.name.count) != f.name {
                for (i, o) in funcs.enumerated() {
                    if o.name == f.name {
                        funcs.remove(at: i)
                    }
                }
                for (i, o) in variables.enumerated() {
                    if o.name == f.name {
                        variables.remove(at: i)
                    }
                }
            }
        }

        for l in 0...lines.count-1 {                    // The big part
            
            var already = false;
            if prev_lines.count > 0 {
                for p in 0...prev_lines.count-1 {
                    if lines[l] == prev_lines[p] && !contains_func_var[l] {         // if line is the same and there is no function/variabe that could be updated on another line
                        results[l] = prev_results[p]
                        factors_range[l] = prev_factors[p]
                        already = true
                    }
                }
            }
            
            var calc: [CalcElement] = []            // THE array containing the parsing result and the calculations
            var values: [CalcElement] = []
            
            var lastIndex = 0
            var type = -1
            var current = ""
            var range_2 = NSMakeRange(0, 0)
            
            if lines[l].count > 0 {                 // If line isn't empty
                for i in 0...lines[l].count-1 {     // For each char in line
                    let char = String(lines[l][lines[l].index(lines[l].startIndex, offsetBy: i)])
                    if shouldChange(char: char, type: type) {       // If char if of new type: i-1 -> "1" & i -> "+" => true
                        if current != "" {                          // First char should always change byt let's not add nothing to values
                            values.append(CalcElement(string: current, range: range_2))
                        }
                        lastIndex = i
                        
                        if char == " " {
                            type = 0
                        } else if char.isDouble {
                            type = 1
                        }  else if char.isOperator {
                            type = 3
                        }  else {
                            type = 2
                        }
                    }
                    let start = lines[l].index(lines[l].startIndex, offsetBy: lastIndex)            // Kinda stupid to redefine the starting index every time
                    let end = lines[l].index(lines[l].endIndex, offsetBy: -(lines[l].count-i-1))
                    let range = start..<end
                    range_2 = NSMakeRange(/*line_index+*/lastIndex, i+1-lastIndex)

                    let substr = String(lines[l][range])
                    current = substr
                }
                if current != "" {          // If all line is same type, append everything at the end
                    values.append(CalcElement(string: current, range: range_2))
                }
                calc = values               // Initial calc is done for this line, yay
            }
            
            messages = []
            
            if calc.count > 0 {
                lines_color.append([])
                doNumber(calc: &calc)
                doDotSeparation(calc: &calc)
                colorInput(calc: &calc, line: l)
                doComments(calc: &calc, line: l)
                doDoubleOperator(calc: &calc)
                removeUseless(calc: &calc)
                doSimplifications(calc: &calc)
            }
            
            if !already {
                if calc.count > 0 {
                    if !isComplex(calc: &calc) {
                        doUnits(calc: &calc)
                        if !doFunctionsDeclaration(calc: &calc, line: l) {
                            doParenthesis(calc: &calc, 0)
                            doVariablesReplacement(calc: &calc, line: l)
                            doFunctionsReplacement(calc: &calc, line: l)
                            doConstants(calc: &calc)
                            doGreekLetters(calc: &calc)
                            doDegRad(calc: &calc)
                            doParenthesis(calc: &calc, 0)
                            doMath(calc: &calc)
                            doConversions(calc: &calc)
                            doUnitsConversions(calc: &calc)
                            doCurrencyConversions(calc: &calc)
                            doVariablesDefinition(calc: &calc, line: l)
                        }
                    } else {
                        if !doFunctionsDeclaration(calc: &calc, line: l) {
                            doConstants(calc: &calc)
                            doComplex(calc: &calc)
                        }
                    }
                    if messages.count == 1 {
                        results[l] = messages[0].content
                    } else if messages.count > 1 {
                        results[l] = "Error"
                    } else {
                        if calc.count == 1 {
                            if calc[0].isComplex {
                                results[l] = calc[0].complex.toString
                            } else {
                                if calc[0].string.isNumber {
                                    results[l] = toSystem(system: calc[0].string.system, result: String(calc[0].string.toNumber))
                                    if calc[0].hasUnit {
                                        results[l] += " "
                                        for (i, u) in calc[0].unit.enumerated() {
                                            if u.factor != 0 {
                                                results[l] += u.prefix.symbol+u.unit.symbol
                                                if u.factor != 1 {
                                                    let factor_string = String(format: "%g", u.factor)
                                                    factors_range[l].append(NSMakeRange(results[l].count, factor_string.count))
                                                    results[l] += factor_string
                                                }
                                                if i < calc[0].unit.count-1 {
                                                    results[l] += "."
                                                }
                                            }
                                        }
                                    }
                                } else {
                                    results[l] = calc[0].string
                                }
                            }
                        } else if calc.count > 0 && calc[0].string.isNumber {
                            results[l] = toSystem(system: calc[0].string.system, result: String(calc[0].string.toNumber))
                            if calc[0].hasUnit {
                                results[l] += " "
                                for (i, u) in calc[0].unit.enumerated() {
                                    if u.factor != 0 {
                                        results[l] += u.prefix.symbol+u.unit.symbol
                                        if u.factor != 1 {
                                            let factor_string = String(format: "%g", u.factor)
                                            factors_range[l].append(NSMakeRange(results[l].count, factor_string.count))
                                            results[l] += factor_string
                                        }
                                        if i < calc[0].unit.count-1 {
                                            results[l] += "."
                                        }
                                    }
                                }
                            }
                        } else {
                            results[l] = ""
                        }
                    }
                } else {
                    results[l] = ""
                }
            }
            //line_index += lines[l].count+1
        }
        
        InputField.textStorage!.removeAttribute(NSAttributedString.Key.foregroundColor, range: NSMakeRange(0, str.count))
        InputField.textColor = .white

        for l in lines_color {
            for j in l {
                InputField.textStorage!.addAttribute(NSAttributedString.Key.foregroundColor, value: j.color, range: j.range)
            }
        }
        self.viewDidLayout()
    }
    
    func colorInput(calc: inout [CalcElement], line: Int) {
        for (i, e) in calc.enumerated() {
            var calc2 = calc
            var ucalc = findUnit(calc: &calc2, start: i)
            if functions.contains(where: {$0 == e.string}) {
                lines_color[line].append(ColorElement(color: NSColor.fromHex(hex: 0xD22B2B, alpha: 1.0), range: e.range))
            }
            if constants.contains(where: {$0 == e.string}) {
                lines_color[line].append(ColorElement(color: NSColor.fromHex(hex: 0x6B8187, alpha: 1.0), range: e.range))
            }
            if funcs.contains(where: {$0.name == e.string}) {
                lines_color[line].append(ColorElement(color: NSColor.fromHex(hex: 0xFFA500, alpha: 1.0), range: e.range))
            }
            if variables.contains(where: {$0.name == e.string}) {
                lines_color[line].append(ColorElement(color: NSColor.fromHex(hex: 0x00FDF1, alpha: 1.0), range: e.range))
            }
            if i > 0 && i < calc.count-1 && (calc[i].string == "to" || calc[i].string == "in") && calc[i-1].string.isNumber &&
                (calc[i+1].string == "bin" || calc[i+1].string == "hex" || calc[i+1].string == "dec") {
                lines_color[line].append(ColorElement(color: NSColor.fromHex(hex: 0x44A6C6, alpha: 1.0), range: e.range))
            }
            if e.string == "i" {
                lines_color[line].append(ColorElement(color: NSColor.fromHex(hex: 0xEB34D8, alpha: 1.0), range: e.range))
            }
            if ucalc.hasUnit {
                if !(i > 0 && i < calc.count-1 &&
                     findUnit(calc: &calc2, start: i-1).hasUnit &&
                     findUnit(calc: &calc2, start: i+1).hasUnit &&
                     ucalc.unit.count == 1 && ucalc.unit[0].unit.name == "inch") {
                    ucalc.range.location = e.range.location
                    lines_color[line].append(ColorElement(color: NSColor.fromHex(hex: 0x00C896, alpha: 1.0), range: ucalc.range))
                } else {
                    ucalc.range.location = e.range.location
                    lines_color[line].append(ColorElement(color: NSColor.fromHex(hex: 0x44A6C6, alpha: 1.0), range: ucalc.range))
                }
            }
        }
    }
    
    func shouldChange(char: String, type: Int) -> Bool {
        return (char.isDouble && type != 1)
                    || (char.isOperator && (type != 3))
                    || (char == " " && type != 0)
                    || (!char.isDouble && !char.isOperator && char != " " && type != 2)
    }
    
    func doComments(calc: inout [CalcElement], line: Int) {
        var i = 0
        while i < calc.count {
            if calc[i].string.prefix(2) != "//" {
                if let index = calc[i].string.index(of: "//") {
                    let before = String(calc[i].string[..<index])
                    let index2 = calc[i].string.distance(from: calc[i].string.startIndex, to: index)
                    
                    let range2 = NSRange(location: calc[i].range.lowerBound+index2, length: calc[calc.endIndex-1].range.upperBound-(calc[i].range.lowerBound+index2))
                    lines_color[line].append(ColorElement(color: NSColor.green, range: range2))
                    
                    calc[i].string = before
                    calc.removeSubrange((i+1)...)
                }
            } else {
                let range2 = NSRange(location: calc[i].range.lowerBound, length: calc[calc.endIndex-1].range.upperBound-(calc[i].range.lowerBound))
                lines_color[line].append(ColorElement(color: NSColor.green, range: range2))
                calc.removeSubrange(i...)
            }
            i+=1
        }
    }
    
    func doDotSeparation(calc: inout [CalcElement]) {
        var i = 0
        while i<calc.count {
            if calc[i].string.isNumber && calc[i].string.suffix(1) == "." && calc[i].string != "." {
                calc[i].string = String(calc[i].string.prefix(calc[i].string.count-1))
                calc[i].range.length -= 1
                calc.insert(CalcElement(string: ".", range: NSMakeRange(calc[i].range.upperBound, 1)), at: i+1)
                i+=1
            }
            i+=1
        }
    }
    
    func doDoubleOperator(calc: inout [CalcElement]) {
        var i = 0
        while i<calc.count {
            if calc[i].string[0].isOperator {
                if calc[i].string.count > 1 {
                    var pieces: [String] = []
                    var lastString = ""
                    var lastIndex = 0
                    for j in 1...calc[i].string.count-1 {
                        if calc[i].string[j-1] != calc[i].string[j] || calc[i].string[j-1] == "(" || calc[i].string[j-1] == ")" {
                            pieces.append(calc[i].string[lastIndex..<j])
                            lastIndex = j
                        }
                    }
                    if pieces.count > 0 {
                        lastString = calc[i].string[lastIndex..<calc[i].string.length]
                        for piece in pieces {
                            calc[i].string = piece
                            calc[i].range.length = piece.count
                            calc.insert(CalcElement(string: "", range: NSMakeRange(calc[i].range.upperBound, 1)), at: i+1)
                            i+=1
                        }
                        calc[i].string = lastString
                        calc[i].range.length = lastString.count
                    }
                }
            }
            i+=1
        }
    }
    
    func doVariablesDefinition(calc: inout [CalcElement], line: Int) {
        if calc.count >= 3 {
            if calc[1].string == "=" && calc[0].string.isText && calc[2].string.isNumber {
                var first = [calc[0]]
                let ucalc = findUnit(calc: &first, start: 0)
                if Units.contains(where: { $0.symbol == calc[0].string}) || constants.contains(calc[0].string) || funcs.contains(where: { $0.name == calc[0].string}) || (variables.contains(where: { $0.name == calc[0].string}) && variables[variables.firstIndex(where: {$0.name == calc[0].string}) ?? 0].line != line) || ucalc.hasUnit {
                    messages.append(Message(type: 1, line: line, content: "Name already used"))
                } else {
                    if variables.filter({$0.name == calc[0].string}).count == 0 {
                        variables.append(CalcVariable(name: calc[0].string, value: Double(calc[2].string.toNumber), line: line, unit: calc[2].unit))
                        lines_color[line].append(ColorElement(color: NSColor.fromHex(hex: 0x00FDF1, alpha: 1.0), range: calc[0].range))
                    } else {
                        if variables[variables.firstIndex(where: {$0.name == calc[0].string}) ?? 0].line == line {
                            variables[variables.firstIndex(where: {$0.name == calc[0].string}) ?? 0].value = Double(calc[2].string.toNumber)
                            variables[variables.firstIndex(where: {$0.name == calc[0].string}) ?? 0].unit = calc[2].unit
                            lines_color[line].append(ColorElement(color: NSColor.fromHex(hex: 0x00FDF1, alpha: 1.0), range: calc[0].range))
                        }
                    }
                    func_var_defs.append(CalcFunctionsDef(name: calc[0].string, line: line))
                    calc[0] = calc[2]
                    calc.remove(at: 2)
                    calc.remove(at: 1)
                }
            }
        }
    }
    
    func doVariablesReplacement(calc: inout [CalcElement], line: Int) {
        var i = 0
        while i < calc.count {
            for v in variables {
                if calc[i].string == v.name {
                    if !(i < calc.count-1 && calc[i+1].string == "=") {
                        contains_func_var[line] = true
                        calc[i].string = String(v.value)
                        calc[i].unit = v.unit
                    }
                }
            }
            i+=1
        }
    }
    
    func doFunctionsDeclaration(calc: inout [CalcElement], line: Int) -> Bool {
        var r = false
        if calc.count >= 5 {
            if calc[2].string.isText && calc[2].string.count == 1 && calc[0].string.isText /*&& calc[0].string.count == 1*/  && calc[1].string == "(" &&
                calc.count >= 6 && calc[3].string == ")" && calc[4].string.starts(with: "=")  {
                var first = [calc[0]]
                let ucalc = findUnit(calc: &first, start: 0)
                if Units.contains(where: { $0.symbol == calc[0].string}) || constants.contains(calc[0].string) || variables.contains(where: { $0.name == calc[0].string}) || (funcs.contains(where: { $0.name == calc[0].string}) && func_var_defs[func_var_defs.firstIndex(where: {$0.name == calc[0].string }) ?? 0].line != line) || ucalc.hasUnit {
                    messages.append(Message(type: 1, line: line, content: "Name already used"))
                } else {
                    let n = calc[0].string
                    let v = calc[2].string
                
                    let range = calc[0].range
                    
                    calc.remove(at: 4)
                    calc.remove(at: 3)
                    calc.remove(at: 2)
                    calc.remove(at: 1)
                    calc.remove(at: 0)
                    
                    if funcs.filter({$0.name == n}).count == 0 {
                        funcs.append(CalcFunctions(name: n, variable: v, calc: calc))
                        messages.append(Message(type: 0, line: line, content: "Function defined"))
                        lines_color[line].append(ColorElement(color: NSColor.fromHex(hex: 0xFFA500, alpha: 1.0), range: range))
                    } else {
                        /*funcs[funcs.firstIndex(where: {$0.name == n}) ?? 0].variable = v
                        funcs[funcs.firstIndex(where: {$0.name == n}) ?? 0].calc = calc*/
                        if func_var_defs[func_var_defs.firstIndex(where: {$0.name == n}) ?? 0].line == line {
                            funcs[funcs.firstIndex(where: {$0.name == n}) ?? 0].variable = v
                            funcs[funcs.firstIndex(where: {$0.name == n}) ?? 0].calc = calc
                            messages.append(Message(type: 0, line: line, content: "Function defined"))
                        } /*else {
                            messages.append(Message(type: 0, line: line, content: "Function redefined"))
                            lines_color[line].append(ColorElement(color: NSColor.fromHex(hex: 0xFFA500, alpha: 1.0), range: range))
                        }*/
                    }
                    func_var_defs.append(CalcFunctionsDef(name: n, line: line))
                    calc.removeAll()
                    r = true
                }
            }
        }
        return r
    }
    
    func removeUseless(calc: inout [CalcElement]) {
        var lastOpen = -2
        var firstOpen = -2
        var openNext = 1
        var lastClose = -2
        var closeNext = 1
        var i = 0
        while i < calc.count {
            if calc[i].string == "(" {
                if lastOpen == i-1 || ((i > 0 && lastOpen == i-2 && (calc[i-1].string == "ln" || calc[i-1].string == "exp")) && (i < 3 || !(functions.contains(calc[i-3].string)))) {
                    openNext += 1
                } else {
                    openNext = 1
                    firstOpen = -2
                }
                lastOpen = i
                if firstOpen == -2 {
                    firstOpen = i
                }
            } else if calc[i].string == ")" {
                if lastClose == i-1 {
                    closeNext += 1
                } else {
                    closeNext = 1
                }
                lastClose = i
                if closeNext > 1 && openNext > 1 {
                    calc.remove(at: i)
                    var j = firstOpen
                    var f = false
                    while j < lastOpen {
                        if calc[j].string == "(" {
                            if !f {
                                calc.remove(at: j)
                                f = true
                            }
                        }
                        j+=1
                    }
                    openNext -= 1
                    closeNext -= 1
                    lastOpen -= 1
                    lastClose -= 2
                    i-=2
                }
            }
            i+=1
        }
    }
    
    func doFunctionsReplacement(calc: inout[CalcElement], line: Int) {
        var i = 0
        while i < calc.count-1 {
            for f in funcs {
                if calc[i].string == f.name && calc[i+1].string.isNumber {
                    if (i < calc.count-2 && calc[i+2].string != "=") || i >= calc.count-2 {
                        contains_func_var[line] = true
                        var c = f.calc
                        for (j, c_i) in c.enumerated() {
                            if c_i.string == f.variable {
                                c[j] = calc[i+1]
                            }
                        }
                        if(!isComplex(calc: &c)) {
                            doConstants(calc: &c)
                            doParenthesis(calc: &c, 0)
                            doMath(calc: &c)
                        } else {
                            doConstants(calc: &c)
                            doParenthesis(calc: &c, 0)
                            doComplex(calc: &c)
                        }
                        if c.count == 1 {
                            calc[i] = c[0]
                            calc.remove(at: i+1)
                        }
                    }
                }
            }
            i+=1
        }
    }
    
    func doConstants(calc: inout [CalcElement]) {
        var i = 0
        while i < calc.count {
            if calc[i].string == "pi" {
                calc[i].string = String(Double.pi)
            } else if calc[i].string == "c" {
                calc[i].string = String(299792458)
            } else if calc[i].string == "h" {
                calc[i].string = String(6.62607015e-34)
            } else if calc[i].string == "Na" {
                calc[i].string = String(6.02214076e23)
            }
            i+=1
        }
    }
    
    func doGreekLetters(calc: inout [CalcElement]) {
        var i = 0
        while i < calc.count {
            if calc[i].string == "\\alpha" {
                calc[i].string = "α"
            } else if calc[i].string == "\\beta" {
                calc[i].string = "β"
            } else if calc[i].string == "\\gamma" {
                calc[i].string = "γ"
            } else if calc[i].string == "\\delta" {
                calc[i].string = "δ"
            } else if calc[i].string == "\\epsilon" {
                calc[i].string = "ε"
            }
            i+=1
        }
    }
    
    func doAngles(calc: inout [CalcElement]) {
        var i = 1
        while i < calc.count {
            if calc[i-1].string.isNumber {
                if calc[i].string == "rad" {
                    calc.remove(at: i)
                } else if calc[i].string == "deg" || calc[i].string == "°" {
                    calc[i-1].string = String(Double(calc[i-1].string.toNumber)*Double.pi/180)
                    calc.remove(at: i)
                }
            }
            i+=1
        }
    }
    
    func doCurrencyConversions(calc: inout [CalcElement]) {
        var i = 2
        while i < calc.count {
            if i < calc.count-1 && (calc[i].string == "in" || calc[i].string == "to") && calc[i-2].string.isNumber {
                let value = calc[i-2].string
                let valuedouble = Double(value.toNumber)
                var result = ""
                let currencies = getCSVData("currencies.csv")
                if currencies.contains(String.SubSequence(calc[i-1].string)) && currencies.contains(String.SubSequence(calc[i+1].string)) {
                    let urlSession = URLSession(configuration: .ephemeral)
                    let url = URL(string: "https://api.frankfurter.app/latest?from="+calc[i-1].string+"&to="+calc[i+1].string)!
                    let task = urlSession.synchronousDataTask(with: url)
                    do {
                        if let json = try JSONSerialization.jsonObject(with: task.0!, options: []) as? [String: Any] {
                            let rates = json["rates"] as! Dictionary<String, Double>
                            let rate = rates[calc[i+1].string]!
                            result = toSystem(system: value.system,
                                                   result: String(valuedouble*rate))+" "+calc[i+1].string
                        }
                    } catch let error as NSError {
                        print("Failed to load: \(error.localizedDescription)")
                    }
                }
                calc[i].string = result
                calc.remove(at: i+1)
                calc.remove(at: i-2)
                calc.remove(at: i-2)
                i-=2
            }
            i+=1
        }
    }
    
    func getCSVData(_ filename: String) -> [String.SubSequence] {
        let lines: [String.SubSequence]
        let path = Bundle.main.path(forResource: "currencies", ofType: "csv")!
        do {
            let contents = try String(contentsOfFile: path)
            lines = contents.split(separator:"\r\n")
        } catch {
            return []
        }
        return lines
    }
    
    func textDidBeginEditing(_ notification: Notification) {
        document?.objectDidBeginEditing(self)
    }

    func textDidEndEditing(_ notification: Notification) {
        document?.objectDidEndEditing(self)
    }
}

func isKeyPresentInUserDefaults(key: String) -> Bool {
    return UserDefaults.standard.object(forKey: key) != nil
}

func buildImportOpenPanel() -> NSOpenPanel {
    let openPanel = NSOpenPanel()
    openPanel.prompt = "Import"
    return openPanel
}
