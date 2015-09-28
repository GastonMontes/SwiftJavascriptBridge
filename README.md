SwiftJavascriptBridge
=====================

[![CI Status](http://img.shields.io/travis/Gaston%20Montes/SwiftJavascriptBridge.svg?style=flat)](https://travis-ci.org/Gaston Montes/SwiftJavascriptBridge)
[![Version](https://img.shields.io/cocoapods/v/SwiftJavascriptBridge.svg?style=flat)](http://cocoapods.org/pods/SwiftJavascriptBridge)
[![License](https://img.shields.io/cocoapods/l/SwiftJavascriptBridge.svg?style=flat)](http://cocoapods.org/pods/SwiftJavascriptBridge)
[![Platform](https://img.shields.io/cocoapods/p/SwiftJavascriptBridge.svg?style=flat)](http://cocoapods.org/pods/SwiftJavascriptBridge)

An iOS bridge for sending messages between Swift and Javascript.

SwiftJavascriptBridge is a Swift interface for bridging between WKWebView (Swift) and WebKit (Javascript).

SwiftJavascriptBridge can be use to send message from Swift to Javascript, from Javascript to Swift or to receive messages in Swift from Javascript or in Javascript from Swift.

## Requirements

| SwiftJavascriptBridge Version |     Minimum iOS Target      |      Minimum OS X Target     |               Notes              |
|:-----------------------------:|:---------------------------:|:----------------------------:|:--------------------------------:|
|             1.0.0             |            iOS 7            |           OS X 10.10.4       |        Xcode 7 is required.      |

## Get Started

- 1) Download Cocoapods
-----------------------
[CocoaPods](http://cocoapods.org) is a dependency manager for iOS, which automates and simplifies the process of using 3rd-party libraries in your projects.

CocoaPods is distributed as a ruby gem, and is installed by running the following commands in Terminal.app:

```ruby
$ sudo gem install cocoapods
$ pod setup
```

- 2) Create Podfile
-------------------
In the project root folder, run the following command to create a Podfile:

```ruby
$ pod init YOURXCODEPROJECTFILE
```

If an `YOURXCODEPROJECTFILE` project file is specified or if there is only a single project file in the current directory, targets will be automatically generated based on targets defined in the project.

- 3) Add dependencies:
An empty Podfile was created, so we are going to add dependencies to the Podfile specifying pods versions:

To use the latest version of a Pod, ommit the version specification:
```ruby
pod 'SwiftJavascriptBridge'
```

Freezing to a specific Pod version:
```ruby
pod 'SwiftJavascriptBridge', '0.0.1'
```

Using `logical` operators:
- `'> 0.1'`, Any version higher than 0.1.
- `'>= 0.1'`, Any version higher or equal to 0.1.
- `'< 0.1'`, Any version lower than 0.1.
- `'<= 0.1'`, Any version lower or equal to 0.1.

Using `optimistic` operators:
- `'~> 0.1.0'`, Version 0.1.0 or higher up to 0.2, not including 0.2.
- `'~> 0.1'`, Version 0.1 or higher up to 1.0, not including 1.0.

- 4) Install dependencies
-------------------------
Install Pods dependencies in your project. Run the following commands:

```ruby
$ pod install
```

From now on, be sure to always open the generated Xcode workspace (.xcworkspace) instead of the project file when building your project.

## Installation

SwiftJavascriptBridge is available through [CocoaPods](http://cocoapods.org). To install it, simply add the following line to your Podfile:

```ruby
pod "SwiftJavascriptBridge"
```

## Communication

- If you **need help**, use [Stack Overflow](http://stackoverflow.com/questions/tagged/swiftjavascriptbridge). (Tag 'swiftjavascriptbridge')
- If you'd like to **ask a general question**, use [Stack Overflow](http://stackoverflow.com/questions/tagged/swiftjavascriptbridge).
- If you **found a bug**, _and can provide steps to reliably reproduce it_, open an issue.
- If you **have a feature request**, open an issue.
- If you **want to contribute**, submit a pull request.
- If you **want to contact** the owner of the project, write an email to [Gastón Montes](<mailto:gastonmontes@hotmail.com>).

## Architecture

### SwiftJavascriptBridge

#### Swift 

- `public func bridgeLoadScriptFromURL(urlString : String)`
- `public func bridgeCallFunction(jsFunctionName: String, data: AnyObject?)`
- `public func bridgeRemoveHandler(handlerName: String)`
- `public func bridgeAddHandler(handlerName: String, handlerClosure: HandlerClosure)`

## API Reference

### Swift API

#### `public func bridgeLoadScriptFromURL(urlString : String)

Load the 'urlString's' page that contains JavasCript code. After the page load, JavasCript functions can call Swift handlers and Swift function can call JavasCript functions.

* `Parameters:
	- urlString: The string of the URL to load.

Example:

```Swift	
var bridge: SwiftJavascriptBridge = SwiftJavascriptBridge.bridge()
self.bridge.bridgeLoadScriptFromURL("URLToLoad")
```

#### `public func bridgeAddHandler(handlerName: String, handlerClosure: HandlerClosure)`

 Add Swift 'handlerName' handler. Until bridgeLoadScriptFromURL() not called, bridgeAddHandler is going to have no effect. bridgeAddHandler() function can be called at any time, even before the page is loaded.
    
* ´Parameters:
	- handlerName: The name of the Swift handler to add.
	- handlerClosure: The closure (block code) that is going to be called when JavaScript call the Swift 'handlerName' handler.

Example:

```Swift	
var bridge: SwiftJavascriptBridge = SwiftJavascriptBridge.bridge()
self.bridge.bridgeAddHandler("aHandlerName", handlerClosure: { (data: AnyObject?) -> Void in
	// Handler called from JS.
	NSLog(@"Handler called from JS.", nil);
});
```

#### `public func bridgeRemoveHandler(handlerName: String)`

Remove Swift 'handlerName' handler. Until bridgeLoadScriptFromURL() not called, bridgeRemoveHandler is going to have no effect.
    
* `Parameters:
	- handlerName: The name of the Swift handler to remove.

Example:

```Swift	
var bridge: SwiftJavascriptBridge = SwiftJavascriptBridge.bridge()
self.bridge.bridgeRemoveHandler("aHandlerName")
```

#### `public func bridgeCallFunction(jsFunctionName: String, data: AnyObject?)`

Call the JavasCript function called 'jsFunctionName'. 'jsFunctionName' must be declared in the page loaded in bridgeLoadScriptFromURL() function or the call is going to have no effect. bridgeCallHandler() function can be called at any time, even before the page it is loaded.

* `Parameters`:
	- jsFunctionName: The JavasCript function name to call. The 'jsFunctionName' function name should not have parentheses.
	- data: An object that must be converted to a JSON data object. 'data' must have the following properties:
		+ Top level object is an Array or Dictionary
        + All objects are String, Double, Int or Float.
		+ All dictionary keys are Strings.
		+ Be a Double, Float, Int or String.

Example:

```Swift	
var bridge: SwiftJavascriptBridge = SwiftJavascriptBridge.bridge()
self.bridge.bridgeCallFunction("swiftCallJSFunction", data: nil)
```

## Usage

To run the example project, clone the repo, and run `pod install` from the Example directory first.

## Credits

SwiftJavascriptBridge is owned and maintained by [Gastón Montes](<mailto:gastonmontes@hotmail.com>).

## License

SwiftJavascriptBridge is available under the BSD license. See the LICENSE file for more info.
