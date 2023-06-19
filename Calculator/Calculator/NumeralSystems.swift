//
//  NumeralSystems.swift
//  Calculator
//
//  Created by Cyprien Heusse on 24/09/2021.
//

import Foundation


/// Convert number from binary or hex to decimal
/// - Parameter calc: calc array
func doNumber(calc: inout [CalcElement]) {
    var i = 0
    while i < calc.count {
        if i > 0 && i < calc.count {
            if calc[i-1].string == "0" {
                if i<calc.count-1 && calc[i].string == "b" {
                    if calc[i+1].string.isBin {
                        calc[i].string += calc[i+1].string
                        let ret = logicStringToInt(calc[i+1].string, representation: Constants.BIN)
                        if(ret.1 == 0) {
                            // number valid
                            calc[i].isInteger = true
                            calc[i].representation = Constants.BIN
                            calc[i].integer = ret.0
                            calc[i].range.location -= 1
                            calc[i].range.length = calc[i].string.count
                            calc.remove(at: i+1)
                            calc.remove(at: i-1)
                            i-=1
                        } else {
                            setError(calc: &calc, error: ret.1)
                        }
                    }
                    
                } else if calc[i].string.starts(with: "x") && String(calc[i].string.suffix(calc[i].string.count-1)).isHex {
                    let j = i+1
                    while j<calc.count && calc[j].string.isHex {
                        calc[i].string += calc[j].string
                        calc.remove(at: j)
                    }
                    let str = String(calc[i].string.suffix(calc[i].string.count-1))
                    if(str.isHex) {
                        let ret = logicStringToInt(str, representation: Constants.HEX)
                        if(ret.1 == 0) {
                            // number valid
                            calc[i].string = "0"+calc[i].string
                            calc[i].isInteger = true
                            calc[i].representation = Constants.HEX
                            calc[i].integer = ret.0
                            calc[i].range.location -= 1
                            calc[i].range.length = calc[i].string.count
                            calc.remove(at: i-1)
                            i-=1
                        }  else {
                            setError(calc: &calc, error: ret.1)
                        }
                    }
                }
            }
        }
        i+=1
    }
    i = 0
    while i < calc.count {
        if !calc[i].hasValue {
            if calc[i].string.isInteger {
                calc[i].isInteger = true
                calc[i].integer = Int(calc[i].string) ?? 0
            } else if calc[i].string.isDouble {
                var input = calc[i].string.replacingOccurrences(of: " ", with: "", options: NSString.CompareOptions.literal, range: nil)
                input = input.replacingOccurrences(of: ",", with: ".", options: NSString.CompareOptions.literal, range: nil)
                calc[i].isReal = true
                calc[i].real = Double(input) ?? 0.0
            }
        }
        i+=1
    }
    removeAllSpaces(calc: &calc)
}

/// Convert number from a numeral system to another
/// - Parameter calc: calc array
func doConversions(calc: inout [CalcElement]) {
    var i = 0
    while i < calc.count {
        if i > 0 && i < calc.count-1 && (calc[i].string == "in" || calc[i].string == "to") {
            if calc[i-1].isInteger {
                if calc[i+1].string == "dec" || calc[i+1].string == "bin" || calc[i+1].string == "hex" {
                    switch calc[i+1].string {
                        case "dec":
                            calc[i-1].representation = Constants.DEC
                        case "hex":
                            calc[i-1].representation = Constants.HEX
                        case "bin":
                            calc[i-1].representation = Constants.BIN
                        default:
                            break;
                    }
                    calc.remove(at: i+1)
                    calc.remove(at: i)
                }
            }
        }
        i+=1
    }
}

func doScientificNotation(calc: inout [CalcElement]) {
    var i = 1
    while i < calc.count-1 {
        if calc[i].string == "e" && calc[i-1].string.isDouble {
            if calc[i+1].string.isInteger {
                calc[i].string = String(Double(calc[i-1].string.toNumber)*pow(10.0, Double(calc[i+1].string.toNumber)))
                calc.remove(at: i+1)
                calc.remove(at: i-1)
                i-=1
            } else if i < calc.count-2 && calc[i+1].string == "-" && calc[i+2].string.isInteger {
                calc[i].string = String(Double(calc[i-1].string.toNumber)*pow(10.0, -Double(calc[i+2].string.toNumber)))
                calc.remove(at: i+2)
                calc.remove(at: i+1)
                calc.remove(at: i-1)
                i-=1
            }
        }
        i+=1
    }
}

func removeAllSpaces(calc: inout [CalcElement]) {
    var i = 0
    while i < calc.count {
        if calc[i].string == " " {
            calc.remove(at: i)
        } else {
            i += 1
        }
    }
}

func calcPrint(_ calc: [CalcElement]) {
    print("[")
    for e in calc {
        if e.isInteger {
            print("  Int      - "+String(e.integer)+" - ")
        } else if e.isReal {
            print("  Real     - "+String(e.real)+" - "+e.string)
        } else if e.isComplex {
            print("  Complex  - "+String(e.complex.imaginary)+"i+"+String(e.complex.real)+" - "+e.string)
        } else {
            print("  Operator - "+e.string)
        }
    }
    print("]")
}

func hexToBin(_ str: String) -> String {
    var result: String = ""
    for char in str {
        switch char {
        case "0":
            result += "0000"
        case "1":
            result += "0001"
        case "2":
            result += "0010"
        case "3":
            result += "0011"
        case "4":
            result += "0100"
        case "5":
            result += "0101"
        case "6":
            result += "0110"
        case "7":
            result += "0111"
        case "8":
            result += "1000"
        case "9":
            result += "1001"
        case "a":
            result += "1010"
        case "b":
            result += "1011"
        case "c":
            result += "1100"
        case "d":
            result += "1101"
        case "e":
            result += "1110"
        case "f":
            result += "1111"
        default:
            return ""
        }
    }
    return result
}

func logicStringToInt(_ str: String, representation: Int) -> (Int, Int) {
    let bits = AppVariables.bits;
    var bin: String
    // HEX & BIN to BIN
    if(representation == Constants.HEX) {
        bin = hexToBin(str)
    } else if(representation == Constants.BIN) {
        bin = str
    } else {
        return (0, Constants.LOGIC_ERROR)
    }
    bin = bin.replacingOccurrences(of: "^0+", with: "", options: .regularExpression)    // Remove leading zeros
    if(bin.count <= bits) {
        if(AppVariables.signed) {
            if(bin.count == bits && bin[0] == "1") {
                // negative
                var inv: String = ""
                for bit in bin {
                    inv += (bit == "0") ? "1" : "0"
                }
                let val = -((Int(inv, radix: 2) ?? 0)+1)
                return (val, 0)
            }
        }
        // positive/unsigned
        let val = Int(bin, radix: 2) ?? 0
        return (val, 0)
    }
    return (0, Constants.OUT_BOUNDS_ERROR)
}
