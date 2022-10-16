//
//  MathCalculator.swift
//  Calculator
//
//  Created by Cyprien Heusse on 24/09/2021.
//

import Foundation
import Cocoa

func doMath(calc: inout [CalcElement]) {
    doFactorial(calc: &calc)
    doFunctions(calc: &calc)
    doScientificNotation(calc: &calc)
    doPower(calc: &calc, 0)
    doNegative(calc: &calc)
    doImplicit(calc: &calc)
    doMultDiv(calc: &calc)
    doPlusMinus(calc: &calc)
    doBitShifts(calc: &calc)
    doNOT(calc: &calc)
    doAND(calc: &calc)
    doOR(calc: &calc)
    doXOR(calc: &calc)
    doDivisionRest(calc: &calc)
}

func doPower(calc: inout [CalcElement], _ start: Int) {
    var i = start+1
    while i < calc.count-1 {
        if calc[i].string == "^" || calc[i].string == "**" {
            if calc[i+1].string.isNumber {
                if i < calc.count-2 && (calc[i+2].string == "^" || calc[i+2].string == "**") {
                    doPower(calc: &calc, i+1)
                }
                let right = Double(calc[i+1].string.toNumber)
                if calc[i-1].string.isNumber {
                    let left = Double(calc[i-1].string.toNumber)
                    calc[i-1].string = toSystem(system: calc[i-1].string.system,
                                              result: String(pow(left, right)))
                    if calc[i-1].hasUnit && calc[i+1].string.isInteger {
                        for u in 0...calc[i-1].unit.count-1 {
                            calc[i-1].unit[u].factor *= right
                        }
                    }
                } else if calc[i-1].string == "e" {
                    calc[i-1].string = toSystem(system: calc[i+1].string.system,
                                              result: String(exp(right)))
                }
                calc.remove(at: i+1)
                calc.remove(at: i)
                i-=1
            }
        }
        i+=1
    }
}

func doNegative(calc: inout [CalcElement]) {
    var i = 0
    while i < calc.count-1 {
        if calc[i].string == "-" && calc[i+1].string.isNumber {
            if i == 0 || !calc[i-1].string.isNumber {
                calc[i+1].string = calc[i].string+calc[i+1].string
                calc.remove(at: i)
                i-=1
            }
        }
        i+=1
    }
}

func doFactorial(calc: inout [CalcElement]) {
    var i = 1
    while i < calc.count {
        if calc[i].string == "!" && calc[i-1].string.isNumber {
            calc[i].string = toSystem(system: calc[i-1].string.system,
                                      result: String(fact(Int(calc[i-1].string.toNumber))))
            calc.remove(at: i-1)
            i-=1
        }
        i+=1
    }
}

func doImplicit(calc: inout [CalcElement]) {
    var i = 0
    while i < calc.count-1 {
        if calc[i].string.isNumber && calc[i+1].string.isNumber {
            let left = Double(calc[i].string.toNumber)
            let right = Double(calc[i+1].string.toNumber)
            calc[i].string = toSystem(system: calc[i].string.system,
                                      result: String(left*right))
            for u in calc[i+1].unit {
                calc[i].unit.append(u)
            }
            arrangeUnits(&calc[i])
            calc.remove(at: i+1)
        }
        i+=1
    }
}

func doMultDiv(calc: inout [CalcElement]) {
    var i = 1
    while i < calc.count-1 {
        if calc[i].string == "*" || calc[i].string == "/" {
            if calc[i-1].string.isNumber && calc[i+1].string.isNumber {
                let left = Double(calc[i-1].string.toNumber)
                let right = Double(calc[i+1].string.toNumber)
                if calc[i].string == "*" {
                    calc[i-1].string = toSystem(system: calc[i-1].string.system,
                                              result: String(left*right))
                    if calc[i+1].hasUnit {
                        for u in calc[i+1].unit {
                            calc[i-1].unit.append(u)
                        }
                    }
                } else if calc[i].string == "/" {
                    calc[i-1].string = toSystem(system: calc[i-1].string.system,
                                              result: String(left/right))
                    if calc[i+1].hasUnit {
                        for u in calc[i+1].unit {
                            calc[i-1].unit.append(Unit(unit: u.unit, prefix: u.prefix, factor: -u.factor))
                        }
                    }
                }
                arrangeUnits(&calc[i-1])
                calc.remove(at: i+1)
                calc.remove(at: i)
                i-=1
            }
        }
        i+=1
    }
}

func doPlusMinus(calc: inout [CalcElement]) {
    var i = 1
    while i < calc.count-1 {
        if calc[i].string == "+" || calc[i].string == "-" {
            if calc[i-1].string.isNumber && calc[i+1].string.isNumber {
                var left = Double(calc[i-1].string.toNumber)
                var right = Double(calc[i+1].string.toNumber)
                if calc[i-1].hasUnit && calc[i+1].hasUnit && sameUnit(calc[i-1], calc[i+1]) {
                    var factor1: Double = 0
                    var factor2: Double = 0
                    for j in 0...calc[i-1].unit.count-1{
                        factor1 += calc[i-1].unit[j].factor * Double(calc[i-1].unit[j].prefix.factor)
                        factor2 += calc[i+1].unit[j].factor * Double(calc[i+1].unit[j].prefix.factor)
                    }
                    if factor2 >= factor1 {
                        right *= pow(10, Double(factor2-factor1))
                    } else {
                        left *= pow(10, Double(factor1-factor2))
                        calc[i-1].unit = calc[i+1].unit
                    }
                } else {
                    calc[i-1].unit = []
                }
                if calc[i].string == "+" {
                    calc[i-1].string = toSystem(system: calc[i-1].string.system,
                                              result: String(left+right))
                } else if calc[i].string == "-" {
                    calc[i-1].string = toSystem(system: calc[i-1].string.system,
                                              result: String(left-right))
                }
                arrangeUnits(&calc[i-1])
                calc.remove(at: i+1)
                calc.remove(at: i)
                i-=1
            }
        }
        i+=1
    }
}

func doDivisionRest(calc: inout [CalcElement]) {
    var i = 1
    while i < calc.count-1 {
        if calc[i].string == "%" {
            if calc[i-1].string.isNumber && calc[i+1].string.isNumber {
                let left = Double(calc[i-1].string.toNumber)
                let right = Double(calc[i+1].string.toNumber)
                
                if calc[i-1].string.isDouble || calc[i+1].string.isDouble {
                    calc[i].string = toSystem(system: calc[i-1].string.system,
                                              result: String(left.truncatingRemainder(dividingBy: right)))
                } else {
                    calc[i].string = toSystem(system: calc[i-1].string.system,
                                              result: String(Int(left) % Int(right)))
                }
                calc.remove(at: i+1)
                calc.remove(at: i-1)
                i=i-1
            }
        }
        i+=1
    }
}

func doSimplifications(calc: inout [CalcElement]) {
    var i = 0
    while i < calc.count-2 {                    // Check ln(exp(...)) and exp(ln(...))
        if calc[i].string == "exp" && calc[i+1].string == "(" && calc[i+2].string == "ln" {
            calc[i].string = ""
            calc.remove(at: i+2)
        }
        if calc[i].string == "e" && (calc[i+1].string == "**" || calc[i+1].string == "^") && calc[i+2].string == "ln" {
            calc[i].string = ""
            calc.remove(at: i+2)
            calc.remove(at: i+1)
        }
        if i < calc.count-3 && calc[i].string == "e" && (calc[i+1].string == "**" || calc[i+1].string == "^") && calc[i+2].string == "(" && calc[i+3].string == "ln" {
            calc[i].string = ""
            calc.remove(at: i+3)
            calc.remove(at: i+1)
        }
        if i < calc.count-3 && calc[i].string == "ln" && calc[i+2].string == "e" && (calc[i+3].string == "**" || calc[i+3].string == "^") {
            calc.remove(at: i+3)
            calc.remove(at: i+2)
            calc.remove(at: i)
        }
        if calc[i].string == "ln" && calc[i+1].string == "(" && calc[i+2].string == "exp" {
            calc.remove(at: i+2)
            calc.remove(at: i)
            i-=1
        }
        i+=1
    }
}


/// Convert whatever deg to rad for trigonometric function
/// - Parameter calc: calc array
func doDegRad(calc: inout [CalcElement]) {
    var i = 0
    while i < calc.count-1 {
        if calc[i+1].string.isNumber {
            if i < calc.count-2 {
                if calc[i+2].string == "deg" || calc[i+2].string == "°" {
                    calc[i+1].string = String(Double(calc[i+1].string.toNumber)*Double.pi/180)
                    calc.remove(at: i+2)
                } else if calc[i+2].string == "rad" {
                    calc.remove(at: i+2)
                }
            }
        }
        i+=1
    }
}

func doFunctions(calc: inout [CalcElement]) {
    var i = 0
    while i < calc.count-1 {
        if calc[i+1].string.isNumber {
            let fin = Double(calc[i+1].string.toNumber)
            if calc[i].string == "sqrt"  {
                calc[i].string = toSystem(system: calc[i+1].string.system,
                                          result: String(sqrt(fin)))
                if calc[i+1].hasUnit {
                    for u in 0...calc[i+1].unit.count-1 {
                        calc[i+1].unit[u].factor *= 1/2
                    }
                    calc[i].unit = calc[i+1].unit
                }
                calc.remove(at: i+1)
            } else if calc[i].string == "exp" {
                calc[i].string = toSystem(system: calc[i+1].string.system,
                                          result: String(exp(fin)))
                calc.remove(at: i+1)
            } else if calc[i].string == "" {
                if fin > 0 {
                    calc[i].string = toSystem(system: calc[i+1].string.system,
                                              result: String(fin))
                } else {
                    calc[i].string = "NaN"
                }
                calc.remove(at: i+1)
            } else if calc[i].string == "ln"  {
                calc[i].string = toSystem(system: calc[i+1].string.system,
                                          result: String(log(fin)))
                calc.remove(at: i+1)
            } else if calc[i].string == "sinh" {
                calc[i].string = toSystem(system: calc[i+1].string.system, result: String(sinh(fin)))
                calc.remove(at: i+1)
            } else if calc[i].string == "cosh" {
                calc[i].string = toSystem(system: calc[i+1].string.system, result: String(cosh(fin)))
                calc.remove(at: i+1)
            } else if calc[i].string == "tanh" {
                calc[i].string = toSystem(system: calc[i+1].string.system, result: String(tanh(fin)))
                calc.remove(at: i+1)
            } else if calc[i].string == "asinh" {
                calc[i].string = toSystem(system: calc[i+1].string.system, result: String(asinh(fin)))
                calc.remove(at: i+1)
            } else if calc[i].string == "acosh" {
                calc[i].string = toSystem(system: calc[i+1].string.system, result: String(acosh(fin)))
                calc.remove(at: i+1)
            } else if calc[i].string == "atanh" {
                calc[i].string = toSystem(system: calc[i+1].string.system, result: String(atanh(fin)))
                calc.remove(at: i+1)
            } else if calc[i].string == "sin" {
                calc[i].string = toSystem(system: calc[i+1].string.system, result: String(smartRounding(sin(fin))))
                calc.remove(at: i+1)
            } else if calc[i].string == "cos" {
                calc[i].string = toSystem(system: calc[i+1].string.system, result: String(smartRounding(cos(fin))))
                calc.remove(at: i+1)
            } else if calc[i].string == "tan" {
                calc[i].string = toSystem(system: calc[i+1].string.system, result: String(smartRounding(tan(fin))))
                calc.remove(at: i+1)
            } else if calc[i].string == "asin" {
                calc[i].string = toSystem(system: calc[i+1].string.system, result: String(asin(fin)))
                calc.remove(at: i+1)
            } else if calc[i].string == "acos" {
                calc[i].string = toSystem(system: calc[i+1].string.system, result: String(acos(fin)))
                calc.remove(at: i+1)
            } else if calc[i].string == "atan" {
                calc[i].string = toSystem(system: calc[i+1].string.system, result: String(atan(fin)))
                calc.remove(at: i+1)
            } else if calc[i].string == "round" {
                calc[i+1].string = toSystem(system: calc[i+1].string.system,
                                          result: String(round(fin)))
                calc.remove(at: i)
                i-=1
            } else if calc[i].string == "ceil" {
                calc[i+1].string = toSystem(system: calc[i+1].string.system,
                                          result: String(ceil(fin)))
                calc.remove(at: i)
                i-=1
            } else if calc[i].string == "floor" {
                calc[i+1].string = toSystem(system: calc[i+1].string.system,
                                          result: String(floor(fin)))
                calc.remove(at: i)
                i-=1
            } else if i < calc.count-2 {
                if calc[i+2].string.isNumber {
                    let second = Double(calc[i+2].string.toNumber)
                    if calc[i].string == "root"  {
                        calc[i+2].string = toSystem(system: calc[i+1].string.system,
                                                  result: String(pow(second, (1/fin))))
                        if calc[i+2].hasUnit {
                            for u in 0...calc[i+2].unit.count-1 {
                                calc[i+2].unit[u].factor *= 1/fin
                            }
                        }
                        calc.remove(at: i+1)
                        calc.remove(at: i)
                        i-=1
                    } else if calc[i].string == "log"  {
                        calc[i].string = toSystem(system: calc[i+1].string.system,
                                                  result: String(logN(N: fin, val: second)))
                        calc.remove(at: i+2)
                        calc.remove(at: i+1)
                    }
                }
            }
        }/* else if i < calc.count-2 && calc[i].string == "e" && (calc[i+1].string == "**" || calc[i+1].string == "^") && calc[i+2].string.isNumber {
            let fin = Double(calc[i+2].string.toNumber)
            calc[i].string = toSystem(system: calc[i+1].string.system,
                                      result: String(exp(fin)))
            calc.remove(at: i+2)
            calc.remove(at: i+1)
        }*/
        i+=1
    }
}
 

/// Reccurently calculate what's inside the parenthesis
/// - Parameters:
///   - calc: calc array
///   - pos: for recurrence
func doParenthesis(calc: inout [CalcElement], _ pos: Int) {
    var i = pos
    var start = 0
    var stop = 0
    while i < calc.count {
        if calc[i].string == "(" {
            start = i+1
            break
        }
        i+=1
    }
    i = start
    while i < calc.count {
        if calc[i].string == ")" {
            stop = i-1
            if stop >= start && start != 0 && stop != 0 {
                var subcalc = Array<CalcElement>(calc[start...stop])
                let len = subcalc.count
                if isComplex(calc: &calc) {
                    doComplexMath(calc: &subcalc)
                } else {
                    doMath(calc: &subcalc)
                }
                if subcalc.count < len {
                    for k in start...stop {
                        if k-start >= subcalc.count {
                            calc.remove(at: stop)
                            stop -= 1
                        } else {
                            calc[k] = subcalc[k-start]
                        }
                    }
                }
                if subcalc.count == 1 {
                    calc.remove(at: stop+1)
                    calc.remove(at: start-1)
                }
            }
            break
        } else if calc[i].string == "(" {
            doParenthesis(calc: &calc, start)
        }
        i+=1
    }
 }


/// Round result properly depending on settings
/// - Parameter value: value to round
/// - Returns: rounded value
func smartRounding(_ value: Double) -> Double {
    let power = NSDecimalNumber(decimal: pow(10, AppVariables.digits)).doubleValue
    let rounded = round(power * value) / power
    return rounded
}

func logN(N: Double, val: Double) -> Double {
    return log(val)/log(N)
}

func fact(_ of: Int) -> Int {
    return (1...max(of, 1)).reduce(1, *)
}
