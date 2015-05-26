# MCMHeaderAnimated


## Usage


```swift
private let transitionManager = MCMHeaderAnimated()
```

```swift
destination.transitioningDelegate = self.transitionManager
```

Finally extend MCMHeaderAnimatedDelegate and implement __headerView__ and __headerCopy__ functions in both view controllers.

```swift
self.transitionManager.destinationViewController = destination
```

## Requirements

iOS 8.0+

## Installation

### CocoaPods

MCMHeaderAnimated is available through [CocoaPods](http://cocoapods.org). To install
it, simply add the following line to your Podfile:

```ruby
pod "MCMHeaderAnimated"
```

Then, run the following command:

```
$ pod install
```

### Manual

If you prefer not to use [CocoaPods](http://cocoapods.org), you can integrate MCMHeaderAnimated into your project manually. Just drag and drop all files in the [__Source__](Source) folder into your project.

## Demo

Build and run the example project in Xcode to see MCMHeaderAnimated in action.

## Author

Mathias Carignani, mathcarignani@gmail.com

## License

MCMHeaderAnimated is available under the MIT license. See the LICENSE file for more info.
