# FRDLivelyButton-Swift

`FRDLivelyButton-Swift` is a dirty and quick port of the original simple UIButton subclass intended to be used inside a UIBarButtonItem,
even though it can be used anywhere you can use a UIButton.
It is entirely Core Graphics driven, supports 5 common button types (menu, close, add, etc...)
used in navigation bar, and will nicely animate any button type changes and touch events.

![demo](images/screenshot.gif)

## Requirements

`FRDLivelyButton-Swift` uses Swift 3


## Installation

### CocoaPods
cocoapods has not yet been updated for the swift version

~~`pod 'FRDLivelyButton', '~> 1.1.3'`~~

### Manual

Copy the files `FRDLivelyButton-Swift.swift` & `FRDLivelyButtonObject.swift` to your project.

## Usage

Add a FRDLivelyButton either in code. (may work in Storyboards but I have yet to try it that way)

Example, how to add a ```FRDLivelyButton``` in a nav bar:

``` swift
class view: UIViewController {
let button = FRDLivelyButton(frame: CGRect(x: 0, y: 0, width: 50, height: 50))

  func buttonConfig() {
    button.setStyle(style: kFRDLivelyButtonStyle.kFRDLivelyButtonStyleCaretUp, animated: true)

    button.addTarget(self, action: #selector(targetFunc), for: .touchUpInside)

    let buttonItem = UIBarButtonItem(customView: button)
    navigationItem.rightBarButtonItem = buttonItem
  }
}
```

To change the button style, just call ```setStyle(style:,animated:)```:

``` swift
button.setStyle(style: kFRDLivelyButtonStyle.kFRDLivelyButtonStyleCaretDown, animated: true)
```

The current type of the button can be accessed using the buttonStyle property:

``` swift
func targetFunc()
{
    if (button.buttonStyle == kFRDLivelyButtonStyleCaretUp) {
    	// logic
      button.setStyle(style: kFRDLivelyButtonStyle.kFRDLivelyButtonStyleCaretDown, animated: true)
    } else
    button.setStyle(style: kFRDLivelyButtonStyle.kFRDLivelyButtonStyleCaretUp, animated: true)
}
```


## Customizing Appearance

Button appearance and behavior can be somewhat customized using the FRDLivelyButtonObject.swift file. Color, highlighted color, line thickness, animation
durations, etc... can be customized. Default should work just fine though.

This area needs more work in swift, I have yet to polish it up.

See FRDLivelyButtonObject.swift for list of possible attributes.

Example:

``` swift
class FRDLivelyButtonObject: NSObject {
    var kFRDLivelyButtonHighlightScale: CGFloat = 0.9
    var kFRDLivelyButtonLineWidth: CGFloat = 2.0
    var kFRDLivelyButtonColor: CGColor = UIColor.white.cgColor
    var kFRDLivelyButtonHighlightedColor: CGColor = UIColor.lightGray.cgColor
    var kFRDLivelyButtonHighlightAnimationDuration: Double = 0.1
    var kFRDLivelyButtonUnHighlightAnimationDuration: Double = 0.15
    var kFRDLivelyButtonStyleChangeAnimationDuration:Double = 0.3
}
```


## License

    The MIT License (MIT)

    Copyright (c) 2016 Brandon Harris

    Permission is hereby granted, free of charge, to any person obtaining a copy
    of this software and associated documentation files (the "Software"), to deal
    in the Software without restriction, including without limitation the rights
    to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
    copies of the Software, and to permit persons to whom the Software is
    furnished to do so, subject to the following conditions:

    The above copyright notice and this permission notice shall be included in
    all copies or substantial portions of the Software.

    THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
    IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
    FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
    AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
    LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
    OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
    THE SOFTWARE.
