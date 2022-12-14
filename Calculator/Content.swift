//
//  CalcDocument.swift
//  Calculator
//
//  Created by Cyprien Heusse on 20/06/2022.
//

import Cocoa

class Content: NSObject {
    @objc dynamic var contentString = ""
    
    public init(contentString: String) {
        self.contentString = contentString
    }
    
}

extension Content {
    
    func read(from data: Data) {
        contentString = String(bytes: data, encoding: .utf8)!
    }
    
    func data() -> Data? {
        return contentString.data(using: .utf8)
    }
    
}
