# BridgeOfDeath

THGBridge, a Javascript&lt;->Native bridge implementation in Swift

## Usage

### NativeBridge

#### updatePageState()

Update the current view controller state using data from options. Currently only supports updating the title.

**Parameters**

- `options` (object) - Options
  - `title` (string) - Title text of view controller.

**Example**

```
NativeBridge.updatePageState({title: "Edit Address"});

```

### NativeBridge.navigation

#### animateForward()

Trigger a native push navigation transition. By default it pushes a new web view controller on to the web view controller's navigation stack with the current web view. Does not affect web view history.

**Example**

```
NativeBridge.navigation.animateForward();

```

#### animateBackward()

Trigger a native pop navigation transition. By default it pops a view controller off of the web view controller's navigation stack. Does not affect web view history.

**Example**

```
NativeBridge.navigation.animateBackward();

```

## Example

A test iOS project is located in BridgeOfDeathTest/BridgeOfDeathTest.xcodeproj that is configured to load the test page at [http://bridgeofdeath.herokuapp.com/](http://bridgeofdeath.herokuapp.com/).