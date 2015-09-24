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

public typealias HandlerClosure = (data: AnyObject?) -> Void

// MARK: - Constants.
private let kJSDataToSendKey: String = "data"
private let kJSHandlerNameKey: String = "name"
private let kURLNotValidErrorText: String = "Bridge URL is not a valid URL: %@\n"
private let kEvaluateScriptErrorText: String = "SwiftJavascriptBridge - EvaluateJavaScript Error: "
private let kJSONDataCreationErrorText: String = "SwiftJavascriptBridge - JSON data creation Error: "

// WKNavigationDelegate, WKUIDelegate
public class SwiftJavascriptBridge: NSObject, WKScriptMessageHandler, WKNavigationDelegate {
    
    // MARK: - Vars.
    private let jsWebViewConfiguration = WKWebViewConfiguration()
    private var jsWebView: WKWebView?
    private var handlersDictionary = [String: HandlerClosure]()
    private var jsHandlersList = NSMutableArray()
    
    // MARK: - WKScriptMessageHandler implementation.
    public func userContentController(userContentController: WKUserContentController, didReceiveScriptMessage message: WKScriptMessage) {
        // The name of the message handler to which the message is sent.
        let messageHandlerName = String(message.name)
        let messageBody   = message.body;
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
    
    // MARK: - Private Methods.
    private func dataToJSONString(jsonDictionary: AnyObject!) -> String? {
        if (NSJSONSerialization.isValidJSONObject(jsonDictionary)) {
            do {
                let jsonData = try NSJSONSerialization.dataWithJSONObject(jsonDictionary, options: NSJSONWritingOptions())
                let dataString = NSString(data: jsonData, encoding: NSASCIIStringEncoding)!
                return dataString as String
            } catch {
                print(kJSONDataCreationErrorText + String(error))
                return nil
            }
        }
        
        return nil
    }
    
    private func createJSFunctionName(jsFunctionName: String, functionArguments: AnyObject?) -> String {
        var functionName = String(jsFunctionName)
        
        if (functionArguments?.count > 0) {
            functionName += "(\(dataToJSONString(functionArguments!)!))"
        } else {
            functionName += "()"
        }
        
        return functionName
    }
    
    private func callJSFunction(jsHandler: NSDictionary) {
        let handlerName: String = jsHandler.objectForKey(kJSHandlerNameKey) as! String
        let handleData: AnyObject? = jsHandler.objectForKey(kJSDataToSendKey)
        
        let functionName = String(self.createJSFunctionName(handlerName, functionArguments: handleData))
        
        self.jsWebView?.evaluateJavaScript(functionName, completionHandler: { (response : AnyObject?, error: NSError?) -> Void in
            if (error != nil) {
                print(kEvaluateScriptErrorText + functionName + " - " + String(error))
            }
        })
    }
    
    // MARK: - WKNavigationDelegate implementation.
    public func webView(webView: WKWebView, didFinishNavigation navigation: WKNavigation!) {
        for jsHandler in self.jsHandlersList {
            self.callJSFunction(jsHandler as! NSDictionary)
        }
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
    
    public func bridgeCallHandler(jsHandlerName: String, data: AnyObject?) {
        let handler: NSMutableDictionary = [kJSHandlerNameKey : jsHandlerName]
        
        if (data != nil) {
            handler.setObject(data!, forKey: kJSDataToSendKey)
        }
        
        if (self.jsWebView != nil && self.jsWebView?.loading == false) {
            self.callJSFunction(handler as NSDictionary)
        } else {
            self.jsHandlersList.addObject(handler as NSDictionary)
        }
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
}
