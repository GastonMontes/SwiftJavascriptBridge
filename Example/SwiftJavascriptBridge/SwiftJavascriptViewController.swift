//
//  SwiftJavascriptIntegration.swift
//  SwiftJavascriptBridge
//
//  Created by Gaston Montes on 18/9/15.
//  Copyright © 2015 CocoaPods. All rights reserved.
//

import Foundation
import UIKit

class SwiftJavascriptViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    // MARK: - Constants.
    private let kNibName: String = "SwiftJavascriptViewController"
    private let kCellIdentifier = "ExampleCell"
    
    // MARK: - Vars.
    private var messagesFromJS = NSMutableDictionary()
    
    // MARK: - Initialization.
    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: NSBundle?) {
        super.init(nibName:kNibName, bundle:NSBundle.mainBundle())
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    // MARK: - UITableViewDatasource implementation.
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return messagesFromJS.count;
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier(kCellIdentifier, forIndexPath: indexPath) as UITableViewCell
        return cell
    }
}
