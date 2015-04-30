# BridgeOfDeath

THGBridge, a Javascript&lt;->Native bridge implementation in Swift

## Swift Usage

```
// present a modal web view controller w/ bridge scripts

if let url = NSURL(string: "http://localhost:3000/") {
    let webController = WebViewController.WithBridgePlatform()
    let navController = UINavigationController(rootViewController: webController)

    webController.loadURL(url)
    presentViewController(navController, animated: true, completion: nil)
}
```

## JavaScript Usage

#### window.nativeBridgeReady()

An optional callback to invoke after the web view has finished loading and the bridge APIs are ready for use.

**Example**

```
// wait for the bridge to be ready

function bridgeReady() {
  // web view is loaded and bridge is ready for use
}

if (window.NativeBridge === undefined) {
  window.nativeBridgeReady = function() {
    bridgeReady();
  }
} else {
  bridgeReady();
}
```

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

#### share()

Present an activity view controller with `message` and `url` as the activity items.

**Parameters**

- `options` (object) - Options
  - `message` (string) - Message text to share.
  - `url` (string) -  URL to share.

**Example**

```
var options = {
  message: "What is your quest?", 
  url: "https://github.com/TheHolyGrail/BridgeOfDeath"
};

NativeBridge.share(options);

```

#### dialog()

Present an activity view controller with `message` and `url` as the activity items.

**Parameters**

- `options` (object) - Options
  - `title` (string) -  Title text.
  - `message` (string) - Message text.
  - `actions` (array) - Array of dialog actions.
    - `id` (string) - Action identifier
    - `label` (string) - Action label text.
- `callback` (function(error, id)) - Callback to invoke when dialog action is tapped.
  - `error - Possible error.
  - `id` - ID of action that was tapped.

**Example**

```
var options = {
  title: "Title of Dialog",
  message: "Message of Dialog",
  actions: [{
    id: "cancel",
    label: "Cancel"
  }, {
    id: "ok",
    label: "Ok"
  }]
};

window.NativeBridge.dialog(options, function(error, id) {
  // handle action
});

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