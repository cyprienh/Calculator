//
//  LogicCalculator.swift
//  Calculator
//
//  Created by Cyprien Heusse on 16/10/2022.
//

import Foundation
import Cocoa

func doBitShifts(calc: inout [CalcElement]) {
    var i = 1
    while i < calc.count-1 {
        if calc[i].string == ">>" || calc[i].string == "<<" {
            if calc[i-1].string.isNumber && calc[i+1].string.isNumber {
                let left = Int(calc[i-1].string.toNumber)
                let right = Int(calc[i+1].string.toNumber)
                if isValidInteger(left) && isValidInteger(right) {
                    if calc[i].string == ">>" {
                        if isValidInteger(left >> right) {
                            calc[i].string = toSystem(system: calc[i-1].string.system,
                                                      result: String(left >> right))
                        } else {
                            setError(calc: &calc, error: Constants.REPRESENTATION_ERROR)
                            return
                        }
                    } else if calc[i].string == "<<" {
                        if isValidInteger(left << right) {
                            calc[i].string = toSystem(system: calc[i-1].string.system,
                                                      result: String(left << right))
                        } else {
                            setError(calc: &calc, error: Constants.REPRESENTATION_ERROR)
                            return
                        }
                    }
                    calc.remove(at: i+1)
                    calc.remove(at: i-1)
                    i=i-1
                } else {
                    setError(calc: &calc, error: Constants.REPRESENTATION_ERROR)
                    return
                }
            }
        }
        i+=1
    }
}

func doOR(calc: inout [CalcElement]) {
    var i = 1
    while i < calc.count-1 {
        if calc[i].string == "|" || calc[i].string == "||" || calc[i].string.lowercased() == "or" {
            if calc[i-1].string.isNumber && calc[i+1].string.isNumber {
                let left = Int(calc[i-1].string.toNumber)
                let right = Int(calc[i+1].string.toNumber)
                if isValidInteger(left) && isValidInteger(right) {
                    calc[i].string = toSystem(system: calc[i-1].string.system,
                                              result: String(left | right))
                    calc.remove(at: i+1)
                    calc.remove(at: i-1)
                    i=i-1
                } else {
                    setError(calc: &calc, error: Constants.REPRESENTATION_ERROR)
                    return
                }
            }
        }
        i+=1
    }
}

func doAND(calc: inout [CalcElement]) {
    var i = 1
    while i < calc.count-1 {
        if calc[i].string == "&" || calc[i].string == "&&" || calc[i].string.lowercased() == "and" {
            if calc[i-1].string.isNumber && calc[i+1].string.isNumber {
                let left = Int(calc[i-1].string.toNumber)
                let right = Int(calc[i+1].string.toNumber)
                if isValidInteger(left) && isValidInteger(right) {
                    calc[i].string = toSystem(system: calc[i-1].string.system,
                                              result: String(left & right))
                    calc.remove(at: i+1)
                    calc.remove(at: i-1)
                    i=i-1
                } else {
                    setError(calc: &calc, error: Constants.REPRESENTATION_ERROR)
                    return
                }
            }
        }
        i+=1
    }
}

func doXOR(calc: inout [CalcElement]) {
    var i = 1
    while i < calc.count-1 {
        if calc[i].string.lowercased() == "xor" {
            if calc[i-1].string.isNumber && calc[i+1].string.isNumber {
                let left = Int(calc[i-1].string.toNumber)
                let right = Int(calc[i+1].string.toNumber)
                if isValidInteger(left) && isValidInteger(right) {
                    calc[i].string = toSystem(system: calc[i-1].string.system,
                                              result: String(left ^ right))
                    calc.remove(at: i+1)
                    calc.remove(at: i-1)
                    i=i-1
                } else {
                    setError(calc: &calc, error: Constants.REPRESENTATION_ERROR)
                    return
                }
            }
        }
        i+=1
    }
}

func doNOT(calc: inout [CalcElement]) {
    var i = 0
    while i < calc.count-1 {
        if calc[i].string.lowercased() == "not" || calc[i].string == "!" || calc[i].string.lowercased() == "~" {
            if calc[i+1].string.isNumber {
                let right = Int(calc[i+1].string.toNumber)
                if isValidInteger(right) {
                    calc[i].string = toSystem(system: calc[i+1].string.system,
                                              result: String(!right))
                    calc.remove(at: i+1)
                } else {
                    setError(calc: &calc, error: Constants.REPRESENTATION_ERROR)
                    return
                }
            }
        }
        i+=1
    }
}

func isValidInteger(_ x: Int) -> Bool {
    let max = Int(pow(Double(2), Double(AppVariables.bits)))
    return ((AppVariables.representation == Constants.SIGNED && x >= (-max/2) && x < (max/2))
        || (AppVariables.representation == Constants.UNSIGNED && x >= 0 && x < max))
}
