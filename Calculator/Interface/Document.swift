//
//  Document.swift
//  Calculator
//
//  Created by Cyprien Heusse on 20/06/2022.
//

import Cocoa

class Document: NSDocument {

    @objc var content = Content(contentString: "")
    var contentViewController: ViewController!
    
    override init() {
        super.init()
        // Add your subclass-specific initialization here.
    }
    
    override func canAsynchronouslyWrite(to url: URL, ofType typeName: String, for saveOperation: NSDocument.SaveOperationType) -> Bool {
        return true
    }
    
    // This enables asynchronous reading.
    override class func canConcurrentlyReadDocuments(ofType: String) -> Bool {
        return ofType == "public.plain-text"
    }

    override class var autosavesInPlace: Bool {
        return true
    }
    
    override func makeWindowControllers() {
        let storyboard = NSStoryboard(name: NSStoryboard.Name("Main"), bundle: nil)
        if let windowController =
            storyboard.instantiateController(
                withIdentifier: NSStoryboard.SceneIdentifier("Document Window Controller")) as? NSWindowController {
            addWindowController(windowController)
            
            /*windowController.window?.tabbingMode = .preferred
            
            //windowController.window?.tab.attributedTitle = NSAttributedString(string: "hey", attributes: [NSAttributedString.Key.backgroundColor: NSColor.red])
            //windowController.window?.tab.attributedTitle = NSMutableAttributedString(attributedString: NSAttributedString(string: "Hello"))
            //windowController.window?.tab.setValue(NSMutableAttributedString(attributedString: NSAttributedString(string: "Hello")), forKey: "attributedTitle")
            
            let myFont = NSFont(name: "Fira Code", size: 12)
            var attributes = [NSAttributedString.Key: Any]()
            attributes[NSAttributedString.Key.font] = myFont

            let myTitle = NSMutableAttributedString(string: "Test2", attributes: attributes)// \n to skip a line and make room

            windowController.window?.tab.setValue(myTitle, forKey: "attributedTitle")*/
            
            // Set the view controller's represented object as your document.
            if let contentVC = windowController.contentViewController as? ViewController {
                contentVC.representedObject = content
                contentViewController = contentVC
            }
        }
    }

    override func read(from data: Data, ofType typeName: String) throws {
        content.read(from: data)
    }
    
    override func data(ofType typeName: String) throws -> Data {
        return content.data()!
    }


}

