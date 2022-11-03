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
        if calc[i].string == "-" && calc[i+1].hasValue {
            if i == 0 || !calc[i-1].hasValue {
                if calc[i+1].isInteger {
                    calc[i+1].integer = -calc[i+1].integer
                } else {
                    calc[i+1].real = -calc[i+1].real
                }
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
        if calc[i].string == "!" && calc[i-1].hasValue {
            if calc[i-1].isInteger {
                calc[i].integer = fact(calc[i-1].integer)
                calc[i].isInteger = true
                calc.remove(at: i-1)
                i-=1
            }
        }
        i+=1
    }
}

func doImplicit(calc: inout [CalcElement]) {
    var i = 0
    while i < calc.count-1 {
        if calc[i].hasValue && calc[i+1].hasValue {
            if calc.isInteger {
                let left = calc[i].integer
                let right = calc[i+1].integer
                calc[i] = CalcElement(string: "", unit: calc[i].unit, isInteger: true, integer: left*right, range: calc[i].range)
            } else {
                let left = calc[i].getDouble
                let right = calc[i+1].getDouble
                calc[i] = CalcElement(string: "", unit: calc[i].unit, isReal: true, real: left*right, range: calc[i].range)
            }

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
            if calc[i-1].hasValue && calc[i+1].hasValue {
                if calc[i].string == "*" {
                    if calc.isInteger {
                        let left = calc[i-1].integer
                        let right = calc[i+1].integer
                        calc[i-1] = CalcElement(string: "", unit: calc[i-1].unit, isInteger: true, integer: left*right, range: calc[i-1].range)
                    } else {
                        let left = calc[i-1].getDouble
                        let right = calc[i+1].getDouble
                        calc[i-1] = CalcElement(string: "", unit: calc[i-1].unit, isReal: true, real: left*right, range: calc[i-1].range)
                    }
                    if calc[i+1].hasUnit {
                        for u in calc[i+1].unit {
                            calc[i-1].unit.append(u)
                        }
                    }
                } else if calc[i].string == "/" {
                    if calc.isInteger {
                        let left = calc[i-1].integer
                        let right = calc[i+1].integer
                        if right != 0 {
                            calc[i-1] = CalcElement(string: "", unit: calc[i-1].unit, isInteger: true, integer: left/right, range: calc[i-1].range)
                        } else {
                            calc[i-1] = CalcElement(string: "", range: calc[i].range, error: Constants.DIVIDE_ZERO_ERROR)
                        }
                    } else {
                        let left = calc[i-1].getDouble
                        let right = calc[i+1].getDouble
                        if right != 0 {
                            calc[i-1] = CalcElement(string: "", unit: calc[i-1].unit, isReal: true, real: left/right, range: calc[i-1].range)
                        } else {
                            calc[i-1] = CalcElement(string: "", range: calc[i].range, error: Constants.DIVIDE_ZERO_ERROR)
                        }
                    }
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
            if calc[i-1].hasValue && calc[i+1].hasValue {
                if (!calc[i-1].hasUnit && !calc[i+1].hasUnit) || sameUnit(calc[i-1], calc[i+1]) {
                    var final_unit: [Unit] = calc[i-1].unit
                    var x_factor: Double = 1
                    var y_factor: Double = 1
                    if calc[i-1].hasUnit {
                        let result = getAdditionUnit(calc[i-1], calc[i+1])
                        if result.0 {
                            final_unit = calc[i+1].unit
                            x_factor = pow(10, result.1)
                        } else {
                            final_unit = calc[i-1].unit
                            y_factor = pow(10, result.1)
                        }
                    }
                    if calc[i].string == "+" {
                        if calc.isInteger {
                            let left = calc[i-1].integer
                            let right = calc[i+1].integer
                            calc[i-1] = CalcElement(string: "", unit: calc[i-1].unit, isInteger: true, integer: Int(x_factor)*left+Int(y_factor)*right, range: calc[i-1].range)
                        } else {
                            let left = calc[i-1].getDouble
                            let right = calc[i+1].getDouble
                            calc[i-1] = CalcElement(string: "", unit: calc[i-1].unit, isReal: true, real: x_factor*left+y_factor*right, range: calc[i-1].range)
                        }
                    } else if calc[i].string == "-" {
                        if calc.isInteger {
                            let left = calc[i-1].integer
                            let right = calc[i+1].integer
                            calc[i-1] = CalcElement(string: "", unit: calc[i-1].unit, isInteger: true, integer: Int(x_factor)*left-Int(y_factor)*right, range: calc[i-1].range)
                        } else {
                            let left = calc[i-1].getDouble
                            let right = calc[i+1].getDouble
                            calc[i-1] = CalcElement(string: "", unit: calc[i-1].unit, isReal: true, real: x_factor*left-y_factor*right, range: calc[i-1].range)
                        }
                    }
                    calc[i-1].unit = final_unit
                    calc.remove(at: i+1)
                    calc.remove(at: i)
                    i-=1
                } else {
                    calc = [CalcElement(string: "", range: NSMakeRange(0, 0), error: Constants.UNIT_ERROR)]
                    return
                }
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
                if calc.isInteger {
                    let left = calc[i-1].integer
                    let right = calc[i+1].integer
                    if right != 0 {
                        calc[i] = CalcElement(string: "", isInteger: true, integer: left % right, range: calc[i].range)
                    } else {
                        calc[i] = CalcElement(string: "", range: calc[i].range, error: Constants.DIVIDE_ZERO_ERROR)
                    }
                } else {
                    let left = calc[i-1].getDouble
                    let right = calc[i+1].getDouble
                    if right != 0 {
                        calc[i] = CalcElement(string: "", isReal: true, real: left.truncatingRemainder(dividingBy: right), range: calc[i].range)
                    } else {
                        calc[i] = CalcElement(string: "", range: calc[i].range, error: Constants.DIVIDE_ZERO_ERROR)
                    }
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
                    calc[i+1] = CalcElement(string: "", isReal: true, real: calc[i+1].getDouble*Double.pi/180, range: calc[i+1].range)
                    calc.remove(at: i+2)
                } else if calc[i+2].string == "rad" {
                    calc.remove(at: i+2)
                }
            }
        }
        i+=1
    }
}

func doFunctions(calc: inout [CalcElement]) {       // OUTPUTS DOUBLE MOST OF THE TIME
    var i = 0
    while i < calc.count-1 {
        if calc[i+1].hasValue {
            let fin = calc[i+1].getDouble
            if calc[i].string == "sqrt"  {
                calc[i] = CalcElement(string: "", isReal: true, real: sqrt(fin), range: calc[i].range)
                if calc[i+1].hasUnit {
                    for u in 0...calc[i+1].unit.count-1 {
                        calc[i+1].unit[u].factor *= 1/2
                    }
                    calc[i].unit = calc[i+1].unit
                }
                calc.remove(at: i+1)
            } else if calc[i].string == "exp" {
                calc[i] = CalcElement(string: "", isReal: true, real: exp(fin), range: calc[i].range)
                calc.remove(at: i+1)
            } else if calc[i].string == "" {
                if fin > 0 {
                    calc[i] = CalcElement(string: "", isReal: true, real: fin, range: calc[i].range)
                } else {
                    calc[i].string = "NaN"
                }
                calc.remove(at: i+1)
            } else if calc[i].string == "ln"  {
                calc[i] = CalcElement(string: "", isReal: true, real: log(fin), range: calc[i].range)
                calc.remove(at: i+1)
            } else if calc[i].string == "sinh" {
                calc[i] = CalcElement(string: "", isReal: true, real: sinh(fin), range: calc[i].range)
                calc.remove(at: i+1)
            } else if calc[i].string == "cosh" {
                calc[i] = CalcElement(string: "", isReal: true, real: cosh(fin), range: calc[i].range)
                calc.remove(at: i+1)
            } else if calc[i].string == "tanh" {
                calc[i] = CalcElement(string: "", isReal: true, real: tanh(fin), range: calc[i].range)
                calc.remove(at: i+1)
            } else if calc[i].string == "asinh" {
                calc[i] = CalcElement(string: "", isReal: true, real: asinh(fin), range: calc[i].range)
                calc.remove(at: i+1)
            } else if calc[i].string == "acosh" {
                calc[i] = CalcElement(string: "", isReal: true, real: acosh(fin), range: calc[i].range)
                calc.remove(at: i+1)
            } else if calc[i].string == "atanh" {
                calc[i] = CalcElement(string: "", isReal: true, real: atanh(fin), range: calc[i].range)
                calc.remove(at: i+1)
            } else if calc[i].string == "sin" {
                calc[i] = CalcElement(string: "", isReal: true, real: sin(fin), range: calc[i].range)
                calc.remove(at: i+1)
            } else if calc[i].string == "cos" {
                calc[i] = CalcElement(string: "", isReal: true, real: cos(fin), range: calc[i].range)
                calc.remove(at: i+1)
            } else if calc[i].string == "tan" {
                calc[i] = CalcElement(string: "", isReal: true, real: tan(fin), range: calc[i].range)
                calc.remove(at: i+1)
            } else if calc[i].string == "asin" {
                calc[i] = CalcElement(string: "", isReal: true, real: asin(fin), range: calc[i].range)
                calc.remove(at: i+1)
            } else if calc[i].string == "acos" {
                calc[i] = CalcElement(string: "", isReal: true, real: acos(fin), range: calc[i].range)
                calc.remove(at: i+1)
            } else if calc[i].string == "atan" {
                calc[i] = CalcElement(string: "", isReal: true, real: atan(fin), range: calc[i].range)
                calc.remove(at: i+1)
            } else if calc[i].string == "round" {
                calc[i] = CalcElement(string: "", isInteger: true, integer: Int(round(fin)), range: calc[i].range)
                calc.remove(at: i)
                i-=1
            } else if calc[i].string == "ceil" {
                calc[i] = CalcElement(string: "", isInteger: true, integer: Int(ceil(fin)), range: calc[i].range)
                calc.remove(at: i)
                i-=1
            } else if calc[i].string == "floor" {
                calc[i] = CalcElement(string: "", isInteger: true, integer: Int(floor(fin)), range: calc[i].range)
                calc.remove(at: i)
                i-=1
            } else if i < calc.count-2 {
                if calc[i+2].hasValue {
                    let second = calc[i+2].getDouble
                    if calc[i].string == "root"  {
                        calc[i+2] = CalcElement(string: "", unit: calc[i+2].unit, isReal: true, real: pow(second, (1/fin)), range: calc[i].range)
                        if calc[i+2].hasUnit {
                            for u in 0...calc[i+2].unit.count-1 {
                                calc[i+2].unit[u].factor *= 1/fin
                            }
                        }
                        calc.remove(at: i+1)
                        calc.remove(at: i)
                        i-=1
                    } else if calc[i].string == "log"  {
                        calc[i] = CalcElement(string: "", isReal: true, real: logN(fin, second), range: calc[i].range)
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

func logN(_ N: Double, _ val: Double) -> Double {
    return log(val)/log(N)
}

func fact(_ of: Int) -> Int {
    return (1...max(of, 1)).reduce(1, *)
}
