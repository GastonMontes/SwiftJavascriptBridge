//
//  SwiftJavascriptIntegration.swift
//  SwiftJavascriptBridge
//
//  Created by Gaston Montes on 18/9/15.
//  Copyright © 2015 CocoaPods. All rights reserved.
//

import Foundation
import UIKit

class SwiftJavascriptViewController: UIViewController {
    
    // MARK: - Constants.
    private let kNibName: String = "SwiftJavascriptViewController"
    
    // MARK: - Initialization.
    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: NSBundle?) {
        super.init(nibName:kNibName, bundle:NSBundle.mainBundle())
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
}
