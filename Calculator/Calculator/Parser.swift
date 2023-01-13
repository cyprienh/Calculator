
import Cocoa
import Numerics

/// Parse content of line (convert string to [CalcElement])
/// - Parameters:
///   - line: current line to parse
///   - index: starting index of line in str
/// - Returns: calc array with each type separated
func parseLine(_ line: String, _ index: Int) -> [CalcElement] {
    var values: [CalcElement] = []
    var lastIndex = 0
    var type = -1
    var current = ""
    var range_2 = NSMakeRange(0, 0)
    
    var start: String.Index = line.index(line.startIndex, offsetBy: lastIndex)
    var end: String.Index
    
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
            start = line.index(line.startIndex, offsetBy: lastIndex)
        }
        
        end = line.index(line.endIndex, offsetBy: -(line.count-i-1))
        let range = start..<end
        range_2 = NSMakeRange(index+lastIndex, i+1-lastIndex)

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
