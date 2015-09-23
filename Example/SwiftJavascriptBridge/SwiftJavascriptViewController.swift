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
    
    // MARK: - View life cycle.
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.messagesTable?.registerNib(UINib(nibName: NSStringFromClass(UITableViewCell), bundle: nil), forCellReuseIdentifier: kCellIdentifier)
        self.messagesTable?.registerClass(UITableViewCell.classForCoder(), forCellReuseIdentifier: kCellIdentifier)
        
        let safeMe = self
        self.bridge.bridgeAddHandler("firstFunction", handlerBlock: { (data: NSDictionary) -> Void in
            safeMe.jsFunctionCalled(data)
        });
        
        self.bridge.bridgeAddHandler("secondFunction", handlerBlock: { (data: NSDictionary) -> Void in
            safeMe.jsFunctionCalled(data)
        });
        
        self.bridge.bridgeAddHandler("thirdFunction", handlerBlock: { (data: NSDictionary) -> Void in
            safeMe.jsFunctionCalled(data)
        });
        
        let data: NSDictionary = ["message" : "Message from Swift to JS."]
        self.bridge.bridgeCallHandler("calledFromSwift()", data: data)
        
        self.bridge.bridgeAddHandler("calledBakcFromJS", handlerBlock: { (data: NSDictionary) -> Void in
            let data: NSDictionary = ["message" : "Swift call back call other JS function."]
            safeMe.bridge.bridgeCallHandler("calledFromSwift2()", data: data)
        })
        
        self.bridge.bridgeLoadScriptFromURL(kJSWebURL)
        
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
    
    // MARK: - Functions to be called by JS.
    func jsFunctionCalled(body: NSDictionary) {
        self.messagesFromJS.addObject(body.objectForKey("message")!);
        self.messagesTable?.reloadData()
    }
}
