//
//  TWTlvUtilsTests.swift
//  TWTagLengthValue
//
//  Created by Thomas Wilson on 27/11/2015.
//  Copyright © 2015 Thomas Wilson. All rights reserved.
//

import XCTest
@testable import TWTagLengthValue
class TWTlvUtilsTests: XCTestCase {

    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }

	func testBytesUsed(){
		XCTAssert(bytesUsed(0xFF) == 1);
		XCTAssert(bytesUsed(0xFFFF) == 2);
		XCTAssert(bytesUsed(0xFFFFFF) == 3);
		XCTAssert(bytesUsed(0xFFFFFFFF) == 4);
		XCTAssert(bytesUsed(0xFFFFFFFFFF) == 5);
		XCTAssert(bytesUsed(0xFFFFFFFFFFFF) == 6);
		XCTAssert(bytesUsed(0xFFFFFFFFFFFFFF) == 7);
		XCTAssert(bytesUsed(0xFFFFFFFFFFFFFFFF) == 8);
		XCTAssert(bytesUsed(0x00) == 0);
		XCTAssert(bytesUsed(0x00FF) == 1);
		
		
	}
	
	func testGetLengthData(){
		let simpleLength = 100;
		var testArray = getLengthData(simpleLength);
		
		XCTAssert(testArray.count == 1);
		XCTAssert(testArray.first == 100);
		
		testArray = getLengthData(240);
		XCTAssert(testArray.count == 2);
		XCTAssert(testArray[0] == 0x81);
		XCTAssert(testArray[1] == 240);
		
		testArray = getLengthData(0x1001);
		XCTAssert(testArray.count == 3);
		XCTAssert(testArray[0] == 0x82);
		XCTAssert(testArray[1] == 0x10);
		XCTAssert(testArray[2] == 0x01);
	}

}
