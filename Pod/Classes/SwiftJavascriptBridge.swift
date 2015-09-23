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

// WKNavigationDelegate, WKUIDelegate
public class SwiftJavascriptBridge: NSObject, WKScriptMessageHandler, WKNavigationDelegate {
    
    // MARK: - Constants.
    private let kDataToSendKey: String = "data"
    private let kJSHandlerNameKey: String = "name"
    private let kURLNotValidErrorText: String = "Bridge URL is not a valid URL: %@\n"
    
    // MARK: - Vars.
    private let jsWebViewConfiguration = WKWebViewConfiguration()
    private var jsWebView: WKWebView?
    private var handlersDictionary = [String: HandlerClosure]()
    private var callersList = NSMutableArray()
    
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
    public class func bridge() -> SwiftJavascriptBridge {
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
    
    public func bridgeCallHandler(jsHandlerName: String, data: NSDictionary) {
        let handler: NSDictionary = [kDataToSendKey : data, kJSHandlerNameKey : jsHandlerName]
        self.callersList.addObject(handler)
    }
    
    public func bridgeLoadScriptFromURL(urlString : String) {
        let url = NSURL(string: urlString)
        if (url != nil) {
            self.jsWebView = WKWebView(frame: CGRectMake(0, 0, 0, 0), configuration: self.jsWebViewConfiguration)
            self.jsWebView!.navigationDelegate = self;
            let request = NSURLRequest(URL: url!)
            self.jsWebView!.loadRequest(request);
        } else {
            NSLog (kURLNotValidErrorText, urlString)
        }
    }
    
    // MARK: - WKNavigationDelegate implementation.    
    public func webView(webView: WKWebView, didFinishNavigation navigation: WKNavigation!) {
        
        for handlerDict in self.callersList {
            let handlerName: String = handlerDict.objectForKey(kJSHandlerNameKey) as! String
            //            let handlerData = handlerDict.objectForKey(kDataToSendKey) as! NSDictionary
            
            self.jsWebView!.evaluateJavaScript(handlerName, completionHandler: { (response : AnyObject?, error: NSError?) -> Void in
                if (error != nil) {
                    print("Error: " + String(error))
                }
            })
        }
    }
}
