//
//  BlocksViewModelTests.swift
//  BlocksViewModelTests
//
//  Created by Morris Uhlenbrauck on 5/15/23.
//

import Combine
import XCTest
@testable import drag_and_drop

final class BlocksViewModelTests: XCTestCase {

    var cancellables = Set<AnyCancellable>()


    func testViewLoaded() {
        let mockviewmodel = BlocksViewModel(viewBounds: CGRect(x: 0, y: 0, width: 500, height: 1000))
        let expectation = expectation(description: "viewloaded publishes correct value")
        mockviewmodel.viewBlocks.sink(receiveValue: { blocks in
            if blocks.count == 2 {
                expectation.fulfill()
            }
                
        }).store(in: &cancellables)
        mockviewmodel.viewLoaded()
        waitForExpectations(timeout: 2)
    }
    
    func testSaveBlocks() {
        let mockBlock = Block(xCoordinate: 0, yCoordinate: 0, height: 100, width: 200)
        let mockedBlocks = [
            mockBlock,
            mockBlock,
            mockBlock
        ]
        
        let mockViewModel = BlocksViewModel(viewBounds: CGRect(x: 0, y: 0, width: 500, height: 1000))
        mockViewModel.saveBlocks(mockedBlocks)
        guard let fetchBlocks = mockViewModel.fetchSavedBlocks() else { return XCTFail("No blocks fetched")}
        XCTAssertTrue(fetchBlocks.count == 3)
    }
}
