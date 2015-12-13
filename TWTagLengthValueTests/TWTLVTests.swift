//
//  TWTLV.swift
//  TWTagLengthValue
//
//  Created by Thomas Wilson on 27/11/2015.
//  Copyright © 2015 Thomas Wilson. All rights reserved.
//

import XCTest
@testable import TWTagLengthValue
class TWTLVTests: XCTestCase {
	let testTlvStr = "6F1A840E315041592E5359532E4444463031A5088801025F2D02656E"
    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }

	func testInit(){
		if let testData = testTlvStr.asciiHexToData(){
			if let testTlv = try? TWTLV(data: testData){
				XCTAssert(testTlv.tagId == 0x6f)
				XCTAssert(testTlv.length == 0x1a);
				XCTAssert(UInt64(testTlv.value.count) == testTlv.length)
				XCTAssert(testTlv.children.count == 2);
				
				var child = testTlv.children[0]

				XCTAssert(child.tagId == 0x84)
				XCTAssert(child.length == 0x0e)
				XCTAssert(UInt64(child.value.count) == child.length)
				XCTAssert(child.children.count == 0)
				
				child = testTlv.children[1]
				
				XCTAssert(child.tagId == 0xa5)
				XCTAssert(child.length == 0x08)
				XCTAssert(UInt64(child.value.count) == child.length)
				XCTAssert(child.children.count == 2)
				
				let parent = child
				child = parent.children[0]
				
				XCTAssert(child.tagId == 0x88)
				XCTAssert(child.length == 0x01)
				XCTAssert(UInt64(child.value.count) == child.length)
				XCTAssert(child.children.count == 0)
				
				child = parent.children[1]
				
				XCTAssert(child.tagId == 0x5f2d)
				XCTAssert(child.length == 0x02)
				XCTAssert(UInt64(child.value.count) == child.length)
				XCTAssert(child.children.count == 0)
				
				
			}else{
				XCTAssert(false);
			}
		}else{
			XCTAssert(false);
		}
	}
	
	func testEmptyTlv(){
		do{
			var tlv = try TWTLV(tagId:0xe4, value: nil)
			XCTAssert(tlv.length == 0)
			XCTAssert(tlv.children.count == 0)
			XCTAssert(tlv.tagId == 0xe4);
			
			tlv = try TWTLV(data: [0xe4, 0x00])
			XCTAssert(tlv.length == 0)
			XCTAssert(tlv.children.count == 0)
			XCTAssert(tlv.tagId == 0xe4);
		} catch {
			XCTAssert(false)
		}
	}
	
	func testAddChild(){
		do{
			let tlv = try TWTLV(tagId:0xe4, value: nil)
			try tlv.addChild(0x9f33, data: [0x35,0x45, 0x34])
			
			XCTAssert(tlv.tagId == 0xe4)
			XCTAssert(tlv.children.count == 1)
			XCTAssert(tlv.length == 6);
			XCTAssert(tlv.data.count == 8);
			let child = tlv.children[0];
			
			XCTAssert(child.tagId == 0x9f33);
			XCTAssert(child.length == 3);
			XCTAssert(child.data.count == 6);
			
		}catch {
			XCTAssert(false);
		}
		
	}
	
	
}
