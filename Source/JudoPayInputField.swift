//
//  JudoPayInputField.swift
//  JudoKit
//
//  Copyright (c) 2016 Alternative Payments Ltd
//
//  Permission is hereby granted, free of charge, to any person obtaining a copy
//  of this software and associated documentation files (the "Software"), to deal
//  in the Software without restriction, including without limitation the rights
//  to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
//  copies of the Software, and to permit persons to whom the Software is
//  furnished to do so, subject to the following conditions:
//
//  The above copyright notice and this permission notice shall be included in all
//  copies or substantial portions of the Software.
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
//  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
//  SOFTWARE.

import UIKit

fileprivate func < <T : Comparable>(lhs: T?, rhs: T?) -> Bool {
  switch (lhs, rhs) {
  case let (l?, r?):
    return l < r
  case (nil, _?):
    return true
  default:
    return false
  }
}

fileprivate func > <T : Comparable>(lhs: T?, rhs: T?) -> Bool {
  switch (lhs, rhs) {
  case let (l?, r?):
    return l > r
  default:
    return rhs < lhs
  }
}

/**
 
 The JudoPayInputField is a UIView subclass that is used to help to validate and visualize common information related to payments. This class delivers the common ground for the UI and UX. Text fields can either be used in a side-by-side motion (title on the left and input text field on the right) or with a floating title that floats to the top as soon as a user starts entering their details.
 
 It is not recommended to use this class directly but rather use the subclasses of JudoPayInputField that are also provided in judoKit as this class does not do any validation which are necessary for making any kind of transaction.
 
 */
open class JudoPayInputField: UIView, UITextFieldDelegate, ErrorAnimatable {
    
    /// The delegate for the input field validation methods
    open var delegate: JudoPayInputDelegate?
    
    /// the theme of the current judoKit session
    open var theme: Theme
    
    internal final let textField: FloatingTextField = FloatingTextField()
    
    internal lazy var logoContainerView: UIView = UIView()
    
    //THe bottom border the transaction into an error indictator upon invalid input.
    fileprivate let borderBottom = UIView()
    
    //Hint to display user hints or error message upon invalid input.
    fileprivate let hintLabel = UILabel()
    
    // MARK: Initializers
    
    /**
     Designated Initializer for JudoPayInputField
     
     - parameter theme: the theme to use
     
     - returns: a JudoPayInputField instance
     */
    public init(theme: Theme) {
        self.theme = theme
        super.init(frame: CGRect.zero)
        self.setupView()
    }
    
    
    /**
     Designated Initializer for JudoPayInputField
     
     - parameter frame: the frame of the input view
     
     - returns: a JudoPayInputField instance
     */
    override public init(frame: CGRect) {
        self.theme = Theme()
        super.init(frame: CGRect.zero)
        self.setupView()
    }
    
    
    /**
     Required initializer set as convenience to trigger the designated initializer that contains all necessary initialization methods
     
     - parameter aDecoder: decoder is ignored
     
     - returns: a JudoPayInputField instance
     */
    convenience required public init?(coder aDecoder: NSCoder) {
        self.init(frame: CGRect.zero)
    }
    
    
    /**
     Helper method to initialize the view
     */
    func setupView() {
        //Set up the bottom border
        self.borderBottom.translatesAutoresizingMaskIntoConstraints = false
        self.borderBottom.backgroundColor = UIColor(colorLiteralRed: 0.67, green: 0.67, blue: 0.67, alpha: 1)
        
        //Set up hint label
        self.hintLabel.translatesAutoresizingMaskIntoConstraints = false
        self.hintLabel.font = UIFont(name: self.hintLabel.font.fontName, size: 12)

        self.backgroundColor = self.theme.getInputFieldBackgroundColor()
        self.clipsToBounds = true
        
        self.translatesAutoresizingMaskIntoConstraints = false
        
        self.textField.delegate = self
        self.textField.keyboardType = .numberPad
        self.textField.keepBaseline = true
        self.textField.titleYPadding = 0.0
        
        self.addSubview(self.textField)
        self.addSubview(self.borderBottom)
        self.addSubview(self.hintLabel)
        
        self.textField.translatesAutoresizingMaskIntoConstraints = false
        self.textField.textColor = self.theme.getInputFieldTextColor()
        self.textField.tintColor = self.theme.tintColor
        self.textField.font = UIFont.boldSystemFont(ofSize: 16)
        self.textField.addTarget(self, action: #selector(JudoInputType.textFieldDidChangeValue(_:)), for: .editingChanged)
        
        self.setActive(false)
        
        self.textField.attributedPlaceholder = NSAttributedString(string: self.title(), attributes: [NSForegroundColorAttributeName: self.theme.getPlaceholderTextColor()])
        
        if self.containsLogo() {
            let logoView = self.logoView()!
            logoView.frame = CGRect(x: 0, y: 0, width: 46, height: 30)
            self.addSubview(self.logoContainerView)
            self.logoContainerView.translatesAutoresizingMaskIntoConstraints = false
            self.logoContainerView.clipsToBounds = true
            self.logoContainerView.layer.cornerRadius = 2
            self.logoContainerView.addSubview(logoView)
            
            self.addConstraint(NSLayoutConstraint(item: self.logoContainerView, attribute: .centerY, relatedBy: .equal, toItem: self, attribute: .centerY, multiplier: 1.0, constant: 0.0))
            self.logoContainerView.addConstraint(NSLayoutConstraint(item: self.logoContainerView, attribute: .height, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1.0, constant: 30.0))
        }
        
        self.setUpConstraints()
    }
    
    // MARK: Helpers
    
    private func setUpConstraints() {
        //Border bottom horizontal
        self.addConstraint(vfl: "H:|-13-[borderBottom]-13-|", option: NSLayoutFormatOptions.directionLeftToRight)
        self.addConstraint(vfl: "H:|-13-[hintLabel]-13-|", option: NSLayoutFormatOptions.directionLeftToRight)
        self.addConstraint(vfl: self.containsLogo() ? "H:|-13-[text][logo(46)]-13-|" : "H:|-13-[text]-13-|", option: NSLayoutFormatOptions.directionLeftToRight)
        self.addConstraint(vfl: "V:|[text]-8-[borderBottom(0.5)]-5-[hintLabel(15)]|", option: NSLayoutFormatOptions(rawValue: 0))
        
        if self.containsLogo() {
            self.addConstraint(vfl: "V:|-5-[logo(30)]|", option: NSLayoutFormatOptions(rawValue: 0))
        }
    }
    
    private func addConstraint(vfl: String, option: NSLayoutFormatOptions) {
        var views = [
            "text" : self.textField,
            "borderBottom" : self.borderBottom,
            "hintLabel" : self.hintLabel
        ]
        
        if self.containsLogo() {
            views["logo"] = self.logoContainerView
        }
        
        self.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: vfl, options: option, metrics: nil, views: views))
    }
    
    /**
     In the case of an updated card logo, this method animates the change
     */
    open func updateCardLogo() {
        let logoView = self.logoView()!
        logoView.frame = CGRect(x: 0, y: 0, width: 46, height: 30)
        if let oldLogoView = self.logoContainerView.subviews.first as? CardLogoView {
            if oldLogoView.type != logoView.type {
                UIView.transition(from: self.logoContainerView.subviews.first!, to: logoView, duration: 0.3, options: .transitionFlipFromBottom, completion: nil)
            }
        }
        self.textField.attributedPlaceholder = self.placeholder()
    }
    
    
    /**
     Set current object as active text field visually
     
     - parameter isActive: Boolean stating whether textfield has become active or inactive
     */
    open func setActive(_ isActive: Bool) {
        self.textField.alpha = isActive ? 1.0 : 0.5
        self.logoContainerView.alpha = isActive ? 1.0 : 0.5
        self.borderBottom.alpha = isActive ? 1.0 : 0.5
    }
    
    
    /**
     Method that dismisses the error generated in the `errorAnmiation:` method
     */
    open func dismissError() {
        if self.borderBottom.bounds.size.height > 0 {
            UIView.animate(withDuration: 0.4, animations: { () -> Void in
                self.setBorderBottomAsNormal()
            }) 
        }
    }
    
    
    /**
     Delegate method when text field did begin editing
     
     - parameter textField: The `UITextField` that has begun editing
     */
    open func textFieldDidBeginEditing(_ textField: UITextField) {
        self.setActive(true)
        self.delegate?.judoPayInputDidChangeText(self)
    }
    
    /**
     Delegate method when text field did end editing
     
     - parameter textField: the `UITextField` that has ended editing
     */
    open func textFieldDidEndEditing(_ textField: UITextField) {
        self.setActive(textField.text?.characters.count > 0)
        self.delegate?.judoInputEditingDidEnd(self)
    }
    
    open func setBorderBottomAsError() {
        self.borderBottom.frame = CGRect(x: self.borderBottom.frame.origin.x, y: self.borderBottom.frame.origin.y, width: self.borderBottom.frame.size.width, height: 2.0)
        self.borderBottom.backgroundColor = self.theme.getErrorColor()
        self.textField.textColor = self.theme.getErrorColor()
    }
    
    open func setBorderBottomAsNormal() {
        self.borderBottom.frame = CGRect(x: self.borderBottom.frame.origin.x, y: self.borderBottom.frame.origin.y, width: self.borderBottom.frame.size.width, height: 0.5)
        self.borderBottom.backgroundColor = UIColor(colorLiteralRed: 0.67, green: 0.67, blue: 0.67, alpha: 1) 
        self.textField.textColor = self.theme.getTextColor()
    }
    
    open func setErrorHintText(message: String) {
        self.hintLabel.text = message
        self.hintLabel.textColor = self.theme.getErrorColor()
    }
    
    open func setHintText(message: String) {
        self.hintLabel.text = message
        self.hintLabel.textColor = self.theme.getTextColor()
    }
}

extension JudoPayInputField: JudoInputType {
    
    /**
     Checks if the receiving input field has content that is valid
     
     - returns: true if valid input
     */
    public func isValid() -> Bool {
        return false
    }
    
    
    /**
     Helper call for delegate method
     */
    public func didChangeInputText() {
        self.delegate?.judoPayInputDidChangeText(self)
    }
    
    
    /**
     Subclassed method that is called when text field content was changed
     
     - parameter textField: the textfield of which the content has changed
     */
    public func textFieldDidChangeValue(_ textField: UITextField) {
        self.dismissError()
        // Method for subclassing
    }
    
    
    /**
     The placeholder string for the current input field
     
     - returns: an Attributed String that is the placeholder of the receiver
     */
    public func placeholder() -> NSAttributedString? {
        return nil
    }
    
    
    /**
     Boolean indicating whether the receiver has to show a logo
     
     - returns: true if inputField shows a Logo
     */
    public func containsLogo() -> Bool {
        return false
    }
    
    
    /**
     If the receiving input field contains a logo, this method returns Some
     
     - returns: an optional CardLogoView
     */
    public func logoView() -> CardLogoView? {
        return nil
    }
    
    
    /**
     Title of the receiver input field
     
     - returns: a string that is the title of the receiver
     */
    public func title() -> String {
        return ""
    }
    
    
    /**
     Width of the title
     
     - returns: width of the title
     */
    public func titleWidth() -> Int {
        return 50
    }
    
    
    /**
     Hint label text
     
     - returns: string that is shown as a hint when user resides in a inputField for more than 5 seconds
     */
    public func hintLabelText() -> String {
        return ""
    }
    
}

