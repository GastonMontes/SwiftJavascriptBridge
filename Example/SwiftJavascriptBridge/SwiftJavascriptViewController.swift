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
    private var messagesFromJS = NSMutableArray()
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
            safeMe?.printMessage("noDataHandler handler called from JS.")
        });
        
        self.bridge.bridgeAddHandler("stringDataHandler", handlerClosure: { (data: AnyObject?) -> Void in
            // Handler that receive a string as data.
            let message = data as! String;
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
            safeMe?.bridge.bridgeCallHandler("swiftCallBackJSFunction", data: dataDic)
        })
        
        self.bridge.bridgeAddHandler("handlerToPrintMessages", handlerClosure: { (data: AnyObject?) -> Void in
            // Handler that receive a message and print it.
            let message = data as! String;
            safeMe?.printMessage(message)
        })
    }
    
    private func callJSFunctions() {
        
    }
    
    // MARK: - View life cycle.
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Register table cells.
        self.messagesTable?.registerNib(UINib(nibName: NSStringFromClass(UITableViewCell), bundle: nil), forCellReuseIdentifier: kCellIdentifier)
        self.messagesTable?.registerClass(UITableViewCell.classForCoder(), forCellReuseIdentifier: kCellIdentifier)
        
        // Add Swift Handlers to bridge. This handlers are going to be called from JS.
        self.addSwiftHandlers()
        
        self.bridge.bridgeLoadScriptFromURL(kJSWebURL)
        
        self.callJSFunctions()
    }
    
    // MARK: - UITableViewDatasource implementation.
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return messagesFromJS.count;
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell: UITableViewCell = tableView.dequeueReusableCellWithIdentifier(kCellIdentifier, forIndexPath: indexPath) as UITableViewCell
        let message = self.messagesFromJS.objectAtIndex(indexPath.row);
        let messageString = message as! String;
        cell.textLabel?.text = messageString;
        return cell
    }
    
    // MARK: - Functions to be print message from JS.
    func printMessage(message: String!) {
        self.messagesFromJS.addObject(message);
        self.messagesTable?.reloadData()
    }
}
