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
// FIXME: comparison operators with optionals were removed from the Swift Standard Libary.
// Consider refactoring the code to use the non-optional operators.
fileprivate func < <T : Comparable>(lhs: T?, rhs: T?) -> Bool {
  switch (lhs, rhs) {
  case let (l?, r?):
    return l < r
  case (nil, _?):
    return true
  default:
    return false
  }
}

// FIXME: comparison operators with optionals were removed from the Swift Standard Libary.
// Consider refactoring the code to use the non-optional operators.
fileprivate func > <T : Comparable>(lhs: T?, rhs: T?) -> Bool {
  switch (lhs, rhs) {
  case let (l?, r?):
    return l > r
  default:
    return rhs < lhs
  }
}


public typealias HandlerClosure = (_ data: AnyObject?) -> Void

// MARK: - Constants.
private let kJSDataToSendKey: String = "data"
private let kJSHandlerNameKey: String = "name"
private let kURLNotValidErrorText: String = "Bridge URL is not a valid URL: %@\n"
private let kEvaluateScriptErrorText: String = "SwiftJavascriptBridge - EvaluateJavaScript Error: "
private let kJSONDataCreationErrorText: String = "SwiftJavascriptBridge - JSON data creation Error: "

// WKNavigationDelegate, WKUIDelegate
open class SwiftJavascriptBridge: NSObject, WKScriptMessageHandler, WKNavigationDelegate {
    
    // MARK: - Vars.
    fileprivate let jsWebViewConfiguration = WKWebViewConfiguration()
    fileprivate var jsWebView: WKWebView?
    fileprivate var handlersDictionary = [String : HandlerClosure]()
    fileprivate var callBackDictionary = [String : HandlerClosure]()
    fileprivate var jsHandlersList: Array<Dictionary<String, AnyObject>> = Array<Dictionary<String, AnyObject>>()
    
    // MARK: - WKScriptMessageHandler implementation.
    open func userContentController(_ userContentController: WKUserContentController, didReceive message: WKScriptMessage) {
        // The name of the message handler to which the message is sent.
        let messageHandlerName = String(message.name)
        let messageBody   = message.body;
        let closureHandler: HandlerClosure? = self.handlersDictionary[messageHandlerName!]
        
        closureHandler?(messageBody as AnyObject?)
    }
    
    // MARK: - Bridge initialization.
    override init() {
        super.init()
    }
    
    // MARK: - Bridge creation.
    open class func bridge() -> SwiftJavascriptBridge {
        let bridge: SwiftJavascriptBridge = SwiftJavascriptBridge()
        return bridge;
    }
    
    // MARK: - Private Methods.
    fileprivate func dataToJSONString(_ jsonData: AnyObject!) -> String? {
        if (JSONSerialization.isValidJSONObject(jsonData)) {
            do {
                let jsonData = try JSONSerialization.data(withJSONObject: jsonData, options: JSONSerialization.WritingOptions())
                let dataString = String(data: jsonData, encoding: String.Encoding.ascii)!
                return dataString
            } catch {
                print(kJSONDataCreationErrorText + String(describing: error))
                return nil
            }
        }
        
        return nil
    }
    
    fileprivate func createJSFunctionName(_ jsFunctionName: String, functionArguments: AnyObject?) -> String {
        var functionName = String(jsFunctionName)
        
        if (functionArguments?.count > 0) {
            functionName += "(\(dataToJSONString(functionArguments!)!))"
        } else if let aString = functionArguments as? String {
            functionName += "(\"" + aString + "\")"
        } else if let aDouble = functionArguments as? Double {
            if (aDouble.truncatingRemainder(dividingBy: 1) > 0) {
                // Is a Double.
                functionName = String(format: "%@(\"%.9f\")", functionName!, aDouble)
            } else {
                // Is an Int.
                functionName = String(format: "%@(\"%.0f\")", functionName!, aDouble)
            }
        } else {
            functionName += "()"
        }
        
        return functionName!
    }
    
    fileprivate func callJSFunction(_ jsHandler: Dictionary<String, AnyObject>) {
        let handlerName: String = jsHandler[kJSHandlerNameKey] as! String
        let handleData: AnyObject? = jsHandler[kJSDataToSendKey]
        let callBackClosure: HandlerClosure? = self.callBackDictionary[handlerName]
        
        let functionName = String(self.createJSFunctionName(handlerName, functionArguments: handleData))
        
        self.jsWebView?.evaluateJavaScript(functionName!, completionHandler: { (response : AnyObject?, error: NSError?) -> Void in
            if (error != nil) {
                print(kEvaluateScriptErrorText + functionName + " - " + String(error))
            } else {
                if (response != nil && callBackClosure != nil) {
                    callBackClosure!(data: response!)
                }
            }
        })
    }
    
    // MARK: - WKNavigationDelegate implementation.
    open func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        for jsHandler in self.jsHandlersList {
            self.callJSFunction(jsHandler as Dictionary<String, AnyObject>)
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
    open func bridgeAddHandler(_ handlerName: String, handlerClosure: @escaping HandlerClosure) {
        self.handlersDictionary[handlerName] = handlerClosure;
        self.jsWebViewConfiguration.userContentController.add(self, name: handlerName)
    }
    
    /**
    Remove Swift 'handlerName' handler. Until bridgeLoadScriptFromURL() not called, 
    bridgeRemoveHandler is going to have no effect.
    
    - Parameters:
        - handlerName: The name of the Swift handler to remove.
    */
    open func bridgeRemoveHandler(_ handlerName: String) {
        self.handlersDictionary.removeValue(forKey: handlerName)
        self.jsWebViewConfiguration.userContentController.removeScriptMessageHandler(forName: handlerName)
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
        - callBackClosure: The closure (block code) that is going to be called if
    JavaScript function called return something.
    */
    open func bridgeCallFunction(_ jsFunctionName: String, data: AnyObject?, callBackClosure: HandlerClosure?) {
        var handler: Dictionary<String, AnyObject> = [kJSHandlerNameKey : jsFunctionName as AnyObject]
        if (data != nil) {
            handler.updateValue(data!, forKey: kJSDataToSendKey)
        }
        
        if (callBackClosure != nil) {
            self.callBackDictionary[jsFunctionName] = callBackClosure!
        }
        
        if (self.jsWebView != nil && self.jsWebView?.isLoading == false) {
            self.callJSFunction(handler as Dictionary)
        } else {
            self.jsHandlersList.append(handler as Dictionary)
        }
    }
    
    /** 
    Load the 'urlString's' page that contains JavasCript code. After the page load,
    JavasCript functions can call Swift handlers and Swift function can call
    JavasCript functions.
    
    - Parameters:
        - urlString: The string of the URL to load.
    */
    open func bridgeLoadScriptFromURL(_ urlString : String) {
        let url = URL(string: urlString)
        if (url != nil) {
            self.jsWebView = WKWebView(frame: CGRect(x: 0, y: 0, width: 0, height: 0), configuration: self.jsWebViewConfiguration)
            self.jsWebView!.navigationDelegate = self;
            let request = URLRequest(url: url!)
            self.jsWebView!.load(request);
        } else {
            NSLog (kURLNotValidErrorText, urlString)
        }
    }
}
