//
//  FieldTracking.swift
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

import Foundation

class FieldTracking {
    private var completedFields = [String:[TrackedField]]()
    private var activeFields = [String:TrackedField]()
    
    func textFieldDidBeginEditing(textField: Field) {
        let field = self.getField(textField: textField)
        
        field.name = textField.name
        field.whenFocused = self.date(toString: textField.dateOfAction)
        
        self.activeFields[field.name] = field
    }
    
    func textFieldDidEndEditing(textField: Field) {
        let field = self.getField(textField: textField)
        
        field.whenBlured = self.date(toString: textField.dateOfAction)
        field.isConsideredValid = textField.isConsideredValid
        
        self.moveActiveFieldToCompleted(trackingField: field)
    }
    
    func didChangeInputText(textField: Field) {
        let field = self.getField(textField: textField)
        
        if ((field.currentLength == 0 || (field.whenEditingBegan != nil)) && textField.value.characters.count > 0) {
            field.whenEditingBegan = self.date(toString: textField.dateOfAction)
        }
        
        let doNotWant = CharacterSet(charactersIn: "/ ")
        let textMinusWhitespace: String = (textField.value.components(separatedBy: doNotWant) as NSArray).componentsJoined(by: "")
        
        let previousTextLength = field.currentLength
        let currentTextLength = textMinusWhitespace.characters.count
        
        let differenceInLength = currentTextLength - previousTextLength
        
        if (differenceInLength > 1 || differenceInLength < -1) {
            field.whenPasted.append(self.date(toString: textField.dateOfAction))
        }
        
        field.totalKeystrokes += abs(differenceInLength);
        field.currentLength = currentTextLength;
        
        self.activeFields[field.name] = field
    }
    
    func trackingAsDictionary() -> [String:Any] {
        return FieldMetaDataGenerator.generateAsDictionary(fieldSessions: self.completedFields)
    }
    
    private func moveActiveFieldToCompleted(trackingField: TrackedField) {
        var completedFields = self.completedFields[trackingField.name] ?? [TrackedField]()
        completedFields.append(trackingField)
        
        self.completedFields[trackingField.name] = completedFields
        self.activeFields.removeValue(forKey: trackingField.name)
    }
    
    private func getField(textField: Field) -> TrackedField {
        var field = self.activeFields[textField.name]
        
        if field == nil {
            field = TrackedField()
            field?.name = textField.name
            field?.currentLength = textField.value.characters.count
        }
        
        return field!
    }
    
    private func date(toString date: Date) -> String {
        let dateFormat = DateFormatter()
        dateFormat.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSS'Z'"
        dateFormat.locale = Locale(identifier: "en_US_POSIX")
        return dateFormat.string(from: date)
    }
}
