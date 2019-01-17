//
//  TWTLV.swift
//  TWTagLengthValue
//
//  Created by Thomas Wilson on 21/11/2015.
//  Copyright © 2015 Thomas Wilson. All rights reserved.
//

import Foundation
private let ExceptionName = "InvalidTLV"

enum TWTLVError: Error{
	case invalidTag(description:String)
	case invalidLength(description:String)
	case invalidDataFormat(description:String)
	case invalidOperation(description:String)
}

open class TWTLV : NSObject {
	open var tagId:UInt64
	fileprivate(set) open var length:UInt64 = 0
	open var constructed:Bool
	fileprivate var internalValue:[UInt8]?
	open var value:[UInt8] {
		get{
			if (!constructed && internalValue != nil){
				return internalValue!
			}else if (children.count > 0){
				var result = [UInt8]()
				for child in children{
					result.append(contentsOf: child.data)
				}
				return result
			}else {return [0x00]}
		}
	}
	open var data:[UInt8]{
		get {
			var data = tagId.toByteArray()
			data.append(contentsOf: length.toByteArray())
			data.append(contentsOf: self.value)
			return data
		}
	}
	open var children:[TWTLV]
	
	public convenience init(tagIdStr:String, value:[UInt8]?) throws {
		let result = cleanHex(tagIdStr)
		if let tagData = UInt64(result){
			try self.init(tagId:tagData, value:value)
		}else{
			throw TWTLVError.invalidTag(description: "Invalid Hex String")
		}
	}
	
	public convenience init(tagId:UInt64, value:[UInt8]?) throws {
		var tlvData = tagId.toByteArray()
		if(value != nil){
			tlvData.append(contentsOf:getLengthData(value!.count))
			tlvData.append(contentsOf: value!)
		}else{
			tlvData.append(0x00)
		}
		
		try self.init(data: tlvData)
		
	}
	
	public convenience init(data:[UInt8]) throws {
		var offset = 0
		try self.init(data:data, offset:&offset);
	}
	
	public init(data:[UInt8], offset:inout Int) throws {
		tagId = 0x00
		length = 0x00
		constructed = false;
		children = [TWTLV]()
		super.init()
		if(data.count == 0){
			return
		}
		let pcByte = data[offset];
		self.constructed = pcByte.isConstructedTag()
		if let tagId = TWTLV.getTagId(data, offset: &offset){
			self.tagId = tagId;
			let length = TWTLV.getLength(data, offset: &offset)
			self.length = length
			if(length > UInt64(data.count-offset)){
				throw TWTLVError.invalidLength(description: "Length greater than data array")
			}else if(length == 0x00){
				return
			}
			if((pcByte & 0x20) == 0x20){
				self.children = try TWTLV.getChildern(data, length:self.length, offset:&offset);
			}else{
				let end = offset + Int(self.length)
				self.internalValue = Array(data[offset...end-1])
				offset = end
			}
		}else{
			throw TWTLVError.invalidDataFormat(description: "Invalid tag id")
		}
	}
	
	open func addChild(_ tagid:UInt64, data:[UInt8]) throws {
		let child = try TWTLV.init(tagId: tagid, value: data);
		if !constructed{
			throw TWTLVError.invalidOperation(description: "Tag Id \(self.tagId) marked as primitive")
		}
		self.children.append(child)
		self.length += UInt64(child.data.count)
	}
	
	open func printableTlv(_ level:Int = 1) -> String{
		var tlvStr = ""
		
		let tagData = tagId.toByteArray()
		for byte in tagData{
			tlvStr += byte.toAsciiHex()
		}
		tlvStr += ":"
		let lengthData = length.toByteArray()
		for byte in lengthData {
			tlvStr += byte.toAsciiHex()
		}
		if(length > 0x00){
			tlvStr += ":"
			if(constructed){
				tlvStr += "\n"
				for child in children{
					tlvStr = tlvStr.padding(toLength: tlvStr.count+level, withPad: "\t", startingAt:0)
					tlvStr += child.printableTlv(level+1)
				}
				
			}else{
				for byte in value{
					tlvStr += byte.toAsciiHex()
				}
			}
			if(!tlvStr.hasSuffix(":\n")){
				tlvStr += ":\n"
			}
			
		}
		
		return tlvStr
	}
	
	fileprivate static func getTagId(_ data:[UInt8], offset:inout Int) -> UInt64? {
		var tagArray:[UInt8] = [UInt8]()
		tagArray.append(data[offset]);
		while((data[offset] & 0x1F) == 0x1F){
			offset += 1;
			tagArray.append(data[offset])
		}
		offset += 1
		return arrayToUInt64(tagArray);
	}
	
	fileprivate static func getLength(_ data:[UInt8], offset:inout Int) -> UInt64{
		if(data.count == offset){
			return 0x00
		}
		if((data[offset] & 0x80) == 0x80){
			let lengthCount:UInt8 = data[offset] ^ 0x80;
			offset += 1
			let end = offset + Int(lengthCount)
			let lengthBytes:[UInt8] = Array(data[offset...end]);
			offset = (end+1)
			return UInt64(lengthBytes.withUnsafeBufferPointer {
				($0.baseAddress!.withMemoryRebound(to: UInt32.self, capacity: 1) { $0 })
				}.pointee);
		}else{
			let result = data[offset];
			offset += 1
			return UInt64(result);
		}
	}
	
	fileprivate static func getChildern(_ data:[UInt8], length:UInt64, offset:inout Int) throws -> [TWTLV]{
		var children = [TWTLV]()
		while (offset < data.count){
			children.append(try TWTLV.init(data: data, offset:&offset));
		}
		return children
	}
	
}
