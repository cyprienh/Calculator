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
    let base: Int
}

struct UnitName {
    let name: String
    let symbol: String
    let hasPrefix: Bool
    let canFactor: Bool
}

struct Unit {
    var unit: UnitName
    var prefix: UnitPrefix
    var factor: Double = 1
}

let Prefixes: [UnitPrefix] = [
    UnitPrefix(name: "yotta", symbol: "Y", factor: 24, base: 10),
    UnitPrefix(name: "zetta", symbol: "Z", factor: 21, base: 10),
    UnitPrefix(name: "exa", symbol: "E", factor: 18, base: 10),
    UnitPrefix(name: "peta", symbol: "P", factor: 15, base: 10),
    UnitPrefix(name: "tera", symbol: "T", factor: 12, base: 10),
    UnitPrefix(name: "giga", symbol: "G", factor: 9, base: 10),
    UnitPrefix(name: "mega", symbol: "M", factor: 6, base: 10),
    UnitPrefix(name: "kilo", symbol: "k", factor: 3, base: 10),
    UnitPrefix(name: "hecto", symbol: "h", factor: 2, base: 10),
    UnitPrefix(name: "deca", symbol: "da", factor: 1, base: 10),
    UnitPrefix(name: "", symbol: "", factor: 0, base: 10),
    UnitPrefix(name: "deci", symbol: "d", factor: -1, base: 10),
    UnitPrefix(name: "centi", symbol: "c", factor: -2, base: 10),
    UnitPrefix(name: "milli", symbol: "m", factor: -3, base: 10),
    UnitPrefix(name: "micro", symbol: "u", factor: -6, base: 10),
    UnitPrefix(name: "micro", symbol: "μ", factor: -6, base: 10),
    UnitPrefix(name: "nano", symbol: "n", factor: -9, base: 10),
    UnitPrefix(name: "pico", symbol: "p", factor: -12, base: 10),
    UnitPrefix(name: "femto", symbol: "f", factor: -15, base: 10),
    
    UnitPrefix(name: "exbi", symbol: "Ei", factor: 60, base: 2),
    UnitPrefix(name: "pebi", symbol: "Pi", factor: 50, base: 2),
    UnitPrefix(name: "tebi", symbol: "Ti", factor: 40, base: 2),
    UnitPrefix(name: "gibi", symbol: "Gi", factor: 30, base: 2),
    UnitPrefix(name: "mebi", symbol: "Mi", factor: 20, base: 2),
    UnitPrefix(name: "kibi", symbol: "Ki", factor: 10, base: 2),
]


let Units: [UnitName] = [
    UnitName(name: "bit", symbol: "bit", hasPrefix: true, canFactor: false),
    UnitName(name: "mole", symbol: "mol", hasPrefix: true, canFactor: true),
    UnitName(name: "hertz", symbol: "Hz", hasPrefix: true, canFactor: true),
    UnitName(name: "weber", symbol: "Wb", hasPrefix: true, canFactor: true),
    UnitName(name: "mile", symbol: "mi", hasPrefix: false, canFactor: true),
    UnitName(name: "yard", symbol: "yd", hasPrefix: false, canFactor: true),
    UnitName(name: "foot", symbol: "ft", hasPrefix: false, canFactor: true),
    UnitName(name: "inch", symbol: "in", hasPrefix: false, canFactor: true),
    UnitName(name: "pound", symbol: "lb", hasPrefix: false, canFactor: true),
    UnitName(name: "ounce", symbol: "oz", hasPrefix: false, canFactor: true),
    UnitName(name: "fahrenheit", symbol: "°F", hasPrefix: false, canFactor: false),
    UnitName(name: "celsius", symbol: "°C", hasPrefix: false, canFactor: false),
    UnitName(name: "meter", symbol: "m", hasPrefix: true, canFactor: true),
    UnitName(name: "liter", symbol: "L", hasPrefix: true, canFactor: true),
    UnitName(name: "second", symbol: "s", hasPrefix: true, canFactor: true),
    UnitName(name: "gram", symbol: "g", hasPrefix: true, canFactor: true),
    UnitName(name: "newton", symbol: "N", hasPrefix: true, canFactor: true),
    UnitName(name: "joule", symbol: "J", hasPrefix: true, canFactor: true),
    UnitName(name: "watt", symbol: "W", hasPrefix: true, canFactor: true),
    UnitName(name: "kelvin", symbol: "K", hasPrefix: true, canFactor: false),
    UnitName(name: "ampere", symbol: "A", hasPrefix: true, canFactor: true),
    UnitName(name: "coulomb", symbol: "C", hasPrefix: true, canFactor: true),
    UnitName(name: "volt", symbol: "V", hasPrefix: true, canFactor: true),
    UnitName(name: "ohm", symbol: "Ω", hasPrefix: true, canFactor: true),
    UnitName(name: "farad", symbol: "F", hasPrefix: true, canFactor: true),
    UnitName(name: "siemens", symbol: "S", hasPrefix: true, canFactor: true),
    UnitName(name: "henry", symbol: "H", hasPrefix: true, canFactor: true),
    UnitName(name: "tesla", symbol: "T", hasPrefix: true, canFactor: true),
    UnitName(name: "byte", symbol: "B", hasPrefix: true, canFactor: false),
    UnitName(name: "byte", symbol: "o", hasPrefix: true, canFactor: false),
    UnitName(name: "bit", symbol: "b", hasPrefix: true, canFactor: false),
    UnitName(name: "foot", symbol: "'", hasPrefix: false, canFactor: true),
    UnitName(name: "inch", symbol: "\"", hasPrefix: false, canFactor: true),
    UnitName(name: "degree", symbol: "°", hasPrefix: false, canFactor: true),
    UnitName(name: "degree", symbol: "deg", hasPrefix: false, canFactor: true),     // FIXME: doesn't work ???
    UnitName(name: "radian", symbol: "rad", hasPrefix: false, canFactor: true)
]

func unitConversions(_ from: CalcElement, to: [Unit]) -> CalcElement {
    var new_element = from
    new_element.toDouble()

    if from.unit.contains(where: {$0.unit.name == "celsius"}) && to.contains(where: {$0.unit.name == "fahrenheit"}) {
        if from.unit.first(where: {$0.unit.name == "celsius"})?.factor == to.first(where: {$0.unit.name == "fahrenheit"})?.factor
            && from.unit.first(where: {$0.unit.name == "celsius"})?.factor == 1 {
            new_element.real = 9/5*from.getDouble+32
            new_element.unit = from.unit.map({ $0.unit.name == "celsius" ? Unit(unit: Units.first(where: {$0.name == "fahrenheit"})!, prefix: $0.prefix) : $0 })
        } else {
            new_element.error = Constants.CONVERSION_ERROR;
        }
    } else if from.unit.contains(where: {$0.unit.name == "fahrenheit"}) && to.contains(where: {$0.unit.name == "celsius"}) {
        if from.unit.first(where: {$0.unit.name == "fahrenheit"})?.factor == to.first(where: {$0.unit.name == "celsius"})?.factor
            && from.unit.first(where: {$0.unit.name == "fahrenheit"})?.factor == 1 {
            new_element.real = 5/9*(from.getDouble-32)
            new_element.unit = from.unit.map({ $0.unit.name == "fahrenheit" ? Unit(unit: Units.first(where: {$0.name == "celsius"})!, prefix: $0.prefix) : $0 })
        } else {
            new_element.error = Constants.CONVERSION_ERROR;
        }
    }
    if from.unit.contains(where: {$0.unit.name == "degree"}) && to.contains(where: {$0.unit.name == "radian"}) {
        if from.unit.first(where: {$0.unit.name == "degree"})?.factor == to.first(where: {$0.unit.name == "radian"})?.factor
            && from.unit.first(where: {$0.unit.name == "degree"})?.factor == 1 {
            new_element.real = from.getDouble*Double.pi/180.0
            new_element.unit = from.unit.map({ $0.unit.name == "degree" ? Unit(unit: Units.first(where: {$0.name == "radian"})!, prefix: $0.prefix) : $0 })
        } else {
            new_element.error = Constants.CONVERSION_ERROR;
        }
    } else if from.unit.contains(where: {$0.unit.name == "radian"}) && to.contains(where: {$0.unit.name == "degree"}) {
        if from.unit.first(where: {$0.unit.name == "radian"})?.factor == to.first(where: {$0.unit.name == "degree"})?.factor
            && from.unit.first(where: {$0.unit.name == "radian"})?.factor == 1 {
            new_element.real = from.getDouble*180.0/Double.pi
            new_element.unit = from.unit.map({ $0.unit.name == "radian" ? Unit(unit: Units.first(where: {$0.name == "degree"})!, prefix: $0.prefix) : $0 })
        } else {
            new_element.error = Constants.CONVERSION_ERROR;
        }
    }
    if from.unit.contains(where: {$0.unit.name == "celsius"}) && to.contains(where: {$0.unit.name == "kelvin"}) {
        if from.unit.first(where: {$0.unit.name == "celsius"})?.factor == to.first(where: {$0.unit.name == "kelvin"})?.factor
            && from.unit.first(where: {$0.unit.name == "celsius"})?.factor == 1 {
            new_element.real = from.getDouble+273.15
            new_element.unit = from.unit.map({ $0.unit.name == "celsius" ? Unit(unit: Units.first(where: {$0.name == "kelvin"})!, prefix: $0.prefix) : $0 })
        } else {
            new_element.error = Constants.CONVERSION_ERROR;
        }
    } else if from.unit.contains(where: {$0.unit.name == "kelvin"}) && to.contains(where: {$0.unit.name == "celsius"}) {
        if from.unit.first(where: {$0.unit.name == "kelvin"})?.factor == to.first(where: {$0.unit.name == "celsius"})?.factor {
            if from.unit.first(where: {$0.unit.name == "kelvin"})?.factor == 1 {
                new_element.real = from.getDouble-273.15
                new_element.unit = from.unit.map({ $0.unit.name == "kelvin" ? Unit(unit: Units.first(where: {$0.name == "celsius"})!, prefix: $0.prefix) : $0 })
            }
        }
    }
    if from.unit.contains(where: {$0.unit.name == "kelvin"}) && to.contains(where: {$0.unit.name == "fahrenheit"}) {
        if from.unit.first(where: {$0.unit.name == "kelvin"})?.factor == to.first(where: {$0.unit.name == "fahrenheit"})?.factor
            && from.unit.first(where: {$0.unit.name == "kelvin"})?.factor == 1 {
            new_element.real = 9/5*(from.getDouble-273.15)+32
            new_element.unit = from.unit.map({ $0.unit.name == "kelvin" ? Unit(unit: Units.first(where: {$0.name == "fahrenheit"})!, prefix: $0.prefix) : $0 })
        } else {
            new_element.error = Constants.CONVERSION_ERROR;
        }
    } else if from.unit.contains(where: {$0.unit.name == "fahrenheit"}) && to.contains(where: {$0.unit.name == "kelvin"}) {
        if from.unit.first(where: {$0.unit.name == "fahrenheit"})?.factor == to.first(where: {$0.unit.name == "kelvin"})?.factor
            && from.unit.first(where: {$0.unit.name == "fahrenheit"})?.factor == 1 {
            new_element.real = 5/9*(from.getDouble-32)+273.15
            new_element.unit = from.unit.map({ $0.unit.name == "fahrenheit" ? Unit(unit: Units.first(where: {$0.name == "kelvin"})!, prefix: $0.prefix) : $0 })
        } else {
            new_element.error = Constants.CONVERSION_ERROR;
        }
    }
    
    if from.unit.contains(where: {$0.unit.name == "byte"}) && to.contains(where: {$0.unit.name == "bit"}) {
        if from.unit.first(where: {$0.unit.name == "byte"})?.factor == to.first(where: {$0.unit.name == "bit"})?.factor
            && from.unit.first(where: {$0.unit.name == "byte"})?.factor == 1 {
            new_element.real = 8*from.getDouble
            new_element.unit = from.unit.map({ $0.unit.name == "byte" ? Unit(unit: Units.first(where: {$0.name == "bit"})!, prefix: $0.prefix) : $0 })
        } else {
            new_element.error = Constants.CONVERSION_ERROR;
        }
    } else if from.unit.contains(where: {$0.unit.name == "bit"}) && to.contains(where: {$0.unit.name == "byte"}) {
        if from.unit.first(where: {$0.unit.name == "bit"})?.factor == to.first(where: {$0.unit.name == "byte"})?.factor
            && from.unit.first(where: {$0.unit.name == "bit"})?.factor == 1 {
            new_element.real = from.getDouble/8
            new_element.unit = from.unit.map({ $0.unit.name == "bit" ? Unit(unit: Units.first(where: {$0.name == "byte"})!, prefix: $0.prefix) : $0 })
        } else {
            new_element.error = Constants.CONVERSION_ERROR;
        }
    }
    
    if from.unit.contains(where: {$0.unit.name == "inch"}) && to.contains(where: {$0.unit.name == "meter"}) {
        if from.unit.first(where: {$0.unit.name == "inch"})?.factor == to.first(where: {$0.unit.name == "meter"})?.factor {
            let factor = from.unit.first(where: {$0.unit.name == "inch"})?.factor ?? 1.0
            new_element.real = pow(0.0254, factor)*from.getDouble
            new_element.unit = from.unit.map({ $0.unit.name == "inch" ? Unit(unit: Units.first(where: {$0.name == "meter"})!, prefix: $0.prefix, factor: factor) : $0 })
        }
    } else if from.unit.contains(where: {$0.unit.name == "meter"}) && to.contains(where: {$0.unit.name == "inch"}) {
        if from.unit.first(where: {$0.unit.name == "meter"})?.factor == to.first(where: {$0.unit.name == "inch"})?.factor {
            let factor = from.unit.first(where: {$0.unit.name == "meter"})?.factor ?? 1.0
            new_element.real = pow(1/0.0254, factor)*from.getDouble
            new_element.unit = from.unit.map({ $0.unit.name == "meter" ? Unit(unit: Units.first(where: {$0.name == "inch"})!, prefix: $0.prefix, factor: factor) : $0 })
        }
    }
    if from.unit.contains(where: {$0.unit.name == "foot"}) && to.contains(where: {$0.unit.name == "meter"}) {
        if from.unit.first(where: {$0.unit.name == "foot"})?.factor == to.first(where: {$0.unit.name == "meter"})?.factor {
            let factor = from.unit.first(where: {$0.unit.name == "foot"})?.factor ?? 1.0
            new_element.real = pow(0.3048, factor)*from.getDouble
            new_element.unit = from.unit.map({ $0.unit.name == "foot" ? Unit(unit: Units.first(where: {$0.name == "meter"})!, prefix: $0.prefix, factor: factor) : $0 })
        }
    } else if from.unit.contains(where: {$0.unit.name == "meter"}) && to.contains(where: {$0.unit.name == "foot"}) {
        if from.unit.first(where: {$0.unit.name == "meter"})?.factor == to.first(where: {$0.unit.name == "foot"})?.factor {
            let factor = from.unit.first(where: {$0.unit.name == "meter"})?.factor ?? 1.0
            new_element.real = pow(1/0.3048, factor)*from.getDouble
            new_element.unit = from.unit.map({ $0.unit.name == "meter" ? Unit(unit: Units.first(where: {$0.name == "foot"})!, prefix: $0.prefix, factor: factor) : $0 })
        }
    }
    if from.unit.contains(where: {$0.unit.name == "yard"}) && to.contains(where: {$0.unit.name == "meter"}) {
        if from.unit.first(where: {$0.unit.name == "yard"})?.factor == to.first(where: {$0.unit.name == "meter"})?.factor {
            let factor = from.unit.first(where: {$0.unit.name == "yard"})?.factor ?? 1.0
            new_element.real = pow(0.9144, factor)*from.getDouble
            new_element.unit = from.unit.map({ $0.unit.name == "yard" ? Unit(unit: Units.first(where: {$0.name == "meter"})!, prefix: $0.prefix, factor: factor) : $0 })
        }
    } else if from.unit.contains(where: {$0.unit.name == "meter"}) && to.contains(where: {$0.unit.name == "yard"}) {
        if from.unit.first(where: {$0.unit.name == "meter"})?.factor == to.first(where: {$0.unit.name == "yard"})?.factor {
            let factor = from.unit.first(where: {$0.unit.name == "meter"})?.factor ?? 1.0
            new_element.real = pow(1/0.9144, factor)*from.getDouble
            new_element.unit = from.unit.map({ $0.unit.name == "meter" ? Unit(unit: Units.first(where: {$0.name == "yard"})!, prefix: $0.prefix, factor: factor) : $0 })
        }
    }
    if from.unit.contains(where: {$0.unit.name == "mile"}) && to.contains(where: {$0.unit.name == "meter"}) {
        if from.unit.first(where: {$0.unit.name == "mile"})?.factor == to.first(where: {$0.unit.name == "meter"})?.factor {
            let factor = from.unit.first(where: {$0.unit.name == "mile"})?.factor ?? 1.0
            new_element.real = pow(1609.3, factor)*from.getDouble
            new_element.unit = from.unit.map({ $0.unit.name == "mile" ? Unit(unit: Units.first(where: {$0.name == "meter"})!, prefix: $0.prefix, factor: factor) : $0 })
        }
    } else if from.unit.contains(where: {$0.unit.name == "meter"}) && to.contains(where: {$0.unit.name == "mile"}) {
        if from.unit.first(where: {$0.unit.name == "meter"})?.factor == to.first(where: {$0.unit.name == "mile"})?.factor {
            let factor = from.unit.first(where: {$0.unit.name == "meter"})?.factor ?? 1.0
            new_element.real = pow(1/1609.3, factor)*from.getDouble
            new_element.unit = from.unit.map({ $0.unit.name == "meter" ? Unit(unit: Units.first(where: {$0.name == "mile"})!, prefix: $0.prefix, factor: factor) : $0 })
        }
    }
    
    if from.unit.contains(where: {$0.unit.name == "inch"}) && to.contains(where: {$0.unit.name == "foot"}) {
        if from.unit.first(where: {$0.unit.name == "inch"})?.factor == to.first(where: {$0.unit.name == "foot"})?.factor {
            let factor = from.unit.first(where: {$0.unit.name == "inch"})?.factor ?? 1.0
            new_element.real = from.getDouble/pow(12, factor)
            new_element.unit = from.unit.map({ $0.unit.name == "inch" ? Unit(unit: Units.first(where: {$0.name == "foot"})!, prefix: $0.prefix, factor: factor) : $0 })
        }
    } else if from.unit.contains(where: {$0.unit.name == "foot"}) && to.contains(where: {$0.unit.name == "inch"}) {
        if from.unit.first(where: {$0.unit.name == "foot"})?.factor == to.first(where: {$0.unit.name == "inch"})?.factor {
            let factor = from.unit.first(where: {$0.unit.name == "foot"})?.factor ?? 1.0
            new_element.real = pow(12, factor)*from.getDouble
            new_element.unit = from.unit.map({ $0.unit.name == "foot" ? Unit(unit: Units.first(where: {$0.name == "inch"})!, prefix: $0.prefix, factor: factor) : $0 })
        }
    }
    if from.unit.contains(where: {$0.unit.name == "inch"}) && to.contains(where: {$0.unit.name == "yard"}) {
        if from.unit.first(where: {$0.unit.name == "inch"})?.factor == to.first(where: {$0.unit.name == "yard"})?.factor {
            let factor = from.unit.first(where: {$0.unit.name == "inch"})?.factor ?? 1.0
            new_element.real = from.getDouble/pow(36, factor)
            new_element.unit = from.unit.map({ $0.unit.name == "inch" ? Unit(unit: Units.first(where: {$0.name == "yard"})!, prefix: $0.prefix, factor: factor) : $0 })
        }
    } else if from.unit.contains(where: {$0.unit.name == "yard"}) && to.contains(where: {$0.unit.name == "inch"}) {
        if from.unit.first(where: {$0.unit.name == "yard"})?.factor == to.first(where: {$0.unit.name == "inch"})?.factor {
            let factor = from.unit.first(where: {$0.unit.name == "yard"})?.factor ?? 1.0
            new_element.real = pow(36, factor)*from.getDouble
            new_element.unit = from.unit.map({ $0.unit.name == "yard" ? Unit(unit: Units.first(where: {$0.name == "inch"})!, prefix: $0.prefix, factor: factor) : $0 })
        }
    }
    if from.unit.contains(where: {$0.unit.name == "inch"}) && to.contains(where: {$0.unit.name == "mile"}) {
        if from.unit.first(where: {$0.unit.name == "inch"})?.factor == to.first(where: {$0.unit.name == "mile"})?.factor {
            let factor = from.unit.first(where: {$0.unit.name == "inch"})?.factor ?? 1.0
            new_element.real = from.getDouble/pow(63360, factor)
            new_element.unit = from.unit.map({ $0.unit.name == "inch" ? Unit(unit: Units.first(where: {$0.name == "mile"})!, prefix: $0.prefix, factor: factor) : $0 })
        }
    } else if from.unit.contains(where: {$0.unit.name == "mile"}) && to.contains(where: {$0.unit.name == "inch"}) {
        if from.unit.first(where: {$0.unit.name == "mile"})?.factor == to.first(where: {$0.unit.name == "inch"})?.factor {
            let factor = from.unit.first(where: {$0.unit.name == "mile"})?.factor ?? 1.0
            new_element.real = pow(63360, factor)*from.getDouble
            new_element.unit = from.unit.map({ $0.unit.name == "mile" ? Unit(unit: Units.first(where: {$0.name == "inch"})!, prefix: $0.prefix, factor: factor) : $0 })
        }
    }
    if from.unit.contains(where: {$0.unit.name == "foot"}) && to.contains(where: {$0.unit.name == "yard"}) {
        if from.unit.first(where: {$0.unit.name == "foot"})?.factor == to.first(where: {$0.unit.name == "yard"})?.factor {
            let factor = from.unit.first(where: {$0.unit.name == "foot"})?.factor ?? 1.0
            new_element.real = from.getDouble/pow(3, factor)
            new_element.unit = from.unit.map({ $0.unit.name == "foot" ? Unit(unit: Units.first(where: {$0.name == "yard"})!, prefix: $0.prefix, factor: factor) : $0 })
        }
    } else if from.unit.contains(where: {$0.unit.name == "yard"}) && to.contains(where: {$0.unit.name == "foot"}) {
        if from.unit.first(where: {$0.unit.name == "yard"})?.factor == to.first(where: {$0.unit.name == "foot"})?.factor {
            let factor = from.unit.first(where: {$0.unit.name == "yard"})?.factor ?? 1.0
            new_element.real = pow(3, factor)*from.getDouble
            new_element.unit = from.unit.map({ $0.unit.name == "yard" ? Unit(unit: Units.first(where: {$0.name == "foot"})!, prefix: $0.prefix, factor: factor) : $0 })
        }
    }
    if from.unit.contains(where: {$0.unit.name == "foot"}) && to.contains(where: {$0.unit.name == "mile"}) {
        if from.unit.first(where: {$0.unit.name == "foot"})?.factor == to.first(where: {$0.unit.name == "mile"})?.factor {
            let factor = from.unit.first(where: {$0.unit.name == "foot"})?.factor ?? 1.0
            new_element.real = from.getDouble/pow(5280, factor)
            new_element.unit = from.unit.map({ $0.unit.name == "foot" ? Unit(unit: Units.first(where: {$0.name == "mile"})!, prefix: $0.prefix, factor: factor) : $0 })
        }
    } else if from.unit.contains(where: {$0.unit.name == "mile"}) && to.contains(where: {$0.unit.name == "foot"}) {
        if from.unit.first(where: {$0.unit.name == "mile"})?.factor == to.first(where: {$0.unit.name == "foot"})?.factor {
            let factor = from.unit.first(where: {$0.unit.name == "mile"})?.factor ?? 1.0
            new_element.real = pow(5280, factor)*from.getDouble
            new_element.unit = from.unit.map({ $0.unit.name == "mile" ? Unit(unit: Units.first(where: {$0.name == "foot"})!, prefix: $0.prefix, factor: factor) : $0 })
        }
    }
    if from.unit.contains(where: {$0.unit.name == "yard"}) && to.contains(where: {$0.unit.name == "mile"}) {
        if from.unit.first(where: {$0.unit.name == "yard"})?.factor == to.first(where: {$0.unit.name == "mile"})?.factor {
            let factor = from.unit.first(where: {$0.unit.name == "yard"})?.factor ?? 1.0
            new_element.real = from.getDouble/pow(1760, factor)
            new_element.unit = from.unit.map({ $0.unit.name == "yard" ? Unit(unit: Units.first(where: {$0.name == "mile"})!, prefix: $0.prefix, factor: factor) : $0 })
        }
    } else if from.unit.contains(where: {$0.unit.name == "mile"}) && to.contains(where: {$0.unit.name == "yard"}) {
        if from.unit.first(where: {$0.unit.name == "mile"})?.factor == to.first(where: {$0.unit.name == "yard"})?.factor {
            let factor = from.unit.first(where: {$0.unit.name == "mile"})?.factor ?? 1.0
            new_element.real = pow(1760, factor)*from.getDouble
            new_element.unit = from.unit.map({ $0.unit.name == "mile" ? Unit(unit: Units.first(where: {$0.name == "yard"})!, prefix: $0.prefix, factor: factor) : $0 })
        }
    }
    return new_element
}

func doUnitsConversions(calc: inout [CalcElement]) {
    var i = 1
    while i < calc.count-1 {
        if (calc[i].string == "in" || calc[i].string == "to") && calc[i-1].hasUnit && calc[i+1].string.isText {
            let c2 = findUnit(calc: &calc, start: i+1)
            let c1 = unitConversions(calc[i-1], to: c2.unit)
            if c1.error != Constants.NO_ERROR {
                calc = [c1]
                return
            }
            if sameUnit(c1, c2) {
                let old_unit = c1.unit
                let new_unit = c2.unit
                var new_value = c1.getDouble
                if old_unit.count > 0 && new_unit.count > 0 {
                    for i in 0...old_unit.count-1 {
                        for j in 0...new_unit.count-1 {
                            if old_unit[i].unit.name == new_unit[j].unit.name && old_unit[i].factor == new_unit[j].factor {
                                //new_value *= pow(10, Double((old_unit[i].prefix.factor-new_unit[j].prefix.factor))*new_unit[j].factor)
                                new_value *= pow((pow(Double(old_unit[i].prefix.base), Double(old_unit[i].prefix.factor))/pow(Double(new_unit[j].prefix.base), Double(new_unit[j].prefix.factor))),Double(new_unit[j].factor))
                            }
                        }
                    }
                    //let calc_data: [String: CalcElement] = ["element": calc[i]]
                    //NotificationCenter.default.post(name: Notification.Name(rawValue: "removeColor"), object: nil, userInfo: calc_data)
                    calc[i-1] = CalcElement(string: "", unit: new_unit, isReal: true, real: new_value, range: calc[i-1].range)
                    calc.removeSubrange(i..<calc.count)
                    i-=1
                }
            }
        }
        i+=1
    }
}

func findUnit(calc: inout [CalcElement], start: Int) -> CalcElement {
    var new_calc = Array<CalcElement>(calc[start...calc.count-1])
    new_calc.insert(CalcElement(string: "1", isReal: true, real: 1, range: NSMakeRange(0, 0)), at: 0)
    doUnits(calc: &new_calc)
    return new_calc[0]
}

func getMultiplicationUnit(_ x: [Unit], _ y: [Unit]) -> ([Unit], Double) {
    var c1 = x
    var c2 = y
    var u: [Unit] = []
    var f: Double = 1
    if c1.count > 0 && c2.count > 0 {
        for i in 0...c1.count-1 {
            for j in 0...c2.count-1 {
                if c1[i].unit.name == c2[j].unit.name {
                    if(c1[i].prefix.factor < c2[j].prefix.factor) {
                        c1[i].factor += c2[j].factor
                        f *= pow((pow(Double(c2[j].prefix.base),Double(c2[j].prefix.factor))/pow(Double(c1[i].prefix.base),Double(c1[i].prefix.factor))), y[j].factor)
                        u.append(c1[i])
                    } else {
                        c2[j].factor += c1[i].factor
                        f *= pow((pow(Double(c1[i].prefix.base),Double(c1[i].prefix.factor))/pow(Double(c2[j].prefix.base),Double(c2[j].prefix.factor))), x[i].factor)
                        u.append(c2[j])
                    }
                }
            }
        }
    }
    if c1.count > 0 {
        for i in 0...c1.count-1 {
            if !u.map({ $0.unit.name }).contains(c1[i].unit.name) {
                u.append(c1[i])
            }
        }
    }
    if c2.count > 0 {
        for i in 0...c2.count-1 {
            if !u.map({ $0.unit.name }).contains(c2[i].unit.name) {
                u.append(c2[i])
            }
        }
    }
    return (u, f)
}


// 3mm*dL*K
// 4m/L

func getAdditionUnit(_ x: [Unit], _ y: [Unit]) -> (Bool, Double) {
    var fx: Double = 1
    var fy: Double = 1
    for u in x {
        fx *= pow(pow(Double(u.prefix.base), Double(u.prefix.factor)), u.factor)
    }
    for u in y {
        fy *= pow(pow(Double(u.prefix.base), Double(u.prefix.factor)), u.factor)
    }
    print(fx, fy)
    return (fx > fy, (fx > fy) ? fx/fy : fy/fx)
}

func doUnits(calc: inout [CalcElement]) {
    var i = 1
    while i < calc.count {
        if calc[i].string.isText && ((calc[i-1].hasValue && !calc[i-1].hasUnit)
                                     || (i > 1 && (calc[i-1].string == "." || calc[i-1].string == "*" || calc[i-1].string == "/") && calc[i-2].hasUnit))
            && (i == calc.count-1 || (calc[i+1].string != "hex" && calc[i+1].string != "dec" && calc[i+1].string != "bin")){
            let isFirst = calc[i-1].hasValue && calc[i-1].string != "."
            var unit: UnitName = UnitName(name: "null", symbol: "null", hasPrefix: false, canFactor: false)
            var prefix: UnitPrefix = UnitPrefix(name: "null", symbol: "null", factor: 0, base: 0)
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
            doPowerSeparation(calc: &calc)
            if unit.name != "null" && (prefix.name != "null" || (prefix.name == "null" && unit.symbol == calc[i].string)) {
                if prefix.name == "null" {
                    prefix = Prefixes.first(where: {$0.factor == 0})!
                }
                var ulength = prefix.symbol.count + unit.symbol.count
                var finalUnit = Unit(unit: unit, prefix: prefix)
                if i < calc.count-1 && calc[i+1].isInteger {
                    let factor = Double(calc[i+1].integer)
                    ulength += calc[i+1].string.count
                    if factor != 0 {
                        finalUnit.factor = (calc[i-1].string != "/") ? factor : -factor
                        calc[isFirst ? i-1 : i-2].unit.append(finalUnit)
                    }
                    calc[isFirst ? i-1 : i-2].range.length += ulength
                    calc.remove(at: i+1)
                } else if (i < calc.count-2 && (calc[i+1].string == "^" || calc[i+1].string == "**") && calc[i+2].isInteger) || (i < calc.count-3 && (calc[i+1].string == "**" || calc[i+1].string == "^") && calc[i+2].string == "-" && calc[i+3].isInteger) {
                    var factor: Double = 0
                    if calc[i+1].string == "**" && calc[i+2].string == "-" {
                        ulength += 3+calc[i+3].string.count
                        factor = -Double(calc[i+3].integer)
                        calc.remove(at: i+3)
                    } else if calc[i+1].string == "^" && calc[i+2].string == "-" {
                        ulength += 2+calc[i+3].string.count
                        factor = -Double(calc[i+3].integer)
                        calc.remove(at: i+3)
                    } else {
                        ulength += calc[i+1].string.count+calc[i+2].string.count
                        factor = Double(calc[i+2].integer)
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
                    calc[isFirst ? i-1 : i-2].range.length += ulength
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
                    
                    x.toDouble()
                    var value = Double(x.getDouble) * pow(10, factor1+factor2)
                    
                    x.unit[i].factor = x.unit[i].factor+x.unit[j].factor
                    x.real = value
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
                                x.real = value
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
                                x.real = value
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

func doPowerSeparation(calc: inout [CalcElement]) {
    var i = 0
    while i<calc.count {
        if calc[i].string == "^-" {
            calc.insert(CalcElement(string: "^", range: calc[i].range), at: i)
            calc[i+1].string = "-"
            calc[i+1].range.length -= 1
            calc[i].range.length -= 1
            i+=1
        }
        i+=1
    }
}
