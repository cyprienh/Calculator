//
//  Units.swift
//  Calculator
//
//  Created by Cyprien Heusse on 07/10/2021.
//

import Foundation

struct UnitPrefix {
    let name: String
    let symbol: String
    let factor: Int
}

struct UnitName {
    let name: String
    let symbol: String
    let hasPrefix: Bool
}

struct Unit {
    var unit: UnitName
    var prefix: UnitPrefix
    var factor: Double = 1
}

let Prefixes: [UnitPrefix] = [
    UnitPrefix(name: "yotta", symbol: "Y", factor: 24),
    UnitPrefix(name: "zetta", symbol: "Z", factor: 21),
    UnitPrefix(name: "exa", symbol: "E", factor: 18),
    UnitPrefix(name: "peta", symbol: "P", factor: 15),
    UnitPrefix(name: "tera", symbol: "T", factor: 12),
    UnitPrefix(name: "giga", symbol: "G", factor: 9),
    UnitPrefix(name: "mega", symbol: "M", factor: 6),
    UnitPrefix(name: "kilo", symbol: "k", factor: 3),
    UnitPrefix(name: "hecto", symbol: "h", factor: 2),
    UnitPrefix(name: "deca", symbol: "da", factor: 1),
    UnitPrefix(name: "", symbol: "", factor: 0),
    UnitPrefix(name: "deci", symbol: "d", factor: -1),
    UnitPrefix(name: "centi", symbol: "c", factor: -2),
    UnitPrefix(name: "milli", symbol: "m", factor: -3),
    UnitPrefix(name: "micro", symbol: "u", factor: -6),
    UnitPrefix(name: "micro", symbol: "μ", factor: -6),
    UnitPrefix(name: "nano", symbol: "n", factor: -9),
    UnitPrefix(name: "pico", symbol: "p", factor: -12),
    UnitPrefix(name: "femto", symbol: "f", factor: -15)
]


let Units: [UnitName] = [
    UnitName(name: "bit", symbol: "bit", hasPrefix: true),
    UnitName(name: "mole", symbol: "mol", hasPrefix: true),
    UnitName(name: "hertz", symbol: "Hz", hasPrefix: true),
    UnitName(name: "weber", symbol: "Wb", hasPrefix: true),
    UnitName(name: "mile", symbol: "mi", hasPrefix: false),
    UnitName(name: "yard", symbol: "yd", hasPrefix: false),
    UnitName(name: "foot", symbol: "ft", hasPrefix: false),
    UnitName(name: "inch", symbol: "in", hasPrefix: false),
    UnitName(name: "pound", symbol: "lb", hasPrefix: false),
    UnitName(name: "ounce", symbol: "oz", hasPrefix: false),
    UnitName(name: "fahrenheit", symbol: "°F", hasPrefix: false),
    UnitName(name: "celsius", symbol: "°C", hasPrefix: false),
    UnitName(name: "meter", symbol: "m", hasPrefix: true),
    UnitName(name: "liter", symbol: "L", hasPrefix: true),
    UnitName(name: "second", symbol: "s", hasPrefix: true),
    UnitName(name: "gram", symbol: "g", hasPrefix: true),
    UnitName(name: "newton", symbol: "N", hasPrefix: true),
    UnitName(name: "joule", symbol: "J", hasPrefix: true),
    UnitName(name: "watt", symbol: "W", hasPrefix: true),
    UnitName(name: "kelvin", symbol: "K", hasPrefix: true),
    UnitName(name: "ampere", symbol: "A", hasPrefix: true),
    UnitName(name: "coulomb", symbol: "C", hasPrefix: true),
    UnitName(name: "volt", symbol: "V", hasPrefix: true),
    UnitName(name: "ohm", symbol: "Ω", hasPrefix: true),
    UnitName(name: "farad", symbol: "F", hasPrefix: true),
    UnitName(name: "siemens", symbol: "S", hasPrefix: true),
    UnitName(name: "henry", symbol: "H", hasPrefix: true),
    UnitName(name: "tesla", symbol: "T", hasPrefix: true),
    UnitName(name: "byte", symbol: "B", hasPrefix: true),
    UnitName(name: "byte", symbol: "o", hasPrefix: true),
    UnitName(name: "bit", symbol: "b", hasPrefix: true),
    UnitName(name: "foot", symbol: "'", hasPrefix: false),
    UnitName(name: "inch", symbol: "\"", hasPrefix: false)
]

func unitConversions(_ from: CalcElement, to: [Unit]) -> CalcElement {
    var new_element = from
    if from.unit.contains(where: {$0.unit.name == "celsius"}) && to.contains(where: {$0.unit.name == "fahrenheit"}) {
        let new_value = 9/5*Double(from.string.toNumber)+32
        new_element.string = String(new_value)
        new_element.unit = from.unit.map({ $0.unit.name == "celsius" ? Unit(unit: Units.first(where: {$0.name == "fahrenheit"})!, prefix: $0.prefix) : $0 })
    } else if from.unit.contains(where: {$0.unit.name == "fahrenheit"}) && to.contains(where: {$0.unit.name == "celsius"}) {
        let new_value = 5/9*(Double(from.string.toNumber)-32)
        new_element.string = String(new_value)
        new_element.unit = from.unit.map({ $0.unit.name == "fahrenheit" ? Unit(unit: Units.first(where: {$0.name == "celsius"})!, prefix: $0.prefix) : $0 })
    }
    if from.unit.contains(where: {$0.unit.name == "celsius"}) && to.contains(where: {$0.unit.name == "kelvin"}) {
        let new_value = Double(from.string.toNumber)+273.15
        new_element.string = String(new_value)
        new_element.unit = from.unit.map({ $0.unit.name == "celsius" ? Unit(unit: Units.first(where: {$0.name == "kelvin"})!, prefix: $0.prefix) : $0 })
    } else if from.unit.contains(where: {$0.unit.name == "kelvin"}) && to.contains(where: {$0.unit.name == "celsius"}) {
        let new_value = Double(from.string.toNumber)-273.15
        new_element.string = String(new_value)
        new_element.unit = from.unit.map({ $0.unit.name == "kelvin" ? Unit(unit: Units.first(where: {$0.name == "celsius"})!, prefix: $0.prefix) : $0 })
    }
    if from.unit.contains(where: {$0.unit.name == "kelvin"}) && to.contains(where: {$0.unit.name == "fahrenheit"}) {
        let new_value = 9/5*(Double(from.string.toNumber)-273.15)+32
        new_element.string = String(new_value)
        new_element.unit = from.unit.map({ $0.unit.name == "kelvin" ? Unit(unit: Units.first(where: {$0.name == "fahrenheit"})!, prefix: $0.prefix) : $0 })
    } else if from.unit.contains(where: {$0.unit.name == "fahrenheit"}) && to.contains(where: {$0.unit.name == "kelvin"}) {
        let new_value = 5/9*(Double(from.string.toNumber)-32)+273.15
        new_element.string = String(new_value)
        new_element.unit = from.unit.map({ $0.unit.name == "fahrenheit" ? Unit(unit: Units.first(where: {$0.name == "kelvin"})!, prefix: $0.prefix) : $0 })
    }
    
    if from.unit.contains(where: {$0.unit.name == "byte"}) && to.contains(where: {$0.unit.name == "bit"}) {
        let new_value = 8*Double(from.string.toNumber)
        new_element.string = String(new_value)
        new_element.unit = from.unit.map({ $0.unit.name == "byte" ? Unit(unit: Units.first(where: {$0.name == "bit"})!, prefix: $0.prefix) : $0 })
    } else if from.unit.contains(where: {$0.unit.name == "bit"}) && to.contains(where: {$0.unit.name == "byte"}) {
        let new_value = Double(from.string.toNumber)/8
        new_element.string = String(new_value)
        new_element.unit = from.unit.map({ $0.unit.name == "bit" ? Unit(unit: Units.first(where: {$0.name == "byte"})!, prefix: $0.prefix) : $0 })
    }
    
    if from.unit.contains(where: {$0.unit.name == "inch"}) && to.contains(where: {$0.unit.name == "meter"}) {
        let new_value = 0.0254*Double(from.string.toNumber)
        new_element.string = String(new_value)
        new_element.unit = from.unit.map({ $0.unit.name == "inch" ? Unit(unit: Units.first(where: {$0.name == "meter"})!, prefix: $0.prefix) : $0 })
    } else if from.unit.contains(where: {$0.unit.name == "meter"}) && to.contains(where: {$0.unit.name == "inch"}) {
        let new_value = 1/0.0254*Double(from.string.toNumber)
        new_element.string = String(new_value)
        new_element.unit = from.unit.map({ $0.unit.name == "meter" ? Unit(unit: Units.first(where: {$0.name == "inch"})!, prefix: $0.prefix) : $0 })
    }
    if from.unit.contains(where: {$0.unit.name == "foot"}) && to.contains(where: {$0.unit.name == "meter"}) {
        let new_value = 0.3048*Double(from.string.toNumber)
        new_element.string = String(new_value)
        new_element.unit = from.unit.map({ $0.unit.name == "foot" ? Unit(unit: Units.first(where: {$0.name == "meter"})!, prefix: $0.prefix) : $0 })
    } else if from.unit.contains(where: {$0.unit.name == "meter"}) && to.contains(where: {$0.unit.name == "foot"}) {
        let new_value = 1/0.3048*Double(from.string.toNumber)
        new_element.string = String(new_value)
        new_element.unit = from.unit.map({ $0.unit.name == "meter" ? Unit(unit: Units.first(where: {$0.name == "foot"})!, prefix: $0.prefix) : $0 })
    }
    if from.unit.contains(where: {$0.unit.name == "yard"}) && to.contains(where: {$0.unit.name == "meter"}) {
        let new_value = 0.9144*Double(from.string.toNumber)
        new_element.string = String(new_value)
        new_element.unit = from.unit.map({ $0.unit.name == "yard" ? Unit(unit: Units.first(where: {$0.name == "meter"})!, prefix: $0.prefix) : $0 })
    } else if from.unit.contains(where: {$0.unit.name == "meter"}) && to.contains(where: {$0.unit.name == "yard"}) {
        let new_value = 1/0.9144*Double(from.string.toNumber)
        new_element.string = String(new_value)
        new_element.unit = from.unit.map({ $0.unit.name == "meter" ? Unit(unit: Units.first(where: {$0.name == "yard"})!, prefix: $0.prefix) : $0 })
    }
    if from.unit.contains(where: {$0.unit.name == "mile"}) && to.contains(where: {$0.unit.name == "meter"}) {
        let new_value = 1609.3*Double(from.string.toNumber)
        new_element.string = String(new_value)
        new_element.unit = from.unit.map({ $0.unit.name == "mile" ? Unit(unit: Units.first(where: {$0.name == "meter"})!, prefix: $0.prefix) : $0 })
    } else if from.unit.contains(where: {$0.unit.name == "meter"}) && to.contains(where: {$0.unit.name == "mile"}) {
        let new_value = 1/1609.3*Double(from.string.toNumber)
        new_element.string = String(new_value)
        new_element.unit = from.unit.map({ $0.unit.name == "meter" ? Unit(unit: Units.first(where: {$0.name == "mile"})!, prefix: $0.prefix) : $0 })
    }
    
    if from.unit.contains(where: {$0.unit.name == "inch"}) && to.contains(where: {$0.unit.name == "foot"}) {
        let new_value = Double(from.string.toNumber)/12
        new_element.string = String(new_value)
        new_element.unit = from.unit.map({ $0.unit.name == "inch" ? Unit(unit: Units.first(where: {$0.name == "foot"})!, prefix: $0.prefix) : $0 })
    } else if from.unit.contains(where: {$0.unit.name == "foot"}) && to.contains(where: {$0.unit.name == "inch"}) {
        let new_value = 12*Double(from.string.toNumber)
        new_element.string = String(new_value)
        new_element.unit = from.unit.map({ $0.unit.name == "foot" ? Unit(unit: Units.first(where: {$0.name == "inch"})!, prefix: $0.prefix) : $0 })
    }
    if from.unit.contains(where: {$0.unit.name == "inch"}) && to.contains(where: {$0.unit.name == "yard"}) {
        let new_value = Double(from.string.toNumber)/36
        new_element.string = String(new_value)
        new_element.unit = from.unit.map({ $0.unit.name == "inch" ? Unit(unit: Units.first(where: {$0.name == "yard"})!, prefix: $0.prefix) : $0 })
    } else if from.unit.contains(where: {$0.unit.name == "yard"}) && to.contains(where: {$0.unit.name == "inch"}) {
        let new_value = 36*Double(from.string.toNumber)
        new_element.string = String(new_value)
        new_element.unit = from.unit.map({ $0.unit.name == "yard" ? Unit(unit: Units.first(where: {$0.name == "inch"})!, prefix: $0.prefix) : $0 })
    }
    if from.unit.contains(where: {$0.unit.name == "inch"}) && to.contains(where: {$0.unit.name == "mile"}) {
        let new_value = Double(from.string.toNumber)/63360
        new_element.string = String(new_value)
        new_element.unit = from.unit.map({ $0.unit.name == "inch" ? Unit(unit: Units.first(where: {$0.name == "mile"})!, prefix: $0.prefix) : $0 })
    } else if from.unit.contains(where: {$0.unit.name == "mile"}) && to.contains(where: {$0.unit.name == "inch"}) {
        let new_value = 63360*Double(from.string.toNumber)
        new_element.string = String(new_value)
        new_element.unit = from.unit.map({ $0.unit.name == "mile" ? Unit(unit: Units.first(where: {$0.name == "inch"})!, prefix: $0.prefix) : $0 })
    }
    if from.unit.contains(where: {$0.unit.name == "foot"}) && to.contains(where: {$0.unit.name == "yard"}) {
        let new_value = Double(from.string.toNumber)/3
        new_element.string = String(new_value)
        new_element.unit = from.unit.map({ $0.unit.name == "foot" ? Unit(unit: Units.first(where: {$0.name == "yard"})!, prefix: $0.prefix) : $0 })
    } else if from.unit.contains(where: {$0.unit.name == "yard"}) && to.contains(where: {$0.unit.name == "foot"}) {
        let new_value = 3*Double(from.string.toNumber)
        new_element.string = String(new_value)
        new_element.unit = from.unit.map({ $0.unit.name == "yard" ? Unit(unit: Units.first(where: {$0.name == "foot"})!, prefix: $0.prefix) : $0 })
    }
    if from.unit.contains(where: {$0.unit.name == "foot"}) && to.contains(where: {$0.unit.name == "mile"}) {
        let new_value = Double(from.string.toNumber)/5280
        new_element.string = String(new_value)
        new_element.unit = from.unit.map({ $0.unit.name == "foot" ? Unit(unit: Units.first(where: {$0.name == "mile"})!, prefix: $0.prefix) : $0 })
    } else if from.unit.contains(where: {$0.unit.name == "mile"}) && to.contains(where: {$0.unit.name == "foot"}) {
        let new_value = 5280*Double(from.string.toNumber)
        new_element.string = String(new_value)
        new_element.unit = from.unit.map({ $0.unit.name == "mile" ? Unit(unit: Units.first(where: {$0.name == "foot"})!, prefix: $0.prefix) : $0 })
    }
    if from.unit.contains(where: {$0.unit.name == "yard"}) && to.contains(where: {$0.unit.name == "mile"}) {
        let new_value = Double(from.string.toNumber)/1760
        new_element.string = String(new_value)
        new_element.unit = from.unit.map({ $0.unit.name == "yard" ? Unit(unit: Units.first(where: {$0.name == "mile"})!, prefix: $0.prefix) : $0 })
    } else if from.unit.contains(where: {$0.unit.name == "mile"}) && to.contains(where: {$0.unit.name == "yard"}) {
        let new_value = 1760*Double(from.string.toNumber)
        new_element.string = String(new_value)
        new_element.unit = from.unit.map({ $0.unit.name == "mile" ? Unit(unit: Units.first(where: {$0.name == "yard"})!, prefix: $0.prefix) : $0 })
    }
    
    return new_element
}

func doUnitsConversions(calc: inout [CalcElement]) {
    var i = 1
    while i < calc.count-1 {
        if (calc[i].string == "in" || calc[i].string == "to") && calc[i-1].hasUnit && calc[i+1].string.isText {
            let c2 = findUnit(calc: &calc, start: i+1)
            let c1 = unitConversions(calc[i-1], to: c2.unit)
            if sameUnit(c1, c2) {
                let old_unit = c1.unit
                let new_unit = c2.unit
                var new_value = Double(c1.string.toNumber)
                if old_unit.count > 0 && new_unit.count > 0 {
                    for i in 0...old_unit.count-1 {
                        for j in 0...new_unit.count-1 {
                            if old_unit[i].unit.name == new_unit[j].unit.name && old_unit[i].factor == new_unit[j].factor {
                                new_value *= pow(10, Double((old_unit[i].prefix.factor-new_unit[j].prefix.factor))*new_unit[j].factor)
                            }
                        }
                    }
                    //let calc_data: [String: CalcElement] = ["element": calc[i]]
                    //NotificationCenter.default.post(name: Notification.Name(rawValue: "removeColor"), object: nil, userInfo: calc_data)
                    calc[i-1].string = String(new_value)
                    calc[i-1].unit = new_unit
                    calc.removeSubrange(i..<calc.count-1)
                    i-=1
                }
            }
        }
        i+=1
    }
}

func findUnit(calc: inout [CalcElement], start: Int) -> CalcElement {
    var new_calc = Array<CalcElement>(calc[start...calc.count-1])
    new_calc.insert(CalcElement(string: "1", range: NSMakeRange(0, 0)), at: 0)
    doUnits(calc: &new_calc)
    return new_calc[0]
}

func doUnits(calc: inout [CalcElement]) {
    var i = 1
    while i < calc.count {
        if calc[i].string.isText && ((calc[i-1].string.isNumber && !calc[i-1].hasUnit)
                                     || (i > 1 && (calc[i-1].string == "." || calc[i-1].string == "*" || calc[i-1].string == "/") && calc[i-2].hasUnit))
            && (i == calc.count-1 || (calc[i+1].string != "hex" && calc[i+1].string != "dec" && calc[i+1].string != "bin")){
            let isFirst = calc[i-1].string.isNumber && calc[i-1].string != "."
            var unit: UnitName = UnitName(name: "null", symbol: "null", hasPrefix: false)
            var prefix: UnitPrefix = UnitPrefix(name: "null", symbol: "null", factor: 0)
            for u in Units {
                if calc[i].string.suffix(u.symbol.count) == u.symbol {
                    unit = u
                    if u.hasPrefix {
                        for p in Prefixes {
                            if calc[i].string.prefix(calc[i].string.count-u.symbol.count) == p.symbol {
                                prefix = p
                                break;
                            }
                        }
                    }
                    break;
                }
            }
           
            if unit.name != "null" && (prefix.name != "null" || (prefix.name == "null" && unit.symbol == calc[i].string)) {
                if prefix.name == "null" {
                    prefix = Prefixes.first(where: {$0.factor == 0})!
                }
                var ulength = prefix.symbol.count + unit.symbol.count
                var finalUnit = Unit(unit: unit, prefix: prefix)
                if i < calc.count-1 && calc[i+1].string.isInteger {
                    let factor = calc[i+1].string.toNumber
                    ulength += calc[i+1].string.count
                    if factor != 0 {
                        finalUnit.factor = (calc[i-1].string != "/") ? factor : -factor
                        calc[isFirst ? i-1 : i-2].unit.append(finalUnit)
                    }
                    calc[isFirst ? i-1 : i-2].range.length += ulength
                    calc.remove(at: i+1)
                } else if (i < calc.count-2 && (calc[i+1].string == "^" || calc[i+1].string == "^-") && calc[i+2].string.isInteger) {
                    var factor: Double = 0
                    if calc[i+1].string == "^-" {
                        ulength += 2+calc[i+2].string.count
                        factor = -calc[i+2].string.toNumber
                    } else {
                        ulength += 1+calc[i+2].string.count
                        factor = calc[i+2].string.toNumber
                    }
                    if factor != 0 {
                        finalUnit.factor = (calc[i-1].string != "/") ? factor : -factor
                        calc[isFirst ? i-1 : i-2].unit.append(finalUnit)
                    }
                    calc[isFirst ? i-1 : i-2].range.length = ulength
                    calc.remove(at: i+2)
                    calc.remove(at: i+1)
                } else {
                    if calc[i-1].string == "/" {
                        finalUnit.factor = -1
                    }
                    calc[isFirst ? i-1 : i-2].unit.append(finalUnit)
                    calc[isFirst ? i-1 : i-2].range.length = ulength
                }
                arrangeUnits(&calc[isFirst ? i-1 : i-2])
                calc.remove(at: i)
                i-=1
                if !isFirst {
                    calc.remove(at: i)
                    i-=1
                }
            }
        }
        i+=1
    }
}

func sameUnit(_ x: CalcElement, _ y: CalcElement) -> Bool {
    var sameUnit = true
    for i in x.unit {
        var found = false
        for j in y.unit {
            if i.unit.name == j.unit.name && i.factor == j.factor {
                found = true
            }
        }
        if !found {
            sameUnit = false
            break;
        }
    }
    return sameUnit
}

func arrangeUnits(_ x: inout CalcElement) {
    var i = 0
    while i < x.unit.count {
        if i+1 <= x.unit.count-1 {
            for j in i+1...x.unit.count-1 {
                if x.unit[i].unit.name == x.unit[j].unit.name {
                    let p1 = x.unit[i].prefix
                    let p2 = x.unit[j].prefix
                    let f1 = x.unit[i].factor
                    let f2 = x.unit[j].factor
                    let factor1 = f1*Double(p1.factor)
                    let factor2 = f2*Double(p2.factor)
                    
                    var value = Double(x.string.toNumber) * pow(10, factor1+factor2)
                    
                    x.unit[i].factor = x.unit[i].factor+x.unit[j].factor
                    x.string = String(value)
                    x.unit[i].prefix = Prefixes.first(where: {$0.factor == 0})!
                    
                    if x.unit[i].factor != 0 {
                        if value < 1 {
                            var k = 0
                            while value * pow(10, Double(3*k)*(f1+f2)) < 1  && -3*k >= Prefixes.map({ $0.factor }).min()! {
                                k += 1
                            }
                            value = value * pow(10, Double(3*k)*(f1+f2))
                            if let index = Prefixes.firstIndex(where: {$0.factor == -3*k}) {
                                let np = Prefixes[index]
                                x.string = String(value)
                                x.unit[i].prefix = np
                            }
                        } else if value > pow(10, Double(3*(f1+f2))) {
                            var k = 0
                            while value * pow(10, Double(Double(-3*k)*(f1+f2))) > pow(10, 3*(f1+f2)) && 3*k <= Prefixes.map({ $0.factor }).max()! {
                                k += 1
                            }
                            value = value * pow(10, Double(Double(-3*k)*(f1+f2)))
                            if let index = Prefixes.firstIndex(where: {$0.factor == 3*k}) {
                                let np = Prefixes[index]
                                x.string = String(value)
                                x.unit[i].prefix = np
                            }
                        }
                    }
                    x.unit.remove(at: j)
                }
            }
        }
        i += 1
    }
}
