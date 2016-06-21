# [2.0.1](https://github.com/Electrode-iOS/ELJSBridge/releases/tag/v2.0.1)

- Added Target Dependencies for iOS and macOS

# [2.0.0](https://github.com/Electrode-iOS/ELJSBridge/releases/tag/v2.0.0)

## Breaking Changes

- Updated to suppot Xcode 7.3 and Swift 2.2
- Updated `ELJSBridgeError` to be `ErrorType` 
- Changed all `NSError` parameters to `ErrorType` 

# [1.0.0](https://github.com/Electrode-iOS/ELJSBridge/releases/tag/v1.0.0)

- Updated to support Xcode 7 and Swift 2.1
- Set `ONLY_ACTIVE_ARCH = NO` for QADeployment configuration
- Added QADeployment configuration to match main project
- Changed product name of ELJSBridge target to ELJSBridge
- Changed bundle identifider suffix to ios
- Added default behavior for lack of an `outputHandler` on the Console object.
- Separated Global/Console, added Scriptable protocol, and made bridge additions more explicit.
- Support for OS X.
- Added a mechanism to enable a native implementation of common global JS functions

# [0.0.3](https://github.com/Electrode-iOS/ELJSBridge/releases/tag/v0.0.3)

- Add copy framework build phase to test target

# [0.0.2](https://github.com/Electrode-iOS/ELJSBridge/releases/tag/v0.0.2)

- Add support for installation via Carthage
