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

public class SwiftJavascriptBridge: NSObject, WKScriptMessageHandler {
    
    // MARK: - Vars.
    private let jsWebViewConfiguration = WKWebViewConfiguration()
    private var jsWebView: WKWebView?
    private var scriptURLString: String?
    private var handlersDictionary = NSMutableDictionary()
    
    // MARK: - WKScriptMessageHandler implementation.
    public func userContentController(userContentController: WKUserContentController, didReceiveScriptMessage message: WKScriptMessage) {
        // The name of the message handler to which the message is sent.
        let messageHandlerName = String(message.name)
        let objectHandler: AnyObject? = self.handlersDictionary.objectForKey(messageHandlerName)
        let handlerSelector = Selector(messageHandlerName);
        
        if (objectHandler?.respondsToSelector(handlerSelector) == true) {
            objectHandler!.performSelector(handlerSelector)
        } else {
            NSLog("Cannot handler function: %@\n", messageHandlerName);
        }
    }
    
    // MARK: - Bridge creation.
    public class func bridgeForURLString() -> SwiftJavascriptBridge {
        let bridge: SwiftJavascriptBridge = SwiftJavascriptBridge()
        return bridge;
    }
    
    // MARK: - Public methods.
    public func bridgeAddHandler(objectHandler: AnyObject, handlerName: String) {
        self.handlersDictionary.setObject(objectHandler, forKey: handlerName)
        self.jsWebViewConfiguration.userContentController.addScriptMessageHandler(self, name: handlerName)
    }
    
    public func bridgeRemoveHandler(handlerName: String) {
        self.handlersDictionary.removeObjectForKey(handlerName);
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
