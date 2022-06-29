# HHLOneTimePasswordView
![](https://img.shields.io/badge/version-0.0.1-brightgreen.svg)

`HHLOneTimePasswordView` is SwiftUI component that enables devs to ask users for one time password code authentications (OTP). When code is wrong, it mimics the shake of the apple provided password fields.

The component gives the developer the ability to:
- change its appearace by providing colors
- provide a placeholder view for boxes that are not filled in
- provide a character set of allowed characters, so that the user can't type in(paste) a character that is not valid
- provide an `onChange` closure, that allows you to execute code as user input changes.

Build using Swift 5.6.1, XCode 13.4, supports iOS 15.0+

# Preview

![](https://raw.githubusercontent.com/hedgehoglab-engineering/HHLOneTimePasswordView/master/Preview/HHLOneTimePasswordView-preview.gif)

# Usage

You can use **HHLOneTimePasswordView** like any other SwiftUI view, by invoking its single initialiser.
### Example usage (short form):
```swift
 OneTimePasswordView {
     Circle()
         .fill(Color.brown)
         .padding()
 } passwordEnteredHandler: { enteredCode, recognisedCallback in
     // check if enteredCode is correct and pass true or false to `recognisedCallback`
     // indicating whether it was recognised or not
     recognisedCallback(true)
 }
 ```

### Full form of constructor:

```swift
/// Creates a SwiftUI view, meant to accept one time passwords sends to the user
    /// for authentication.
    ///
    /// It can be configured with a set with allowed characters and with
    /// characters count, as well as with a few UI tweaks, that you can inject
    /// from the constructor.
    ///
    /// - Parameters:
    ///   - cornerRadius: Controls the corner radius of each individual "box". Default is 8.
    ///   - digitCount: Controls how many digits should be entered by the user. Default is 4.
    ///   - foregroundColor: Controls the color of the character in the input boxes. Default is `UIColor.label`
    ///   - backgroundColor: Controls the color of the background of the input boxes. Default is `UIColor.systemGroupedBackground`
    ///   - allowedCharacterSet: A set that determines which inputs from the user should be accepted and which should be ignored.
    ///     Default is `.decimalDigits`
    ///   - highlightBorderColor: Controls the color of the border for the highlighted input box. Default value is `UIColor.label`
    ///   - borderColor: Controls the color of the border for the non highlighted input boxes. Default value is `UIColor.systemGray4`
    ///   - inputFieldFocus: Gives you the ability to control the focus of this view (to become/resign being first responder).
    ///   - placeholder: View builder used to provide a placeholder appearance for when there is no
    ///     entered character by the user in an input box.
    ///   - onSubmit: A closure that gives you the ability to react to the user input, after all boxes are filled in.
    ///   - onChange: A closure that is executed when the text input changes. You can check how many characters are allowed,
    ///     by checking the value in `digitCount`.
    public init(cornerRadius: CGFloat =  8,
                digitCount: Int =  4,
                foregroundColor: Color = Color(uiColor: .label),
                backgroundColor: Color = Color(uiColor: .systemGroupedBackground),
                allowedCharacterSet: CharacterSet = .decimalDigits,
                highlightBorderColor: Color = Color(uiColor: .label),
                borderColor: Color = Color(uiColor: .systemGray4),
                inputFieldFocus: FocusState<Bool> = FocusState(),
                @ViewBuilder placeholder: @escaping () -> Placeholder,
                onChange: (([Character]) -> ())? = nil,
                onSubmit: @escaping ([Character], @escaping (Bool) -> ()) -> ())
```

*If you need more info, have a look at the example project inside "Examples" folder in the repo.*

# Installation

### Swift Package Manager

1. Navigate to `XCode project` > `ProjectName` > `Swift Packages` > `+ (add)`
2. Paste the url `https://github.com/hedgehoglab-engineering/HHLOneTimePasswordView.git`
3. Select the needed targets.
