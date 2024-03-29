//
//  ViewController.swift
//  Calculator
//
//  Created by Cyprien Heusse on 09/09/2021.
//

// TODO: parenthesis in units :(
// TODO: $money for $ as well as money$
// TODO: save results other than string to be able to use results on other lines (#2 for result[2], #-1 or #+1 for result[i+/-1])

import Cocoa
import Numerics

struct CalcVariable {
    let name: String
    var value: CalcElement
    let line: Int
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
    static var bits = 16
    static var separator = 0
    static var signed: Bool = false
}

struct Constants {
    static let COMMA = 1
    static let DOT = 0
    
    static let DEC = 1
    static let BIN = 2
    static let HEX = 3
    
    static let NO_ERROR = 0
    static let LOGIC_ERROR = 1
    static let MATH_ERROR = 2
    static let CONVERSION_ERROR = 3
    static let NAME_ERROR = 4
    static let FUNCTION_DEFINED = 5
    static let BINARY_OVERFLOW_ERROR = 6
    static let REPRESENTATION_ERROR = 7
    static let DIVIDE_ZERO_ERROR = 8
    static let UNIT_ERROR = 9
    static let TOO_BIG_ERROR = 10
    static let OUT_BOUNDS_ERROR = 11
    static let DEFINITION_ERROR = 12
    static let API_ERROR = 13
    static let NO_VALUE_PASSED = 14
}

struct ExchangeRates {
    static var rates: [ExchangeRate] = []
    static var date: Date = Date.distantPast
    static var error: Int = 0
}

struct ExchangeRate : Codable {
    var fullName: String = ""
    var iso: String = ""
    var symbol: String = ""
    var value: Double  = 0
}

struct CalcElement {
    var string: String
    var unit: [Unit] = []
    var isComplex: Bool = false
    var complex: Complex<Double> = Complex(0, 0)
    var isReal: Bool = false
    var real: Double = 0.0
    var isInteger: Bool = false
    var integer: Int = 0
    var representation: Int = 1
    var range: NSRange
    var error: Int = 0  // No error by default
    var printString: Bool = false
}

struct ColorElement {
    var color: NSColor
    var range: NSRange
}

class ViewController: NSViewController, NSTextViewDelegate {
    let functions = ["e", "exp", "sqrt", "root", "ln", "sinh", "cosh", "tanh", "asinh", "acosh", "atanh", "sin", "cos", "tan", "asin", "acos", "atan", "log", "round", "ceil", "floor", "abs", "arg"]
    let constants_list = ["pi", "c", "h", "Na"]
    let fontAttributes = [NSAttributedString.Key.font: NSFont(name: "Fira Code", size: 13.0)!]
    let greenColor = NSColor(red: 10/255, green: 190/255, blue: 50/255, alpha: 1)
    var lines: [String] = []                        // Contains the text of each line, raw
    var lines_color: [[ColorElement]] = []          // Coloring information for the line, to make it look pretty
    var prev_lines: [String] = []                   // Contains the test of each line, before the new modification, for comparison
    var prev_results: [String] = []                 // Contains the results of the last modification, if prev_lines[i] == lines[i] then results[i] = prev_results[i] i guess
    var results: [String] = []                      // Results of the calculation of each line -> probably should be more than just a string ?
    var variables: [CalcVariable] = []              // List of user defined variables; a=2
    var funcs: [CalcFunctions] = []                 // List of user defined functions; f(x)=4x
    var contains_func_var: [Bool] = []              // If line i contains function OR VARIABLE
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
        AppVariables.signed = defaults.bool(forKey: "Signed")
        ExchangeRates.rates = loadRates()
        ExchangeRates.date = defaults.object(forKey: "RatesDate") as? Date ?? Date.distantPast
        ExchangeRates.error = defaults.integer(forKey: "RatesError")
        if isKeyPresentInUserDefaults(key: "Digits") {
            AppVariables.digits = defaults.integer(forKey: "Digits")
        }
        if isKeyPresentInUserDefaults(key: "Bits") {
            AppVariables.bits = defaults.integer(forKey: "Bits")
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

        var line_index = 0
        
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
            
            if lines[l].count > 0 {                 // If line isn't empty
                calc = parseLine(lines[l], line_index)
            }
            
            if calc.count > 0 {                     // Coloring needs to be done every time (maybe the others don't tho?)
                lines_color.append([])
                doNumber(calc: &calc)
                doDotSeparation(calc: &calc)
                colorInput(calc: &calc, line: l)
                doComments(calc: &calc, line: l)
                doAnswers(calc: &calc, line: l)
                doDoubleOperator(calc: &calc)
                doPowerSeparation(calc: &calc)
                removeUseless(calc: &calc)
                doSettings(calc: &calc)
                doSimplifications(calc: &calc)
            }
            
            if !already {
                if calc.count > 0 {
                    if !isComplex(calc: &calc) {            // Do the actual math
                        doUnits(calc: &calc)
                        if !doFunctionsDeclaration(calc: &calc, line: l) {
                            doParenthesis(calc: &calc)
                            doVariablesReplacement(calc: &calc, line: l)
                            doFunctionsReplacement(calc: &calc, line: l)
                            doConstants(calc: &calc)
                            doUnits(calc: &calc)
                            doUnitsConversions(calc: &calc)
                            doParenthesis(calc: &calc)
                            doMath(calc: &calc)
                            doLogic(calc: &calc)
                            doConversions(calc: &calc)
                            doCurrencyConversions(calc: &calc)
                            doVariablesDefinition(calc: &calc, line: l)
                        }
                    } else {                                // Do Complex math (not quite the same)
                        if !doFunctionsDeclaration(calc: &calc, line: l) {
                            doConstants(calc: &calc)
                            doComplex(calc: &calc)
                        }
                    }
                    results[l] = getResult(calc: &calc, line: l)
                    if calc[0].error != Constants.NO_ERROR {
                        results[l] = getErrorMessage(calc[0].error)
                    }
                } else {
                    results[l] = ""
                }
            }
            line_index += lines[l].count+1
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
    
    
    /// Color the input line (function, units, ...) by filling an array of ranges and colors we will later apply to the TextArea
    /// - Parameters:
    ///   - calc: calc array
    ///   - line: current line
    func colorInput(calc: inout [CalcElement], line: Int) {
        for (i, e) in calc.enumerated() {
            var calc2 = calc
            var ucalc = findUnit(calc: &calc2, start: i)
            if functions.contains(where: {$0 == e.string}) {
                lines_color[line].append(ColorElement(color: NSColor.fromHex(hex: 0xD22B2B, alpha: 1.0), range: e.range))
            }
            if constants_list.contains(where: {$0 == e.string}) {
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
    
    
    /// Generates the result string or the error after all the operations have been tried
    /// - Parameters:
    ///   - calc: calc array
    ///   - line: current line
    /// - Returns: result string
    func getResult(calc: inout [CalcElement], line:  Int) -> String {
        var final = ""
        if calc.count == 1 {
            let e = calc[0]
            if e.isInteger {
                if e.representation == Constants.DEC {
                    final = String(e.integer) // TODO: better
                } else {
                    let p2n = Int(pow(2.0, Double(AppVariables.bits)))   // 2**(MAX_BITS)
                    if(!AppVariables.signed && (e.integer < 0 || e.integer >= p2n)) || (AppVariables.signed && (e.integer < -p2n/2 || e.integer >= p2n/2)) {
                        setError(calc: &calc, error: Constants.OUT_BOUNDS_ERROR)
                        return "";
                    }
                    if(AppVariables.signed && e.integer < 0) {
                        if e.representation == Constants.BIN {
                            final = "0b"+String(p2n + e.integer, radix: 2)
                        } else if e.representation == Constants.HEX {
                            final = "0x"+String(p2n + e.integer, radix: 16)
                        }
                    } else {
                        if e.representation == Constants.BIN {
                            final = "0b"+String(e.integer, radix: 2)
                        } else if e.representation == Constants.HEX {
                            final = "0x"+String(e.integer, radix: 16)
                        }
                    }
                }
            } else if e.isReal {
                if e.representation == Constants.DEC {
                    final = e.real.scientificFormatted
                    if e.printString {
                        final += " " + e.string
                    }
                } else {
                    setError(calc: &calc, error: Constants.REPRESENTATION_ERROR)
                    return ""
                }
            } else if e.isComplex {
               final = e.complex.toString
            }
            
            if e.hasUnit {
                final += " "
                for (i, u) in e.unit.enumerated() {
                    if u.factor != 0 {
                        final += u.prefix.symbol+u.unit.symbol
                        if u.factor != 1 {
                            let factor_string = String(format: "%g", u.factor)
                            factors_range[line].append(NSMakeRange(final.count, factor_string.count))
                            final += factor_string
                        }
                        if i < calc[0].unit.count-1 {
                            final += "."
                        }
                    }
                }
            }
            
        } else {
            return ""
        }
        return final
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
    
    
    func doAnswers(calc: inout[CalcElement], line: Int) {
        var i = 0;
        while i < calc.count-1 {
            if calc[i].string == "#" && calc[i+1].isInteger {
                if calc[i+1].integer < results.count && calc[i+1].integer != line {
                    print(results[calc[i+1].integer])
                }
            }
            i += 1
        }
    }
    
    
    /// Let's the user change settings directly from the calculator by writing settings.xxxx=yyyy
    /// - Parameter calc: calc array
    func doSettings(calc: inout[CalcElement]) {
        var i = 4
        while i < calc.count {
            if calc[i-1].string == "=" && calc[i-3].string == "." && calc[i-4].string == "settings" {
                if calc[i-2].string == "bits" && calc[i].isInteger {
                    AppVariables.bits = calc[i].integer
                } else if calc[i-2].string == "signed" && calc[i].string.isBool {
                    AppVariables.signed = calc[i].string.toBool
                } else if calc[i-2].string == "digits" && calc[i].isInteger {
                    AppVariables.digits = calc[i].integer
                } else if calc[i-2].string == "separator" && calc[i].string == "comma" {
                    AppVariables.separator = Constants.COMMA
                } else if calc[i-2].string == "separator" && calc[i].string == "dot" {
                    AppVariables.separator = Constants.DOT
                }
                prev_lines = []     // effectively refresh all calcs
            }
            i += 1
        }
    }
    
    // FIXME: why do this exist ?
    func doDotSeparation(calc: inout [CalcElement]) {
        var i = 0
        while i<calc.count {
            if calc[i].hasValue && calc[i].string.suffix(1) == "." && calc[i].string != "." {
                calc[i].string = String(calc[i].string.prefix(calc[i].string.count-1))
                calc[i].range.length -= 1
                calc.insert(CalcElement(string: ".", range: NSMakeRange(calc[i].range.upperBound, 1)), at: i+1)
                i+=1
            }
            i+=1
        }
    }
    
    // FIXME: what's that ?
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
        if calc.count >= 2 {
            if calc[1].string == "=" && calc[0].string.isText {
                if calc.count == 3 && calc[2].hasValue {
                    var first = [calc[0]]
                    let ucalc = findUnit(calc: &first, start: 0)
                    if Units.contains(where: { $0.symbol == calc[0].string}) || constants_list.contains(calc[0].string) || funcs.contains(where: { $0.name == calc[0].string}) || (variables.contains(where: { $0.name == calc[0].string}) && variables[variables.firstIndex(where: {$0.name == calc[0].string}) ?? 0].line != line) || ucalc.hasUnit {
                        setError(calc: &calc, error: Constants.NAME_ERROR)
                        return
                    } else {
                        if variables.filter({$0.name == calc[0].string}).count == 0 {
                            variables.append(CalcVariable(name: calc[0].string, value: calc[2], line: line))
                            lines_color[line].append(ColorElement(color: NSColor.fromHex(hex: 0x00FDF1, alpha: 1.0), range: calc[0].range))
                        } else {
                            if variables[variables.firstIndex(where: {$0.name == calc[0].string}) ?? 0].line == line {
                                variables[variables.firstIndex(where: {$0.name == calc[0].string}) ?? 0].value = calc[2]
                                lines_color[line].append(ColorElement(color: NSColor.fromHex(hex: 0x00FDF1, alpha: 1.0), range: calc[0].range))
                            }
                        }
                        func_var_defs.append(CalcFunctionsDef(name: calc[0].string, line: line))
                        calc[0] = calc[2]
                        calc.remove(at: 2)
                        calc.remove(at: 1)
                    }
                } else {
                    setError(calc: &calc, error: Constants.DEFINITION_ERROR)
                    return
                }
            }
        }
    }
    
    func doVariablesReplacement(calc: inout [CalcElement], line: Int) {
        var i = 0
        while i < calc.count {
            for v in variables {
                if calc[i].string == v.name {
                    if calc.count >= 2 && calc[0].string == v.name && calc[1].string == "=" && i != 0 {
                        setError(calc: &calc, error: Constants.DEFINITION_ERROR)
                        return
                    } else if !(i < calc.count-1 && calc[i+1].string == "=") {
                        contains_func_var[line] = true
                        calc[i] =  v.value
                        calc[i].string = ""
                    }
                }
            }
            i+=1
        }
    }
    
    func doFunctionsDeclaration(calc: inout [CalcElement], line: Int) -> Bool {
        if calc.count >= 5 {
            if calc[2].string.isText && calc[2].string.count == 1 && calc[0].string.isText /*&& calc[0].string.count == 1*/  && calc[1].string == "(" &&
                calc.count >= 6 && calc[3].string == ")" && calc[4].string.starts(with: "=")  {
                var first = [calc[0]]
                let ucalc = findUnit(calc: &first, start: 0)
                if Units.contains(where: { $0.symbol == calc[0].string}) || constants_list.contains(calc[0].string) || variables.contains(where: { $0.name == calc[0].string}) || (funcs.contains(where: { $0.name == calc[0].string}) && func_var_defs[func_var_defs.firstIndex(where: {$0.name == calc[0].string }) ?? 0].line != line) || ucalc.hasUnit {
                    setError(calc: &calc, error: Constants.NAME_ERROR)
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
                        lines_color[line].append(ColorElement(color: NSColor.fromHex(hex: 0xFFA500, alpha: 1.0), range: range))
                        setError(calc: &calc, error: Constants.FUNCTION_DEFINED)
                    } else {
                        if func_var_defs[func_var_defs.firstIndex(where: {$0.name == n}) ?? 0].line == line {
                            funcs[funcs.firstIndex(where: {$0.name == n}) ?? 0].variable = v
                            funcs[funcs.firstIndex(where: {$0.name == n}) ?? 0].calc = calc
                            setError(calc: &calc, error: Constants.FUNCTION_DEFINED)
                        }
                    }
                    func_var_defs.append(CalcFunctionsDef(name: n, line: line))
                    return true
                }
            }
        }
        return false
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
                            doParenthesis(calc: &c)
                            doMath(calc: &c)
                        } else {
                            doConstants(calc: &c)
                            doParenthesis(calc: &c)
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
    
    /// Removes all useless parenthesis between an exp and a ln to be able to cancel them out later on
    /// - Parameter calc: calc array
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
    
    func doConstants(calc: inout [CalcElement]) {
        var i = 0
        while i < calc.count {
            if calc[i].string == "pi" {
                calc[i].real = Double.pi
                calc[i].isReal = true
            } else if calc[i].string == "c" {
                calc[i].integer = 299792458
                calc[i].isInteger = true
            } else if calc[i].string == "h" {
                calc[i].real = 6.62607015e-34
                calc[i].isReal = true
            } else if calc[i].string == "Na" {
                calc[i].real = 6.02214076e23
                calc[i].isReal = true
            } else if calc[i].string == "e" {
                calc[i].real = Double.exp(1)
                calc[i].isReal = true
            }
            i+=1
        }
    }
    
    /// Based on the IMF's daily exchange rates, might be last day's data depending on the time
    /// - Parameter calc: as always
    func doCurrencyConversions(calc: inout [CalcElement]) {
        var i = 2
        while i < calc.count-1 {
            if (calc[i].string == "in" || calc[i].string == "to") && calc[i-2].hasValue && calc[i-1].string != "" && calc[i+1].string != "" {
                let currencies = getCSVData("currencies.csv")
                if let from = ExchangeRates.rates.first(where: { $0.iso == calc[i-1].string || $0.symbol == calc[i-1].string }), let to = ExchangeRates.rates.first(where: { $0.iso == calc[i+1].string || $0.symbol == calc[i+1].string }) {
                    
                    calc[i-2].toDouble()
                    calc[i-2].real *= to.value/from.value
                    
                    calc.remove(at: i+1)
                    calc.remove(at: i)
                    calc.remove(at: i-1)
                    i-=1
                } else if currencies.contains(where: { $0[1] == calc[i-1].string || $0[2] == calc[i-1].string })
                          && currencies.contains(where: { $0[1] == calc[i+1].string || $0[2] == calc[i+1].string }){
                    setError(calc: &calc, error: Constants.API_ERROR)
                    break
                }
            }
            i+=1
        }
        
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

func setError(calc: inout [CalcElement], error: Int) {
    calc = [CalcElement(string: "", range: NSMakeRange(0, 0), error: error)]
}

func getErrorMessage(_ error: Int) -> String {
    switch error {
        case Constants.NAME_ERROR:
            return "Name already used!"
        case Constants.FUNCTION_DEFINED:
            return "Function defined!"
        case Constants.BINARY_OVERFLOW_ERROR:
            return "Number too big!"
        case Constants.REPRESENTATION_ERROR:
            return "Number can't be represented!"
        case Constants.DIVIDE_ZERO_ERROR:
            return "Can't divide by 0!"
        case Constants.CONVERSION_ERROR:
            return "Conversion error!"
        case Constants.TOO_BIG_ERROR:
            return "Number too big!"
        case Constants.UNIT_ERROR:
            return "The units do not match!"
        case Constants.OUT_BOUNDS_ERROR:
            return "Logic number out of bounds!"
        case Constants.DEFINITION_ERROR:
            return "Definition error!"
        case Constants.API_ERROR:
            return "API error!"
        case Constants.NO_VALUE_PASSED:
            return "No value passed to function!"
        default:
            return "Error!"
    }
}
