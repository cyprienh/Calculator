
import Cocoa
import Numerics

func parseLine(_ line: String) -> [CalcElement] {
    var values: [CalcElement] = []
    var lastIndex = 0
    var type = -1
    var current = ""
    var range_2 = NSMakeRange(0, 0)
    
    for i in 0...line.count-1 {     // For each char in line
        let char = String(line[line.index(line.startIndex, offsetBy: i)])
        if shouldChange(char: char, type: type) {       // If char if of new type: i-1 -> "1" & i -> "+" => true
            if current != "" {                          // First char should always change byt let's not add nothing to values
                values.append(CalcElement(string: current, range: range_2))
            }
            lastIndex = i
            
            if char == " " {
                type = 0
            } else if char.isDouble {
                type = 1
            }  else if char.isOperator {
                type = 3
            }  else {
                type = 2
            }
        }
        let start = line.index(line.startIndex, offsetBy: lastIndex)            // Kinda stupid to redefine the starting index every time
        let end = line.index(line.endIndex, offsetBy: -(line.count-i-1))
        let range = start..<end
        range_2 = NSMakeRange(lastIndex, i+1-lastIndex)

        let substr = String(line[range])
        current = substr
    }
    if current != "" {          // If all line is same type, append everything at the end
        values.append(CalcElement(string: current, range: range_2))
    }
    return values               // Initial calc is done for this line, yay
}

func shouldChange(char: String, type: Int) -> Bool {
    return (char.isDouble && type != 1)
                || (char.isOperator && (type != 3))
                || (char == " " && type != 0)
                || (!char.isDouble && !char.isOperator && char != " " && type != 2)
}
