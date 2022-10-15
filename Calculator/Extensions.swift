//
//  Extensions.swift
//  Calculator
//
//  Created by Cyprien Heusse on 24/09/2021.
//

import Foundation
import Numerics
import Cocoa

extension String {
    var isInteger: Bool { return Int(self) != nil }
    var isFloat: Bool { return Float(self) != nil }
    var isDouble: Bool {
        let input = self.replacingOccurrences(of: ",", with: ".", options: NSString.CompareOptions.literal, range: nil)
        return Double(input) != nil || self == "." || self == ","
    }
    var isNumber: Bool {
        let input = self.replacingOccurrences(of: " ", with: "", options: NSString.CompareOptions.literal, range: nil)
        return (input != ".") && (input.isDouble || input.prefix(2) == "0x" || input.prefix(2) == "0b")
    }
    var isHex: Bool { return filter(\.isHexDigit).count == count }
    var isOperator: Bool { return self == "*" || self == "/" || self == "+" || self == "-" || self == "^" || self == "(" || self == ")" || self == "=" || self == ">" || self == "<" || self == "%" || self == "|" }
    var isText: Bool { return !self.isNumber && !self.isOperator && self != " " && self != "i" && self != "|" }
    var isBin: Bool {
        guard self.count > 0 else { return false }
        let nums: Set<Character> = ["0", "1"]
        return Set(self).isSubset(of: nums)
    }
    var system: Int {
        if self.prefix(2) == "0b" { return 1 } //Binary
        else if self.prefix(2) == "0x" { return 2 } //Hexa
        else { return 0 } //Decimal
    }
    var toNumber: Double {
        var input = self.replacingOccurrences(of: " ", with: "", options: NSString.CompareOptions.literal, range: nil)
        input = input.replacingOccurrences(of: ",", with: ".", options: NSString.CompareOptions.literal, range: nil)
        if input.prefix(2) == "0b" { return Double(Int(input.dropFirst(2), radix: 2) ?? 0) }
        else if input.prefix(2) == "0x" { return Double(Int(input.dropFirst(2), radix: 16) ?? 0) }
        else { return Double(input) ?? 0 }
    }
    mutating func removeFirstChar(char: String) {
        for (i, c) in self.enumerated() {
            if String(c) == char {
                let index = self.index(self.startIndex, offsetBy: i, limitedBy: self.endIndex)!
                self.remove(at: index)
                break
            }
        }
    }
}

extension StringProtocol {
    func index<S: StringProtocol>(of string: S, options: String.CompareOptions = []) -> Index? {
        range(of: string, options: options)?.lowerBound
    }
    func endIndex<S: StringProtocol>(of string: S, options: String.CompareOptions = []) -> Index? {
        range(of: string, options: options)?.upperBound
    }
    func indices<S: StringProtocol>(of string: S, options: String.CompareOptions = []) -> [Index] {
        ranges(of: string, options: options).map(\.lowerBound)
    }
    func ranges<S: StringProtocol>(of string: S, options: String.CompareOptions = []) -> [Range<Index>] {
        var result: [Range<Index>] = []
        var startIndex = self.startIndex
        while startIndex < endIndex,
            let range = self[startIndex...]
                .range(of: string, options: options) {
                result.append(range)
                startIndex = range.lowerBound < range.upperBound ? range.upperBound :
                    index(range.lowerBound, offsetBy: 1, limitedBy: endIndex) ?? endIndex
        }
        return result
    }
}

extension URLSession {
    func synchronousDataTask(with url: URL) -> (Data?, URLResponse?, Error?) {
        var data: Data?
        var response: URLResponse?
        var error: Error?

        let semaphore = DispatchSemaphore(value: 0)

        let dataTask = self.dataTask(with: url) {
            data = $0
            response = $1
            error = $2

            semaphore.signal()
        }
        dataTask.resume()

        _ = semaphore.wait(timeout: .distantFuture)

        return (data, response, error)
    }
}

extension Complex where RealType == Double {
    var toString: String {
        var str = ""
        let imaginary = smartRounding(self.imaginary)
        let real = smartRounding(self.real)
        if  imaginary != 0 {
            if imaginary != 1 && imaginary != -1 {
                str += imaginary.scientificFormatted+"i"
            } else if imaginary == 1 {
                str += "i"
            } else {
                str += "-i"
            }
            if real > 0 {
                str += "+"
            }
        }
        if real != 0 {
            str += real.scientificFormatted
        }
        if imaginary == 0 && real == 0 {
            str = "0"
        }
        return str
    }
}

extension Formatter {
    static let scientific: NumberFormatter = {
        let formatter = NumberFormatter()
        formatter.numberStyle = .scientific
        formatter.maximumFractionDigits = AppVariables.digits
        formatter.exponentSymbol = "e"
        formatter.decimalSeparator = (AppVariables.separator == 0) ? "." : ","
        return formatter
    }()
    static let withSeparator: NumberFormatter = {
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        formatter.groupingSeparator = " "
        formatter.maximumFractionDigits = AppVariables.digits
        formatter.decimalSeparator = (AppVariables.separator == 0) ? "." : ","
        return formatter
    }()
}

extension Double {
    var scientificFormatted: String {
        if self >= 10000000 || (self > 0 && self <= 0.0001) {
            Formatter.scientific.maximumFractionDigits = AppVariables.digits
            Formatter.scientific.decimalSeparator = (AppVariables.separator == 0) ? "." : ","
            return Formatter.scientific.string(for: self) ?? ""
        } else {
            Formatter.withSeparator.maximumFractionDigits = AppVariables.digits
            Formatter.withSeparator.decimalSeparator = (AppVariables.separator == 0) ? "." : ","
            return Formatter.withSeparator.string(for: self) ?? ""
        }
    }
}

extension CalcElement {
    var hasUnit: Bool { return self.unit.count > 0 }
}

extension NSColor {
    class func fromHex(hex: Int, alpha: Float) -> NSColor {
        let red = CGFloat((hex & 0xFF0000) >> 16) / 255.0
        let green = CGFloat((hex & 0xFF00) >> 8) / 255.0
        let blue = CGFloat((hex & 0xFF)) / 255.0
        return NSColor(calibratedRed: red, green: green, blue: blue, alpha: 1.0)
    }
}

extension String {
    var length: Int {
        return count
    }

    subscript (i: Int) -> String {
        return self[i ..< i + 1]
    }

    func substring(fromIndex: Int) -> String {
        return self[min(fromIndex, length) ..< length]
    }

    func substring(toIndex: Int) -> String {
        return self[0 ..< max(0, toIndex)]
    }

    subscript (r: Range<Int>) -> String {
        let range = Range(uncheckedBounds: (lower: max(0, min(length, r.lowerBound)),
                                            upper: min(length, max(0, r.upperBound))))
        let start = index(startIndex, offsetBy: range.lowerBound)
        let end = index(start, offsetBy: range.upperBound - range.lowerBound)
        return String(self[start ..< end])
    }
}
