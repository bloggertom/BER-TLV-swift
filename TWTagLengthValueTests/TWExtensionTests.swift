//
//  TWExtensionTests.swift
//  TWTagLengthValue
//
//  Created by Thomas Wilson on 28/11/2015.
//  Copyright © 2015 Thomas Wilson. All rights reserved.
//

import XCTest
@testable import TWTagLengthValue
class TWExtensionTests: XCTestCase {

    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }

	func testToByteArray(){
		let testInt:Int = 0x010203;
		
		var testArray = testInt.toByteArray();
		
		XCTAssert(testArray[0] == 0x01);
		XCTAssert(testArray[1] == 0x02);
		XCTAssert(testArray[2] == 0x03);
		
		let testUInt64:UInt64 = 0x0102030405060708
		testArray = testUInt64.toByteArray();
		XCTAssert(testArray[0] == 0x01);
		XCTAssert(testArray[1] == 0x02);
		XCTAssert(testArray[2] == 0x03);
		XCTAssert(testArray[3] == 0x04);
		XCTAssert(testArray[4] == 0x05);
		XCTAssert(testArray[5] == 0x06);
		XCTAssert(testArray[6] == 0x07);
		XCTAssert(testArray[7] == 0x08);
		
		
	}

	func testToAsciiHex(){
		let one:UInt8 = 0x01;
		let two:UInt8 = 0x02;
		let three:UInt8 = 0x03;
		
		XCTAssert(one.toAsciiHex() == "01", one.toAsciiHex());
		XCTAssert(two.toAsciiHex() == "02");
		XCTAssert(three.toAsciiHex() == "03");
		
		let effeff:UInt8 = 0xFF;
		XCTAssert(effeff.toAsciiHex() == "FF", effeff.toAsciiHex());
	}
	
	func testAsciiHexConversion(){
		let one:UInt8 = 0x01;
		let two:UInt8 = 0x02;
		let three:UInt8 = 0x03;
		

		XCTAssertEqual(one.toAsciiHex().asciiHexToData()![0], 0x01)
		XCTAssertEqual(two.toAsciiHex().asciiHexToData()![0], 0x02);
		XCTAssertEqual(three.toAsciiHex().asciiHexToData()![0], 0x03);
		
		let effeff:UInt8 = 0xFF;
		XCTAssert(effeff.toAsciiHex().asciiHexToData()![0] == 0xFF);
	}
	
	
}
