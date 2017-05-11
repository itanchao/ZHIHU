# TCRunloopView

[![CI Status](http://img.shields.io/travis/itanchao/TCRunloopView.svg?style=flat)](https://travis-ci.org/itanchao/TCRunloopView)
[![Version](https://img.shields.io/cocoapods/v/TCRunloopView.svg?style=flat)](http://cocoapods.org/pods/TCRunloopView)
[![License](https://img.shields.io/cocoapods/l/TCRunloopView.svg?style=flat)](http://cocoapods.org/pods/TCRunloopView)
[![Platform](https://img.shields.io/cocoapods/p/TCRunloopView.svg?style=flat)](http://cocoapods.org/pods/TCRunloopView)

## Example

To run the example project, clone the repo, and run `pod install` from the Example directory first.

## Requirements

## Installation

TCRunloopView is available through [CocoaPods](http://cocoapods.org). To install
it, simply add the following line to your Podfile:

```ruby
pod "TCRunloopView"
```

## API

```swift

    ///  Called after the user Clicked the Cell.
    ///
    /// - Parameters:
    ///   - loopView: loopView
    ///   - index: current index
    func runLoopViewDidClick(_ loopView:TCRunLoopView, didSelectRowAtIndex index: NSInteger)
    
    /// Called when any currentIndex changes
    ///
    /// - Parameters:
    ///   - loopView: loopView
    ///   - index: new current index
    func runLoopViewDidScroll(_ loopView: TCRunLoopView, didScrollRowAtIndex index: NSInteger)
```



## How to Build a LoopView & SetUp

```swift
        let runloopView = TCRunLoopView(frame: CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width, height: 400))
        runloopView.delegate = self
        view.addSubview(runloopView)
        let urlArray = ["http://ww1.sinaimg.cn/mw1024/473df571jw1f2aq06o3ltj20qo0ur79o.jpg","http://ww3.sinaimg.cn/mw1024/473df571jw1f24p6b71lhj20m80m841x.jpg","http://ww2.sinaimg.cn/mw1024/473df571jw1f1p8u1kf0hj20q50yvn3z.jpg","http://ww3.sinaimg.cn/mw1024/473df571jw1f17waawibmj20rs15o1kx.jpg","http://ww2.sinaimg.cn/mw1024/473df571jw1f0s5nq609zg20ku0kutbg.gif"]
        runloopView.loopDataGroup = urlArray.map{(url) in LoopData(image:url,des:url)}
        
```



## Author

itanchao, itanchao@gmail.com

## License

TCRunloopView is available under the MIT license. See the LICENSE file for more info.
