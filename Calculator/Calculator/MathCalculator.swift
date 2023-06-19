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
    doNegative(calc: &calc)
    doImplicit(calc: &calc)
    doPower(calc: &calc, 0)
    doMultDiv(calc: &calc)
    doPlusMinus(calc: &calc)
}

func doPower(calc: inout [CalcElement], _ start: Int) {
    var i = start+1
    while i < calc.count-1 {
        if calc[i].string == "^" || calc[i].string == "**" {
            if calc[i+1].hasValue {
                if i < calc.count-2 && (calc[i+2].string == "^" || calc[i+2].string == "**") {
                    doPower(calc: &calc, i+1)
                }
                if calc[i-1].hasValue {
                    if(calc[i+1].isReal || calc[i-1].isReal || (calc[i+1].isInteger && calc[i+1].integer < 0)) {
                        let right = (calc[i+1].isReal) ? calc[i+1].real : Double(calc[i+1].integer)
                        let left = (calc[i-1].isReal) ? calc[i-1].real : Double(calc[i-1].integer)
                        
                        calc[i-1].real = pow(left, right)
                        calc[i-1].isReal = true
                        calc[i-1].isInteger = false
                        if calc[i-1].hasUnit && calc[i+1].isInteger {
                            for u in 0...calc[i-1].unit.count-1 {
                                calc[i-1].unit[u].factor *= Double(right)
                            }
                        }
                    } else {
                        let right = calc[i+1].integer
                        let left = calc[i-1].integer
                        let power = pow(Double(left), Double(right))
                        if power < Double(Int.min) || power >= Double(Int.max) {
                            setError(calc: &calc, error: Constants.TOO_BIG_ERROR)
                            return
                        } else {
                            calc[i-1].integer = Int(power)
                            if calc[i-1].hasUnit && calc[i+1].isInteger {
                                for u in 0...calc[i-1].unit.count-1 {
                                    calc[i-1].unit[u].factor *= Double(right)
                                }
                            }
                        }
                    }
                    
                }/* else if calc[i-1].string == "e" {
                    calc[i-1].string = toSystem(system: calc[i+1].string.system,
                                              result: String(exp(right)))
                }*/
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
                    let result = getMultiplicationUnit(calc[i-1].unit, calc[i+1].unit)
                    calc[i-1].unit = result.0
                    if calc.isInteger && result.1 >= 0 {
                        let left = calc[i-1].integer
                        let right = calc[i+1].integer
                        calc[i-1] = CalcElement(string: "", unit: calc[i-1].unit, isInteger: true, integer: left*right, range: calc[i-1].range)
                        calc[i-1].integer *= Int(pow(10, result.1))
                    } else {
                        let left = calc[i-1].getDouble
                        let right = calc[i+1].getDouble
                        calc[i-1] = CalcElement(string: "", unit: calc[i-1].unit, isReal: true, real: left*right, range: calc[i-1].range)
                        calc[i-1].real *= pow(10, result.1)
                    }
                } else if calc[i].string == "/" {
                    let result = getMultiplicationUnit(calc[i-1].unit, calc[i+1].unit.map { Unit(unit: $0.unit, prefix: $0.prefix, factor: -$0.factor) })
                    calc[i-1].unit = result.0
                    
                    let left = calc[i-1].getDouble
                    let right = calc[i+1].getDouble
                    if right != 0 {
                        calc[i-1] = CalcElement(string: "", unit: calc[i-1].unit, isReal: true, real: left/right, range: calc[i-1].range)
                        calc[i-1].real *= pow(10, result.1)
                    } else {
                        setError(calc: &calc, error: Constants.DIVIDE_ZERO_ERROR)
                        return
                    }
                }
                //arrangeUnits(&calc[i-1])
                
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
                        let result = getAdditionUnit(calc[i-1].unit, calc[i+1].unit)
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
                    setError(calc: &calc, error: Constants.UNIT_ERROR)
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
                        setError(calc: &calc, error: Constants.DIVIDE_ZERO_ERROR)
                        return
                    }
                } else {
                    let left = calc[i-1].getDouble
                    let right = calc[i+1].getDouble
                    if right != 0 {
                        calc[i] = CalcElement(string: "", isReal: true, real: left.truncatingRemainder(dividingBy: right), range: calc[i].range)
                    } else {
                        setError(calc: &calc, error: Constants.DIVIDE_ZERO_ERROR)
                        return
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
func doDegRad(_ e: CalcElement) -> Double {
    if e.unit.contains(where: {$0.unit.name == "degree" && $0.factor == 1}) {
        return e.getDouble*Double.pi/180.0
    }
    return e.getDouble
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
                calc[i] = CalcElement(string: "", isReal: true, real: smartRounding(sin(doDegRad(calc[i+1]))), range: calc[i].range)
                calc.remove(at: i+1)
            } else if calc[i].string == "cos" {
                calc[i] = CalcElement(string: "", isReal: true, real: smartRounding(cos(doDegRad(calc[i+1]))), range: calc[i].range)
                calc.remove(at: i+1)
            } else if calc[i].string == "tan" {
                calc[i] = CalcElement(string: "", isReal: true, real: tan(doDegRad(calc[i+1])), range: calc[i].range)
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

func doParenthesis(calc: inout [CalcElement]) {
    var i = 0
    while i < calc.count {
        if calc[i].string == "(" {
            i = doParenthesisRecursive(calc: &calc, i)
            if i == 0 {
                break
            }
        }
        i+=1
    }
}

func doParenthesisRecursive(calc: inout [CalcElement], _ pos: Int) -> Int {
    var i = pos+1
    while i < calc.count && calc[i].string != ")" {
        if calc[i].string == "(" {
            i = doParenthesisRecursive(calc: &calc, i)
        }
        i+=1
    }
    if i < calc.count && calc[i].string == ")" {
        var subcalc = Array<CalcElement>(calc[pos+1...i-1])
        let length = subcalc.count
        if isComplex(calc: &calc) {
            doComplexMath(calc: &subcalc)
        } else {
            doMath(calc: &subcalc)
            doLogic(calc: &subcalc)
        }
        if subcalc.count == 1 {
            for j in (pos...i).reversed() {
                calc.remove(at: j)
            }
            calc.insert(contentsOf: subcalc, at: pos)
            i -= (length+1)
        } else {
            setError(calc: &calc, error: Constants.MATH_ERROR)
            return 0
        }
    }
    return i
}

/// Round result properly depending on settings
/// - Parameter value: value to round
/// - Returns: rounded value
func smartRounding(_ value: Double) -> Double {
    let power = pow(10, Double(AppVariables.digits))
    let rounded = round(power * value) / power
    return rounded
}

func logN(_ N: Double, _ val: Double) -> Double {
    return log(val)/log(N)
}

func fact(_ of: Int) -> Int {
    return (1...max(of, 1)).reduce(1, *)
}
