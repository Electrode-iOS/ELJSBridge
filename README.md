# ELJSBridge [![Build Status](https://travis-ci.org/Electrode-iOS/ELJSBridge.svg)](https://travis-ci.org/Electrode-iOS/ELJSBridge)

ELJSBridge is a Swift wrapper around JavaScriptCore's Objective-C bridge.

## Installation

### Carthage

Install with [Carthage](https://github.com/Carthage/Carthage) by adding the framework to your project's [Cartfile](https://github.com/Carthage/Carthage/blob/master/Documentation/Artifacts.md#cartfile).

```
github "Electrode-iOS/ELJSBridge" ~> 1.0.0
```

### Manual

ELJSBridge can be installed manually by adding `ELJSBridge.xcodeproj` to your project and configuring your target to link `ELJSBridge.framework`.

ELJSBridge depends on the following [Electrode-iOS](https://github.com/Electrode-iOS/) modules:

- [`ELFoundation`](https://github.com/Electrode-iOS/ELFoundation).
- [`ELLog`](https://github.com/Electrode-iOS/ELLog).

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

## Contributions

We appreciate your contributions to all of our projects and look forward to interacting with you via Pull Requests, the issue tracker, via Twitter, etc.  We're happy to help you, and to have you help us.  We'll strive to answer every PR and issue and be very transparent in what we do.

When contributing code, please refer to our [Dennis](https://github.com/Electrode-iOS/Dennis).

## License

The MIT License (MIT)

Copyright (c) 2015 Walmart, WalmartLabs, and other Contributors

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all
copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
SOFTWARE.
