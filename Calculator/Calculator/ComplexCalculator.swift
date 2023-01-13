//
//  ComplexCalculator.swift
//  Calculator
//
//  Created by Cyprien Heusse on 24/09/2021.
//

import Foundation
import Numerics

// TODO: show some love to complex operations

func isComplex(calc: inout [CalcElement]) -> Bool {
    if calc.filter({ $0.string == "i"}).count > 0 {
        return true
    } else {
        for i in calc {
            if i.isComplex {
                return true
            }
        }
        return false
    }
}

func doComplex(calc: inout [CalcElement]) {
    toComplex(calc: &calc)
    calcPrint(calc)
    doParenthesis(calc: &calc, 0)
    doComplexMath(calc: &calc)
}

func doComplexMath(calc: inout [CalcElement]) {
    doComplexNegative(calc: &calc)
    doComplexFunctions(calc: &calc)
    doComplexPower(calc: &calc)
    doComplexImplicit(calc: &calc)
    doComplexMultDiv(calc: &calc)
    doComplexPlusMinus(calc: &calc)
}

func doComplexFunctions(calc: inout [CalcElement]) {
    var i = 0
    while i < calc.count-1 {
        if calc[i+1].isComplex {
            let x = calc[i+1].complex
            if calc[i].string == "sqrt"  {
                calc[i+1].complex = c_pow(x, Complex(0.5))
                calc.remove(at: i)
                i-=1
            } else if calc[i].string == "exp" {
                calc[i+1].complex = c_exp(x)
                calc.remove(at: i)
                i-=1
            } else if calc[i].string == "abs" {
                calc[i+1].complex = Complex(x.length)
                calc.remove(at: i)
                i-=1
            } else if calc[i].string == "arg" {
                calc[i+1].complex = Complex(x.phase)
                calc.remove(at: i)
                i-=1
            } else if calc[i].string == "" {
                calc.remove(at: i)
                i-=1
            } else if calc[i].string == "ln" || calc[i].string == "log" {
                calc[i+1].complex = c_log(x)
                calc.remove(at: i)
                i-=1
            } else if i < calc.count-2 {
                let y = calc[i+2].complex
                if calc[i].string == "root" && calc[i+1].isComplex && calc[i+2].isComplex {
                    calc[i+1].complex = c_pow(y, 1/x)
                    calc.remove(at: i+2)
                    calc.remove(at: i)
                    i-=1
                } else if calc[i].string == "e" && (calc[i+1].string == "^" || calc[i+1].string == "**") && calc[i+2].isComplex {
                    calc[i+2].complex = c_exp(y)
                    calc.remove(at: i+1)
                    calc.remove(at: i)
                    i-=1
                }
            }
        }
        i+=1
    }
}

func doComplexNegative(calc: inout [CalcElement]) {
    var i = 0
    while i < calc.count-1 {
        if calc[i].string == "-" && calc[i+1].isComplex {
            if i == 0 || !calc[i-1].isComplex {
                calc[i+1].complex = -calc[i+1].complex
                calc.remove(at: i)
                i-=1
            }
        }
        i+=1
    }
}

func doComplexImplicit(calc: inout [CalcElement]) {
    var i = 0
    while i < calc.count-1 {
        if calc[i].isComplex && calc[i+1].isComplex {
            let left = calc[i].complex
            let right = calc[i+1].complex
            calc[i].complex = left*right
            calc.remove(at: i+1)
        }
        i+=1
    }
}

func doComplexMultDiv(calc: inout [CalcElement]) {
    var i = 1
    while i < calc.count-1 {
        if calc[i].string == "*" || calc[i].string == "/" {
            if calc[i-1].isComplex && calc[i+1].isComplex {
                let left = calc[i-1].complex
                let right = calc[i+1].complex
                
                if calc[i].string == "*" {
                    calc[i-1].complex = left*right
                } else {
                    calc[i-1].complex = left/right
                }
                calc.remove(at: i+1)
                calc.remove(at: i)
                i-=1
            }
        }
        i+=1
    }
}

func doComplexPlusMinus(calc: inout [CalcElement]) {
    var i = 1
    while i < calc.count-1 {
        if calc[i].string == "+" || calc[i].string == "-" {
            if calc[i-1].isComplex && calc[i+1].isComplex {
                let left = calc[i-1].complex
                let right = calc[i+1].complex
                
                if calc[i].string == "+" {
                    calc[i-1].complex = left+right
                } else {
                    calc[i-1].complex = left-right
                }
                
                calc.remove(at: i+1)
                calc.remove(at: i)
                i-=1
            }
        }
        i+=1
    }
}

func doLogarithm(calc: inout [CalcElement]) {
    var i = 0
    while i < calc.count-1 {
        if (calc[i].string == "log" || calc[i].string == "ln") && calc[i+1].isComplex {
            let x = calc[i+1].complex
            calc[i+1].complex = c_log(x)
            calc.remove(at: i)
            i-=1
        }
        i+=1
    }
}

func doRoots(calc: inout [CalcElement]) {
    var i = 0
    while i < calc.count-1 {
        if calc[i].string == "sqrt" && calc[i+1].isComplex {
            let x = calc[i+1].complex
            calc[i+1].complex = c_pow(x, Complex(0.5))
            calc.remove(at: i)
            i-=1
        } else if i < calc.count-2 && calc[i].string == "root" && calc[i+1].isComplex && calc[i+2].isComplex {
            let y = calc[i+1].complex
            let x = calc[i+2].complex
            
            calc[i+1].complex = c_pow(x, 1/y)
            calc.remove(at: i+2)
            calc.remove(at: i)
            i-=1
        }
        i+=1
    }
}

func doComplexExponential(calc: inout [CalcElement]) {
    var i = 0
    while i < calc.count-1 {
        if calc[i].string == "exp" && calc[i+1].isComplex {
            let x = calc[i+1].complex
            calc[i+1].complex = c_exp(x)
            calc.remove(at: i)
            i-=1
        } else if i < calc.count-2 && calc[i].string == "e" && calc[i+1].string == "^" && calc[i+2].isComplex {
            let x = calc[i+2].complex
            calc[i+2].complex = c_exp(x)
            calc.remove(at: i+1)
            calc.remove(at: i)
            i-=1
        }
        i+=1
    }
}

func doComplexPower(calc: inout [CalcElement]) {
    var i = 0
    while i < calc.count-1 {
        if (calc[i].string == "**" || calc[i].string == "^") && calc[i-1].isComplex && calc[i+1].isComplex {
            let x = calc[i-1].complex
            let y = calc[i+1].complex
            calc[i-1].complex = c_pow(x, y)
            calc.remove(at: i+1)
            calc.remove(at: i)
            i-=1
        }
        i+=1
    }
}

func toComplex(calc: inout [CalcElement]) {
    var i = 0
    while i < calc.count {
        if calc[i].hasValue {
            if calc[i].isInteger {
                calc[i].complex = Complex(calc[i].integer)
            } else if calc[i].isReal {
                calc[i].complex = Complex(calc[i].real)
            }
            calc[i].isComplex = true
            calc.toComplex()
        } else if calc[i].string == "i" {
            calc[i].complex = .i
            calc[i].isComplex = true
            calc.toComplex()
        }
        i+=1
    }
}

func c_exp(_ x: Complex<Double>) -> Complex<Double> {
    let result = Complex(exp(x.real))*Complex(length: 1, phase: x.imaginary)
    return result
}

func c_log(_ x: Complex<Double>) -> Complex<Double> {
    let result = Complex(log(x.length)) + .i * Complex(x.phase)
    return result
}

func c_pow(_ x: Complex<Double>, _ y: Complex<Double>) -> Complex<Double> {
    let result = c_exp( Complex( log(x.length) ) * y + .i * Complex(x.phase) * y )
    return result
}
