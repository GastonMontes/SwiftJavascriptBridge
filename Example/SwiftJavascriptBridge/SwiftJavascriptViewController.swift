//
//  SwiftJavascriptIntegration.swift
//  SwiftJavascriptBridge
//
//  Created by Gaston Montes on 18/9/15.
//  Copyright © 2015 CocoaPods. All rights reserved.
//

import SwiftJavascriptBridge
import Foundation
import UIKit

class SwiftJavascriptViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    // MARK: - Constants.
    private let kNibName: String = "SwiftJavascriptViewController"
    private let kCellIdentifier = "ExampleCell"
    private let kJSWebURL = "https://dl.dropboxusercontent.com/u/64786881/JSSwiftBridge.html"
    
    // MARK: - Vars.
    private var messagesFromJS: Array<String> = Array<String>()
    private var bridge: SwiftJavascriptBridge = SwiftJavascriptBridge.bridge()
    @IBOutlet weak private var messagesTable: UITableView?
    
    // MARK: - Initialization.
    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: NSBundle?) {
        super.init(nibName:kNibName, bundle:NSBundle.mainBundle())
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    // MARK: - Private methods.
    private func addSwiftHandlers() {
        // Add handlers that are going to be called from JavasCript with messages.
        weak var safeMe = self
        self.bridge.bridgeAddHandler("noDataHandler", handlerClosure: { (data: AnyObject?) -> Void in
            // Handler that receive no data.
            safeMe?.printMessage("JS says: Calling noDataHandler.")
        });
        
        self.bridge.bridgeAddHandler("stringDataHandler", handlerClosure: { (data: AnyObject?) -> Void in
            // Handler that receive a string as data.
            let message = data as! String;
            safeMe?.printMessage(message)
        })
        
        self.bridge.bridgeAddHandler("integerDataHandler", handlerClosure: { (data: AnyObject?) -> Void in
            // Handler that receive a string as data.
            let number = data as! Int
            let message = String(format: "%@ %i.", "JS says: Calling integerDataHandler:", number)
            safeMe?.printMessage(message)
        })
        
        self.bridge.bridgeAddHandler("doubleDataHandler", handlerClosure: { (data: AnyObject?) -> Void in
            // Handler that receive a string as data.
            let number = data as! Double
            let message = String(format: "%@ %.9f", "JS says: Calling doubleDataHandler:", number)
            safeMe?.printMessage(message)
        })
        
        self.bridge.bridgeAddHandler("arrayDataHandler", handlerClosure: { (data: AnyObject?) -> Void in
            // Handler that receive an array as data.
            let listMessages = data as! Array<String>;
            
            for message in listMessages {
                safeMe?.printMessage(message)
            }
        })
        
        self.bridge.bridgeAddHandler("dictionaryDataHandler", handlerClosure: { (data: AnyObject?) -> Void in
            // Handler that receive a dictionary as data.
            let dataDic = data as! Dictionary<String, String>
            safeMe?.printMessage(dataDic["message"])
        })
        
        self.bridge.bridgeAddHandler("callBackToJS", handlerClosure: { (data: AnyObject?) -> Void in
            // Handler that receive a dictionary as data with a message. Prints the message and call 
            // back a JS function with the same dictionary.
            
            // Prints the message.
            let dataDic = data as! Dictionary<String, String>
            safeMe?.printMessage(dataDic["message"])
            
            // Call JS Function with param.
            safeMe?.bridge.bridgeCallFunction("swiftCallBackJSFunction", data: dataDic, callBackClosure: { (data: AnyObject?) -> Void in
                let dataDictionary = data as! Dictionary<String, String>
                let message: String = dataDictionary["message"]! + " (2)"
                safeMe?.printMessage(message)
            })
        })
    }
    
    private func callJSFunctions() {
        // Note: All JS functions then call handlerToPrintMessages handler to print a message.
        weak var safeMe = self
        
        // Call a JS Function without arguments.
        self.bridge.bridgeCallFunction("swiftCallWithNoData", data: nil, callBackClosure: { (data: AnyObject?) -> Void in
            let message = data as! String
            safeMe?.printMessage(message)
        })
        
        // Call a JS Function with a String as arguments.
        let message = String("Swift says: swiftCallWithStringData called.")
        self.bridge.bridgeCallFunction("swiftCallWithStringData", data: message, callBackClosure: { (data: AnyObject?) -> Void in
            let message: String! = data as! String
            safeMe?.printMessage(message)
        })

        // Call a JS Function with an Int as arguments.
        self.bridge.bridgeCallFunction("swiftCallWithIntegerData", data: Int(4), callBackClosure: { (data: AnyObject?) -> Void in
            let integerData = data as! Int
            let message = String(format: "Swift says: swiftCallWithIntegerData called: %i.", integerData)
            safeMe?.printMessage(message)
            
        })

        // Call a JS Function with a Double as arguments.
        self.bridge.bridgeCallFunction("swiftCallWithDoubleData", data: Double(8.32743), callBackClosure: { (data: AnyObject?) -> Void in
            let doubleData = data as! Double
            let message = String(format: "Swift says: swiftCallWithDoubleData called: %.9f.", doubleData)
            safeMe?.printMessage(message)
        })

        // Call a JS Function with an Array as arguments.
        let messages: [String] = ["Swift says: swiftCallWithArrayData called.", "Swift says: swiftCallWithArrayData called. (2)"]
        self.bridge.bridgeCallFunction("swiftCallWithArrayData", data: messages, callBackClosure: { (data: AnyObject?) -> Void in
            let messagesData = data as! [String]
            
            for message: String in messagesData {
                safeMe?.printMessage(message)
            }
        })

        // Call a JS Function with a Dictionary as arguments.
        let messageDict: [String : String] = ["message" : "Swift says: swiftCallWithDictionaryData called."]
        self.bridge.bridgeCallFunction("swiftCallWithDictionaryData", data: messageDict, callBackClosure: { (data: AnyObject?) -> Void in
            let dataDictionary = data as! Dictionary<String, String>
            let message: String! = dataDictionary["message"]
            safeMe?.printMessage(message)
        })
    }
    
    // MARK: - View life cycle.
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Register table cells.
        self.messagesTable?.registerNib(UINib(nibName: String(class_getName(UITableViewCell)), bundle: nil), forCellReuseIdentifier: kCellIdentifier)
        self.messagesTable?.registerClass(UITableViewCell.classForCoder(), forCellReuseIdentifier: kCellIdentifier)
        
        // Add Swift Handlers to bridge. This handlers are going to be called from JS.
        self.addSwiftHandlers()
        
        self.bridge.bridgeLoadScriptFromURL(kJSWebURL)
        
        // Call JS functions.
        self.callJSFunctions()
    }
    
    // MARK: - UITableViewDatasource implementation.
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return messagesFromJS.count;
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell: UITableViewCell = tableView.dequeueReusableCellWithIdentifier(kCellIdentifier, forIndexPath: indexPath) as UITableViewCell
        let message = self.messagesFromJS[indexPath.row];
        let messageString = String(message)
        cell.textLabel?.text = messageString;
        cell.textLabel?.font = UIFont(name: cell.textLabel!.font.fontName, size: 11)
        return cell
    }
    
    // MARK: - Functions to be print message from JS.
    func printMessage(message: String!) {
        self.messagesFromJS.append(message)
        self.messagesTable?.reloadData()
    }
}
