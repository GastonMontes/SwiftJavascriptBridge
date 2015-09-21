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
    private var jsWebView: WKWebView?
    private let jsWebViewConfiguration = WKWebViewConfiguration()
    private var handlersDictionary = NSMutableDictionary()
    
    // MARK: - Initialization.
    init(urlString urlStr: String) {
        super.init()
        self.initializeWebViewWithURL(urlStr)
    }
    
    // MARK: - Web view methods.
    private func initializeWebViewWithURL(urlString: String) {
        self.jsWebView = WKWebView(frame: CGRectMake(0, 0, 0, 0), configuration: self.jsWebViewConfiguration)
        let url     = NSURL(string: urlString)
        
        if (url != nil) {
            let request = NSURLRequest(URL: url!)
            self.jsWebView!.loadRequest(request);
        } else {
            NSLog ("Bridge URL is not a valid URL: %@\n", urlString)
        }
    }
    
    // MARK: - WKScriptMessageHandler implementation.
    public func userContentController(userContentController: WKUserContentController, didReceiveScriptMessage message: WKScriptMessage) {
        // The name of the message handler to which the message is sent.
        let messageHandlerName = String(message.name)
        let objectHandler: AnyObject? = self.handlersDictionary.objectForKey(messageHandlerName)
        let handlerSelector = Selector(messageHandlerName);
        
        if (objectHandler?.respondsToSelector(handlerSelector) == true) {
            objectHandler!.respondsToSelector(handlerSelector)
        } else {
            NSLog("Cannot handler function: %@\n", messageHandlerName);
        }
    }
    
    // MARK: - Bridge creation.
    public class func bridgeForURLString(urlString: String) -> SwiftJavascriptBridge {
        let bridge: SwiftJavascriptBridge = SwiftJavascriptBridge(urlString: urlString)
        return bridge;
    }
    
    // MARK: - Public methods.
    func bridgeAddHandler(objectHandler: AnyObject, handlerName: String) {
        self.handlersDictionary.setObject(objectHandler, forKey: handlerName)
        self.jsWebViewConfiguration.userContentController.addScriptMessageHandler(self, name: handlerName)
        self.jsWebView = WKWebView(frame: CGRectMake(0, 0, 0, 0), configuration: self.jsWebViewConfiguration)
    }
    
    func bridgeRemoveHandler(handlerName: String) {
        self.handlersDictionary.removeObjectForKey(handlerName);
        self.jsWebViewConfiguration.userContentController.removeScriptMessageHandlerForName(handlerName)
        self.jsWebView = WKWebView(frame: CGRectMake(0, 0, 0, 0), configuration: self.jsWebViewConfiguration)
    }
    
    func bridgeCallHandler(jsHandlerName: String) {
        
    }
}
