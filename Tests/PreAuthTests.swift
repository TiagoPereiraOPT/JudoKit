//
//  PreAuthTests.swift
//  JudoTests
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

import XCTest
@testable import JudoKit

class PreAuthTests: JudoTestCase {
    
    func testPreAuth() {
        guard let references = Reference(consumerRef: "consumer0053252") else { return }
        let amount = Amount(amountString: "30", currency: .GBP)
        do {
            let preauth = try judo.preAuth(myJudoID, amount: amount, reference: references)
            XCTAssertNotNil(preauth)
        } catch {
            XCTFail("exception thrown: \(error)")
        }
    }
    
    
    func testJudoMakeValidPreAuth() {
        do {
            // Given I have a Pre-authorization
            let preAuth = try judo.preAuth(myJudoID, amount: oneGBPAmount, reference: validReference)
            
            // When I provide all the required fields
            preAuth.card(validVisaTestCard)
            
            // Then I should be able to make a Pre-authorization
            let expectation = self.expectationWithDescription("payment expectation")
            
            try preAuth.completion({ (response, error) -> () in
                if let error = error {
                    XCTFail("api call failed with error: \(error)")
                }
                XCTAssertNotNil(response)
                XCTAssertNotNil(response?.first)
                expectation.fulfill()
            })
            
            XCTAssertNotNil(preAuth)
            XCTAssertEqual(preAuth.judoID, myJudoID)
        } catch {
            XCTFail("exception thrown: \(error)")
        }
        
        self.waitForExpectationsWithTimeout(30, handler: nil)
    }
    
    
    func testJudoMakePreAuthWithoutCurrency() {
        do {
            // Given I have a Pre-authorization
            // When I do not provide a currency
            let preAuth = try judo.preAuth(myJudoID, amount: invalidCurrencyAmount, reference: validReference)
            
            preAuth.card(validVisaTestCard)
            
            // Then I should receive an error
            let expectation = self.expectationWithDescription("payment expectation")
            
            try preAuth.completion({ (response, error) -> () in
                XCTAssertNil(response)
                XCTAssertNotNil(error)
                XCTAssertEqual(error!.code, JudoErrorCode.General_Model_Error)
                
                XCTAssertEqual(error?.details?.count, 3)
                
                expectation.fulfill()
            })
            
            XCTAssertNotNil(preAuth)
            XCTAssertEqual(preAuth.judoID, myJudoID)
        } catch {
            XCTFail("exception thrown: \(error)")
        }
        
        self.waitForExpectationsWithTimeout(30, handler: nil)
    }
    
    
    func testJudoMakePreAuthWithoutReference() {
        do {
            // Given I have a Pre-authorization
            // When I do not provide a consumer reference
            let preAuth = try judo.preAuth(myJudoID, amount: oneGBPAmount, reference: invalidReference)
            
            preAuth.card(validVisaTestCard)
            
            // Then I should receive an error
            let expectation = self.expectationWithDescription("payment expectation")
            
            try preAuth.completion({ (response, error) -> () in
                XCTAssertNil(response)
                XCTAssertNotNil(error)
                XCTAssertEqual(error!.code, JudoErrorCode.General_Model_Error)
                
                XCTAssertEqual(error?.details?.count, 2)
                
                expectation.fulfill()
            })
            
            XCTAssertNotNil(preAuth)
            XCTAssertEqual(preAuth.judoID, myJudoID)
        } catch {
            XCTFail("exception thrown: \(error)")
        }
        
        self.waitForExpectationsWithTimeout(30, handler: nil)
    }
    
    
    func testJudoMakeInvalidJudoIDPreAuth() throws {
        // Given
        // allowed length for judoID is 6 to 10 chars
        let tooShortJudoID = "33412" // 5 chars not allowed
        let tooLongJudoID = "33224433441" // 11 chars not allowed
        let luhnInvalidJudoID = "33224433"
        var parameterError = false
        guard let references = Reference(consumerRef: "consumer0053252") else { return }
        let amount = Amount(amountString: "30", currency: .GBP)
        
        // When too short
        do {
            try judo.preAuth(tooShortJudoID, amount: amount, reference: references) // this should fail
        } catch let error as JudoError {
            // Then
            switch error.code {
            case .JudoIDInvalidError, .LuhnValidationError:
                parameterError = true
            default:
                XCTFail("exception thrown: \(error)")
            }
        }
        XCTAssertTrue(parameterError)
        
        parameterError = false
        // When too long
        do {
            try judo.preAuth(tooLongJudoID, amount: amount, reference: references) // this should fail
        } catch let error as JudoError {
            switch error.code {
            case .JudoIDInvalidError, .LuhnValidationError:
                parameterError = true
            default:
                XCTFail("exception thrown: \(error)")
            }
        }
        XCTAssertTrue(parameterError)
        
        parameterError = false
        // When
        do {
            try judo.preAuth(luhnInvalidJudoID, amount: amount, reference: references) // this should fail
        } catch let error as JudoError {
            switch error.code {
            case .JudoIDInvalidError, .LuhnValidationError:
                parameterError = true
            default:
                XCTFail("exception thrown: \(error)")
            }
        }
        XCTAssertTrue(parameterError)
    }
    
    
    func testJudoMakeInvalidReferencesPreAuth() {
        // Given
        guard let references = Reference(consumerRef: "") else { return }
        let amount = Amount(amountString: "30", currency: .GBP)
        
        // When
        do {
            try judo.preAuth(myJudoID, amount: amount, reference: references)
        } catch {
            XCTFail("exception thrown: \(error)")
        }

    }
    
    
}
