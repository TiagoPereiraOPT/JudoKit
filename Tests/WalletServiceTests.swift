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
    
    private var repo = InMemoryWalletRepository()
    private var sut = WalletService(repo: InMemoryWalletRepository())
    
    override func setUp() {
        self.repo = InMemoryWalletRepository()
        self.sut = WalletService(repo: repo)
    }
    
    //Adding first card to wallet must set that card as default
    func test_AddingFirstCardMustBeSetAsDefault() {
        //arr
        let addedCard = self.buildWalletCard(isDefault: false)
        
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
        let firstAddedCard = self.buildWalletCard(isDefault: false)
        let secondAddedCard = self.buildWalletCard(isDefault: false)
        
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
        let firstAddedCard = self.buildWalletCard(isDefault: false)
        let secondAddedCard = self.buildWalletCard(isDefault: true)
        
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
        //arr
        let firstAddedCard = self.buildWalletCard(isDefault: true)
        let secondAddedCard = self.buildWalletCard(isDefault: false)
        
        //act
        self.sut.add(card: firstAddedCard)
        self.sut.add(card: secondAddedCard)
        //Update the second card.
        try! self.sut.update(card: secondAddedCard)
        
        //assert
        let firstRetrievedCard = self.sut.get(id: firstAddedCard.id)
        let secondRetrievedCard = self.sut.get(id: secondAddedCard.id)
        
        XCTAssertNotNil(firstRetrievedCard)
        XCTAssertTrue(firstRetrievedCard!.defaultPaymentMethod)
        XCTAssertNotNil(secondAddedCard)
        XCTAssertFalse(secondRetrievedCard!.defaultPaymentMethod)
    }
    
    //Updating card to wallet as default must set that card as default
    func test_UpdatingCardAsDefaultMustSetCardAsDefault() {
        //arr
        let firstAddedCard = self.buildWalletCard(isDefault: true)
        let secondAddedCard = self.buildWalletCard(isDefault: false)
        
        //act
        self.sut.add(card: firstAddedCard)
        self.sut.add(card: secondAddedCard)
        //Update the second card.
        try! self.sut.update(card: secondAddedCard.withDefaultCard())
        
        //assert
        let firstRetrievedCard = self.sut.get(id: firstAddedCard.id)
        let secondRetrievedCard = self.sut.get(id: secondAddedCard.id)
        
        XCTAssertNotNil(firstRetrievedCard)
        XCTAssertFalse(firstRetrievedCard!.defaultPaymentMethod)
        XCTAssertNotNil(secondAddedCard)
        XCTAssertTrue(secondRetrievedCard!.defaultPaymentMethod)
    }
    
    //Updating card with UUID that doesn't exist must throw exception
    func test_UpdatingCardWithUUIDThatDoesNotExistMustThrowException() {
        //arr
        let firstAddedCard = self.buildWalletCard(isDefault: true)
        
        //act //assert
        do {
            try self.sut.update(card: firstAddedCard)
            XCTFail()
        } catch let error as Error {
            let walletError = error as! WalletError
            XCTAssertNotNil(walletError)
            XCTAssertNotNil(walletError.description())
            XCTAssertTrue(walletError.description() == WalletError.unknownWalletCard.description())
        }
    }
    
    //Trying to update card with existing UUID must replace existing card
    func test_TryingToUpdateCardWithUUIDThatExistsMustReplaceThatCard() {
        //arr
        let firstAddedCard = self.buildWalletCard(isDefault: false)
        
        //act
        self.sut.add(card: firstAddedCard)
        
        let newAssignedName = self.uuidString()
        
        try! self.sut.update(card: firstAddedCard.withAssignedCardName(assignedName: newAssignedName))
        
        //assert
        let firstRetrievedCard = self.sut.get(id: firstAddedCard.id)
        XCTAssertNotNil(firstRetrievedCard)
        XCTAssertEqual(firstAddedCard.id, firstRetrievedCard!.id)
        XCTAssertEqual(newAssignedName, firstRetrievedCard!.assignedName)
    }
    
    //Removing default card must shift priority to next highest
    func test_RemovingDefaultCardMustShiftPriorityToNextHighest() {
        //arr
        let firstAddedCard = self.buildWalletCard(isDefault: false, alias: "first")
        let secondAddedCard = self.buildWalletCard(isDefault: false, alias: "second")
        let thirdAddedCard = self.buildWalletCard(isDefault: true, alias: "third")
        let forthAddedCard = self.buildWalletCard(isDefault: false, alias: "forth")
        
        //act
        self.sut.add(card: firstAddedCard)
        self.sut.add(card: secondAddedCard)
        self.sut.add(card: thirdAddedCard)
        self.sut.add(card: forthAddedCard)
        
        self.sut.remove(card: thirdAddedCard)
        
        //assert
        let retrievedCard = self.sut.getDefault()
        XCTAssertNotNil(retrievedCard)
        //Removing the third card should the default to the forth card as it was created last.
        XCTAssertEqual(retrievedCard!.id, forthAddedCard.id)
    }
    
    //Removing card UUID that doesn't exist must not thrown execption
    func test_RemovingCardWithUUIDThatDoesNotExistMustNotThrowException() {
        //arr
        let firstAddedCard = self.buildWalletCard(isDefault: false)
        
        //act assert
        self.sut.remove(card: firstAddedCard)
    }
    
    //Calling get default must return defsult card
    func test_CallingGetDefaultCardMustReturnDefaultCard() {
        //arr
        let firstAddedCard = self.buildWalletCard(isDefault: false)
        let secondAddedCard = self.buildWalletCard(isDefault: false)
        let thirdAddedCard = self.buildWalletCard(isDefault: true)
        let forthAddedCard = self.buildWalletCard(isDefault: false)
        
        //act
        self.sut.add(card: firstAddedCard)
        self.sut.add(card: secondAddedCard)
        self.sut.add(card: thirdAddedCard)
        self.sut.add(card: forthAddedCard)
        
        //assert
        let retrievedCard = self.sut.getDefault()
        XCTAssertNotNil(retrievedCard)
        XCTAssertEqual(retrievedCard!.id, thirdAddedCard.id)
    }
    
    //Card list must be ordered by default then date updated desc then date created desc
    func test_CardListMustBePrioritised() {
        let firstAddedCard = self.buildWalletCard(isDefault: false, alias: "first")
        let secondAddedCard = self.buildWalletCard(isDefault: false, alias: "second")
        let thirdAddedCard = self.buildWalletCard(isDefault: true, alias: "third")
        let forthAddedCard = self.buildWalletCard(isDefault: false, alias: "forth")
        let fifthAddedCard = self.buildWalletCard(isDefault: false, alias: "fifth")
        
        self.sut.add(card: firstAddedCard)
        self.sut.add(card: secondAddedCard)
        self.sut.add(card: thirdAddedCard)
        self.sut.add(card: forthAddedCard)
        self.sut.add(card: fifthAddedCard)
        //3,5,4,2,1
        
        self.sut.remove(card: thirdAddedCard)
        //5,4,2,1
        try! self.sut.update(card: firstAddedCard.withAssignedCardName(assignedName: "first-updated"))
        //5,1,4,2
        
        let walletCards = self.sut.get()
        XCTAssertEqual(walletCards.count, 4)
        XCTAssertEqual(walletCards[0].id, fifthAddedCard.id)
        XCTAssertEqual(walletCards[1].id, firstAddedCard.id)
        XCTAssertEqual(walletCards[2].id, forthAddedCard.id)
        XCTAssertEqual(walletCards[3].id, secondAddedCard.id)
    }
    
    private func buildWalletCard(isDefault: Bool) -> WalletCard {
        return self.buildWalletCard(isDefault: isDefault, alias: self.uuidString())
    }
    
    private func buildWalletCard(isDefault: Bool, alias: String) -> WalletCard {
        return WalletCard(cardNumberLastFour: self.uuidString(), expiryDate: self.uuidString(), cardToken: self.uuidString(), cardType: 1, assignedName: alias, defaultPaymentMethod: isDefault)
    }
    
    private func uuidString() -> String {
        return UUID().uuidString
    }
}
