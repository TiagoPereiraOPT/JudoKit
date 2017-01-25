//
//  WalletServiceTests.swift
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

import XCTest
@testable import JudoKit

class WalletServiceTests : JudoTestCase {
    
    private var repo = FakeWalletRepository()
    private var sut = WalletService(repo: FakeWalletRepository())
    
    override func setUp() {
        self.repo = FakeWalletRepository()
        self.sut = WalletService(repo: repo)
    }
    
    //Adding first card to wallet must set that card as default
    func test_AddingFirstCardMustBeSetAsDefault() {
        //arr
        let addedCard = self.buildWalletCard(dateCreated: Date(), dateUpdated: nil, isDefault: false)
        
        //act
        self.sut.add(card: addedCard)
        
        //assert
        let retrievedCard = self.sut.get(id: addedCard.id)
        
        XCTAssertNotNil(retrievedCard)
        XCTAssertTrue(retrievedCard!.defaultPaymentMethod)
    }
    
    //Adding second card to wallet must not set that card as default
    func test_AddingSecondCardMustNotBeSetAsDefault() {
        //arr
        let firstAddedCard = self.buildWalletCard(dateCreated: Date(), dateUpdated: nil, isDefault: false)
        let secondAddedCard = self.buildWalletCard(dateCreated: Date().addingTimeInterval(1.0), dateUpdated: nil, isDefault: false)
        
        //act
        self.sut.add(card: firstAddedCard)
        self.sut.add(card: secondAddedCard)
        
        //assert
        let firstRetrievedCard = self.sut.get(id: firstAddedCard.id)
        let secondRetrievedCard = self.sut.get(id: secondAddedCard.id)
        
        XCTAssertNotNil(firstRetrievedCard)
        XCTAssertTrue(firstRetrievedCard!.defaultPaymentMethod)
        XCTAssertNotNil(secondAddedCard)
        XCTAssertFalse(secondRetrievedCard!.defaultPaymentMethod)
    }
    
    //Adding second card to wallet as default must set that card as default
    func test_AddingSecondCardAsDefaultMustBeSetAsDefault() {
        //arr
        let firstAddedCard = self.buildWalletCard(dateCreated: Date(), dateUpdated: nil, isDefault: false)
        let secondAddedCard = self.buildWalletCard(dateCreated: Date().addingTimeInterval(1.0), dateUpdated: nil, isDefault: true)
        
        //act
        self.sut.add(card: firstAddedCard)
        self.sut.add(card: secondAddedCard)
        
        //assert
        let firstRetrievedCard = self.sut.get(id: firstAddedCard.id)
        let secondRetrievedCard = self.sut.get(id: secondAddedCard.id)
        
        XCTAssertNotNil(firstRetrievedCard)
        XCTAssertFalse(firstRetrievedCard!.defaultPaymentMethod)
        XCTAssertNotNil(secondAddedCard)
        XCTAssertTrue(secondRetrievedCard!.defaultPaymentMethod)
    }
    
    //Trying to add card with existing UUID must throw expection
    /*func test_TryingToAddCardWithExistingUUIDMustThrowException() {
    
    }*/
    
    //Updating card to wallet must not set that card as default
    func test_UpdatingCardMustNotSetCardAsDefault() {
    
    }
    
    //Updating card to wallet as default must set that card as default
    func test_UpdatingCardAsDefaultMustSetCardAsDefault() {
    
    }
    
    //Updating card with UUID that doesn't exist must throw exception
    func test_UpdatingCardWithUUIDThatDoesNotExistMustThrowException() {
    
    }
    
    //Trying to update card with existing UUID must replace existing card
    func test_TryingToUpdateCardWithUUIDThatExistsMustReplaceThatCard() {
    
    }
    
    //Removing default card must shift priority to next highest
    func test_RemovingDefaultCardMustShiftPriorityToNextHighest() {
    
    }
    
    //Removing card UUID that doesn't exist must not thrown execption
    func test_RemovingCardWithUUIDThatDoesNotExistMustNotThrowException() {
    
    }
    
    //Calling get default must return defsult card
    func test_CallingGetDefaultCardMustRetrunDefaultCard() {
    
    }
    
    //Card list must be ordered by default then date updated desc then date created desc
    func test_CardListMustBePrioritised() {
    
    }
    
    private func buildWalletCard(dateCreated: Date, dateUpdated: Date?, isDefault: Bool) -> WalletCard {
        return WalletCard(cardNumberLastFour: "1234", expiryDate: "01/20", cardToken: "testcardtoken1234", cardType: 1, assignedName: "test card", dateCreated: dateCreated, dateUpdated: dateUpdated, defaultPaymentMethod: isDefault)
    }
}
