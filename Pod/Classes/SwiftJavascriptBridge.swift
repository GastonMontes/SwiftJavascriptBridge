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
    private func dataToJSONString(jsonData: AnyObject!) -> String? {
        if (NSJSONSerialization.isValidJSONObject(jsonData)) {
            do {
                let jsonData = try NSJSONSerialization.dataWithJSONObject(jsonData, options: NSJSONWritingOptions())
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
        } else if let aString = functionArguments as? String {
            functionName += "(\"" + aString + "\")"
        } else if let aDouble = functionArguments as? Double {
            if (aDouble % 1 > 0) {
                // Is a Double.
                functionName = String(format: "%@(\"%.9f\")", functionName, aDouble)
            } else {
                // Is an Int.
                functionName = String(format: "%@(\"%.0f\")", functionName, aDouble)
            }
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
    /**
    Add Swift 'handlerName' handler. Until bridgeLoadScriptFromURL() not called,
    bridgeAddHandler is going to have no effect.
    bridgeAddHandler() function can be called at any time, even before the page 
    it is loaded.
    
    - Parameters:
        - handlerName: The name of the Swift handler to add.
        - handlerClosure: The closure (block code) that is going to be called when
    JavaScript call the Swift 'handlerName' handler.
    */
    public func bridgeAddHandler(handlerName: String, handlerClosure: HandlerClosure) {
        self.handlersDictionary[handlerName] = handlerClosure;
        self.jsWebViewConfiguration.userContentController.addScriptMessageHandler(self, name: handlerName)
    }
    
    /**
    Remove Swift 'handlerName' handler. Until bridgeLoadScriptFromURL() not called, 
    bridgeRemoveHandler is going to have no effect.
    
    - Parameters:
        - handlerName: The name of the Swift handler to remove.
    */
    public func bridgeRemoveHandler(handlerName: String) {
        self.handlersDictionary.removeValueForKey(handlerName)
        self.jsWebViewConfiguration.userContentController.removeScriptMessageHandlerForName(handlerName)
    }
    
    /**
    Call the JavasCript function called 'jsFunctionName'. 'jsFunctionName' must be 
    declared in the page loaded in bridgeLoadScriptFromURL() function or the call 
    is going to have no effect.
    bridgeCallHandler() function can be called at any time, even before the page 
    it is loaded.
    
    - Parameters:
        - jsFunctionName: The JavasCript function name to call. The 'jsFunctionName'
    function name should not have parentheses.
        - data: An object that must be converted to a JSON data object. 'data' must 
    have the following properties:
            - Top level object is an Array or Dictionary
            - All objects are String, Double, Int or Float.
            - All dictionary keys are Strings.
            - Be a Double, Float, Int or String.
    */
    public func bridgeCallFunction(jsFunctionName: String, data: AnyObject?) {
        let handler: NSMutableDictionary = [kJSHandlerNameKey : jsFunctionName]
        if (data != nil) {
            handler.setObject(data!, forKey: kJSDataToSendKey)
        }
        
        if (self.jsWebView != nil && self.jsWebView?.loading == false) {
            self.callJSFunction(handler as NSDictionary)
        } else {
            self.jsHandlersList.addObject(handler as NSDictionary)
        }
    }
    
    /** 
    Load the 'urlString's' page that contains JavasCript code. After the page load,
    JavasCript functions can call Swift handlers and Swift function can call
    JavasCript functions.
    
    - Parameters:
        - urlString: The string of the URL to load.
    */
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
