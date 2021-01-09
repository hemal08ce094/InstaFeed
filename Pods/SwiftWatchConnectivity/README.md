# SwiftWatchConnectivity

[![CI Status](http://img.shields.io/travis/ksk.matsuo@gmail.com/SwiftWatchConnectivity.svg?style=flat)](https://travis-ci.org/ksk.matsuo@gmail.com/SwiftWatchConnectivity)
[![Version](https://img.shields.io/cocoapods/v/SwiftWatchConnectivity.svg?style=flat)](http://cocoapods.org/pods/SwiftWatchConnectivity)
[![License](https://img.shields.io/cocoapods/l/SwiftWatchConnectivity.svg?style=flat)](http://cocoapods.org/pods/SwiftWatchConnectivity)
[![Platform](https://img.shields.io/cocoapods/p/SwiftWatchConnectivity.svg?style=flat)](http://cocoapods.org/pods/SwiftWatchConnectivity)
![iOS](https://img.shields.io/badge/iOS-9.3-blue.svg?style=flat)
![watchOS](https://img.shields.io/badge/watchOS-4.0-blue.svg?style=flat)
![Swift](https://img.shields.io/badge/Swift-4.0-blue.svg?style=flat)

SwiftWatchConnectivity is a WatchConnectivity simple wrapper.

## Features

- Queueing requested and received task until all available
- Support all transer between iOS and watchOS

## Example

To run the example project, clone the repo, and run `pod install` from the Example directory first.

### Prepare
- for iOS code
``` swift
// ViewController.swift
override func viewDidLoad() {
    super.viewDidLoad()
    SwiftWatchConnectivity.shared.delegate = self
}

func connectivity(_ swiftWatchConnectivity: SwiftWatchConnectivity, updatedWithTask task: SwiftWatchConnectivity.Task) {
    switch task {
    case .sendMessage(let message):
        // message is dictionaly that was sent by opponent OS
    default:
        break
    }
}
```

- for watchOS code
``` swift
// InterfaceController.swift
override func awake(withContext context: Any?) {
    super.awake(withContext: context)

    // Configure interface objects here.
    SwiftWatchConnectivity.shared.delegate = self
}

func connectivity(_ swiftWatchConnectivity: SwiftWatchConnectivity, updatedWithTask task: SwiftWatchConnectivity.Task) {
    switch task {
    case .sendMessage(let message):
        // message is dictionaly that was sent by opponent OS
    default:
        break
    }
}

// ExtensionDelegate.swift
func handle(_ backgroundTasks: Set<WKRefreshBackgroundTask>) {
    SwiftWatchConnectivity.shared.handle(backgroundTasks)
        :
}
```
### Send data
``` swift
// send dictionary immediately
SwiftWatchConnectivity.shared.sendMesssage(message: ["msg": NSDate()])
// send dictionary in foreground or background
SwiftWatchConnectivity.shared.transferUserInfo(userInfo: [
    "string": "hello",
    "bool": false,
    "array": [1,2,3]
])
// send file with metadata
let fileURL = Bundle.main.url(forResource: "dog", withExtension: "jpg")!
SwiftWatchConnectivity.shared.transferFile(fileURL: fileURL, metadata: ["Level": 8])
``

## Requirements
- iOS 9.3
- watchOS 4.0
- Swift 4.0

## Installation

SwiftWatchConnectivity is available through [CocoaPods](http://cocoapods.org). To install
it, simply add the following line to your Podfile:

```ruby
pod 'SwiftWatchConnectivity'
```

## Author

ksk.matsuo@gmail.com,

## License

SwiftWatchConnectivity is available under the MIT license. See the LICENSE file for more info.
