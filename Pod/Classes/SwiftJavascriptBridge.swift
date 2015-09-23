//
//  SwiftJavascriptBridge.swift
//  Pods
//
//  Created by Gaston Montes on 17/9/15.
//
//

import Foundation
import WebKit
import UIKit

public typealias HandlerClosure = (data: NSDictionary) -> Void

public class SwiftJavascriptBridge: NSObject, WKScriptMessageHandler {
    
    // MARK: - Vars.
    private let jsWebViewConfiguration = WKWebViewConfiguration()
    private var jsWebView: WKWebView?
    private var scriptURLString: String?
    private var handlersDictionary = [String: HandlerClosure]()
    
    // MARK: - WKScriptMessageHandler implementation.
    public func userContentController(userContentController: WKUserContentController, didReceiveScriptMessage message: WKScriptMessage) {
        // The name of the message handler to which the message is sent.
        let messageHandlerName = String(message.name)
        let messageBody   = message.body as! NSDictionary;
        let closureHandler: HandlerClosure? = self.handlersDictionary[messageHandlerName]
        
        closureHandler?(data: messageBody)
    }
    
    // MARK: - Bridge initialization.
    override init() {
        super.init()
    }
    
    // MARK: - Bridge creation.
    public class func bridgeForURLString() -> SwiftJavascriptBridge {
        let bridge: SwiftJavascriptBridge = SwiftJavascriptBridge()
        return bridge;
    }
    
    // MARK: - Public methods.
    public func bridgeAddHandler(handlerName: String, handlerBlock: HandlerClosure) {
        self.handlersDictionary[handlerName] = handlerBlock;
        self.jsWebViewConfiguration.userContentController.addScriptMessageHandler(self, name: handlerName)
    }
    
    public func bridgeRemoveHandler(handlerName: String) {
        self.handlersDictionary.removeValueForKey(handlerName)
        self.jsWebViewConfiguration.userContentController.removeScriptMessageHandlerForName(handlerName)
    }
    
    public func bridgeCallHandler(jsHandlerName: String) {
        
    }
    
    public func bridgeLoadScriptFromURL(urlString : String) {
        self.scriptURLString = urlString;
        
        let url = NSURL(string: self.scriptURLString!)
        if (url != nil) {
            self.jsWebView = WKWebView(frame: CGRectMake(0, 0, 0, 0), configuration: self.jsWebViewConfiguration)
            let request = NSURLRequest(URL: url!)
            self.jsWebView!.loadRequest(request);
        } else {
            NSLog ("Bridge URL is not a valid URL: %@\n", urlString)
        }
    }
}
