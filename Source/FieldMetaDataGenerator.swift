//
//  FieldMetaDataGenerator.swift
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

public class FieldMetaDataGenerator {
    class func generateAsDictionary(fieldSessions: [String:[TrackedField]]) -> [String:Any]{
        var totalKeyStrokes = 0
        var fieldMetadata = [[String:Any]]()
        
        for completed in fieldSessions {
            var pastedFields = [String]()
            var sessions = [[String:String?]]()
            
            for field in completed.value {
                pastedFields += field.whenPasted
                
                sessions.append(["timeStarted":field.whenFocused, "timeEdited":field.whenEditingBegan, "timeEnded":field.whenBlured, "valid":field.isConsideredValid.description])
                totalKeyStrokes += field.totalKeystrokes
            }
            
            fieldMetadata.append(["field":completed.key, "sessions":sessions, "pasted":pastedFields])
        }
        
        return ["totalKeyStrokes":totalKeyStrokes, "fieldMetaData":fieldMetadata]
    }
}
