# ELJSBridge [![Build Status](https://travis-ci.org/Electrode-iOS/ELJSBridge.svg)](https://travis-ci.org/Electrode-iOS/ELJSBridge)

ELJSBridge is a Swift wrapper around JavaScriptCore's Objective-C bridge.

## Installation

### Carthage

Install with [Carthage](https://github.com/Carthage/Carthage) by adding the framework to your project's [Cartfile](https://github.com/Carthage/Carthage/blob/master/Documentation/Artifacts.md#cartfile).

```
github "Electrode-iOS/ELJSBridge" ~> 1.0.0
```

### Manual

ELJSBridge can be installed manually by adding ELJSBridge.xcodeproj to your project and configuring your target to link ELJSBridge.framework.

ELJSBridge depends on the following [THG](https://github.com/Electrode-iOS/) modules:

- [`ELFoundation`](https://github.com/Electrode-iOS/ELFoundation).
- [`ELLog`](https://github.com/Electrode-iOS/ELLog).

[Electrode-iOS](https://github.com/Electrode-iOS/) modules are designed to live side-by-side in the file system, like so:

* \MyProject
* \MyProject\ELJSBridge
* \MyProject\ELFoundation
* \MyProject\ELLog


## Usage

Initialize a bridge instance and evaluate a script with the JavaScript context.

```
let bridge = Bridge()
bridge.context.evaluateScript("var question = 'What is your name?'")

let question: JSValue = bridge.contextValueForName("question")
println(question)
// What is your name?
```

### JSContext

The underlying `JSContext` value can be changed by setting the `context` property. Suppose you wanted to retrieve the JavaScript context from a web view.

```
let webViewContextKeyPath = "documentView.webView.mainFrame.javaScriptContext"

if let context = valueForKeyPath(webViewContextKeyPath) as? JSContext {
    bridge.context = context
}
```

### Exporting Native Objects

Objects that conform to `JSExport` can be exposed to JavaScript by adding instances to the bridge.

Swift:

```
bridge.addExport(Scanner(), name: "scanner")
```

Any methods declared in the JSExport-inherited protocol will be exposed to JavaScript.

JavaScript:

```
scanner.presentScanner(function(error, scannedValue) {});
```

Objects that are exported via the `addExport` method are retained between JavaScript context changes. When the `context` property is set all exported objects are added to the new JavaScript context value. This is useful when you need to provide a stateful API between context changes like page loads in a web view.
