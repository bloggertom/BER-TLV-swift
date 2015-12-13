//
//  TWTLV.swift
//  TWTagLengthValue
//
//  Created by Thomas Wilson on 21/11/2015.
//  Copyright © 2015 Thomas Wilson. All rights reserved.
//

import Foundation
private let ExceptionName = "InvalidTLV"

enum TWTLVError: ErrorType{
	case InvalidTag(description:String)
	case InvalidLength(description:String)
	case InvalidDataFormat(description:String)
	case InvalidOperation(description:String)
}

public class TWTLV : NSObject {
	public var tagId:UInt64
	private(set) public var length:UInt64 = 0
	public var constructed:Bool
	private var internalValue:[UInt8]?
	public var value:[UInt8] {
		get{
			if (!constructed && internalValue != nil){
				return internalValue!
			}else if (children.count > 0){
				var result = [UInt8]()
				for child in children{
					result.appendContentsOf(child.data)
				}
				return result
			}else {return [0x00]}
		}
	}
	public var data:[UInt8]{
		get {
			var data = tagId.toByteArray()
			data.appendContentsOf(length.toByteArray())
			data.appendContentsOf(self.value)
			return data
		}
	}
	public var children:[TWTLV]
	
	public convenience init(tagIdStr:String, value:[UInt8]?) throws {
		let result = cleanHex(tagIdStr)
		if let tagData = UInt64(result){
			try self.init(tagId:tagData, value:value)
		}else{
			throw TWTLVError.InvalidTag(description: "Invalid Hex String")
		}
	}
	
	public convenience init(tagId:UInt64, value:[UInt8]?) throws {
		var tlvData = tagId.toByteArray()
		if(value != nil){
				tlvData.appendContentsOf(getLengthData(value!.count))
				tlvData.appendContentsOf(value!)
		}else{
			tlvData.append(0x00)
		}
		
		try self.init(data: tlvData)
		
	}
	
	public convenience init(data:[UInt8]) throws {
		var offset = 0
		try self.init(data:data, offset:&offset);
	}
	
	public init(data:[UInt8], inout offset:Int) throws {
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
				throw TWTLVError.InvalidLength(description: "Length greater than data array")
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
			throw TWTLVError.InvalidDataFormat(description: "Invalid tag id")
		}
	}
	
	public func addChild(tagid:UInt64, data:[UInt8]) throws {
		let child = try TWTLV.init(tagId: tagid, value: data);
		if !constructed{
			throw TWTLVError.InvalidOperation(description: "Tag Id \(self.tagId) marked as primitive")
		}
		self.children.append(child)
		self.length += UInt64(child.data.count)
	}
	
	public func printableTlv(level:Int = 1) -> String{
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
					tlvStr = tlvStr.stringByPaddingToLength(tlvStr.characters.count+level, withString: "\t", startingAtIndex:0)
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
	
	private static func getTagId(data:[UInt8], inout offset:Int) -> UInt64? {
		var tagArray:[UInt8] = [UInt8]()
		tagArray.append(data[offset]);
		while((data[offset] & 0x1F) == 0x1F){
			offset++;
			tagArray.append(data[offset])
		}
		offset++
		return arrayToUInt64(tagArray);
	}
	
	private static func getLength(data:[UInt8], inout offset:Int) -> UInt64{
		if(data.count == offset){
			return 0x00
		}
		if((data[offset] & 0x80) == 0x80){
			let lengthCount:UInt8 = data[offset] ^ 0x80;
			offset++
			let end = offset + Int(lengthCount)
			let lengthBytes:[UInt8] = Array(data[offset...end]);
			offset = (end+1)
			return UnsafePointer<UInt64>(lengthBytes).memory
		}else{
			let result = data[offset];
			offset++
			return UInt64(result);
		}
	}
	
	private static func getChildern(data:[UInt8], length:UInt64, inout offset:Int) throws -> [TWTLV]{
		var children = [TWTLV]()
		while (offset < data.count){
			children.append(try TWTLV.init(data: data, offset:&offset));
		}
		return children
	}
	
}
