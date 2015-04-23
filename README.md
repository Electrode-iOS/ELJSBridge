# BridgeOfDeath

THGBridge, a Javascript&lt;->Native bridge implementation in Swift


## Usage

### NativeBridge.navigation

#### pushState()

Trigger a native push navigation transition.

**Parameters**

**Example**

```
NativeBridge.navigation.pushState();

```

#### popState()

Trigger a native pop navigation transition. Call after histor

**Parameters**

**Example**

```
NativeBridge.navigation.popState();

```

## Example

A test iOS project is located in BridgeOfDeathTest/BridgeOfDeathTest.xcodeproj that is configured to load the test page at [http://bridgeofdeath.herokuapp.com/](http://bridgeofdeath.herokuapp.com/).