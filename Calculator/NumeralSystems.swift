//
//  NumeralSystems.swift
//  Calculator
//
//  Created by Cyprien Heusse on 24/09/2021.
//

import Foundation

func doNumber(calc: inout [CalcElement]) {
    var i = 0
    while i < calc.count {
        if i > 0 && i < calc.count {
            if calc[i-1].string == "0" {
                if i<calc.count-1 && calc[i].string == "b" {
                    if calc[i+1].string.isBin {
                        calc[i].string += calc[i+1].string
                    } else {
                        var k = 1
                        while String(calc[i+1].string.prefix(k)).isBin {
                            k+=1
                        }
                        calc[i].string += String(calc[i+1].string.prefix(k-1))
                        calc[i+1].string = String(calc[i+1].string.suffix(calc[i+1].string.count-k+1))
                    }
                    calc[i].string = "0"+calc[i].string
                    calc[i].range.location -= 1
                    calc[i].range.length = calc[i].string.count
                    calc.remove(at: i+1)
                    calc.remove(at: i-1)
                    i-=1
                } else if calc[i].string.starts(with: "x") && String(calc[i].string.suffix(calc[i].string.count-1)).isHex {
                    let j = i+1
                    while j<calc.count && calc[j].string.isHex {
                        calc[i].string += calc[j].string
                        calc.remove(at: j)
                    }
                    if j<calc.count {
                        var k = 1
                        while String(calc[j].string.prefix(k)).isHex {
                            k+=1
                        }
                        calc[i].string += String(calc[j].string.prefix(k-1))
                        calc[j].string = String(calc[j].string.suffix(calc[j].string.count-k+1))
                    }
                    calc[i].string = "0"+calc[i].string
                    calc[i].range.location -= 1
                    calc[i].range.length = calc[i].string.count
                    calc.remove(at: i-1)
                    i-=1
                }
            }
        }
        i+=1
    }
    removeAllSpaces(calc: &calc)
}

func doConversions(calc: inout [CalcElement]) {
    var i = 0
    while i < calc.count {
        if i > 0 && i < calc.count-1 && (calc[i].string == "in" || calc[i].string == "to") {
            var result = ""
            var x = Int(calc[i-1].string.toNumber)
            let max = Int(pow(Double(2), Double(AppVariables.bits)))
            if (AppVariables.representation == Constants.SIGNED && x >= (-max/2) && x < (max/2))
                || (AppVariables.representation == Constants.UNSIGNED && x >= 0 && x < max) {
                if AppVariables.representation == Constants.SIGNED && x < 0 {
                    x = max + x
                }
                switch calc[i+1].string {
                case "dec":
                    result = String(Int(calc[i-1].string.toNumber), radix: 10)
                case "hex":
                    result = "0x"+String(x, radix: 16)
                case "bin":
                    result = "0b"+String(x, radix: 2)
                default:
                    result = ""
                }
            }
            
            if result != "" {
                calc[i].string = result
                calc.remove(at: i+1)
                calc.remove(at: i-1)
                i-=1
            } else {
                setError(calc: &calc, error: Constants.REPRESENTATION_ERROR)
                return
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

func toSystem(system: Int, result: String) -> String {
    var final = ""
    switch system {
        case 0: final = result.toNumber.scientificFormatted
        case 1: final = "0b"+String(Int(result.toNumber), radix: 2)
        case 2: final = "0x"+String(Int(result.toNumber), radix: 16)
        default: final = ""
    }
    return final
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
