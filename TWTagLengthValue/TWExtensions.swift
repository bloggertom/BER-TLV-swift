//
//  TWIntegerTypeExtentions.swift
//  TWTagLengthValue
//
//  Created by Thomas Wilson on 28/11/2015.
//  Copyright © 2015 Thomas Wilson. All rights reserved.
//

import Foundation

extension Int {
	func toByteArray() -> [UInt8]{
		var moo = self
		var array = withUnsafePointer(&moo) {
			return Array(UnsafeBufferPointer(start: UnsafePointer<UInt8>($0), count: sizeof(Int)))
		}
		array = array.reverse()
		
		guard let index = array.indexOf({$0 > 0}) else {
			return Array(array)
		}
		
		if index != array.endIndex-1 {
			return Array(array[index...array.endIndex-1])
		}else{
			return [array.last!]
		}
	}
}

extension UInt64 {
	func toByteArray() -> [UInt8]{
		var moo = self
		var array = withUnsafePointer(&moo) {
			return Array(UnsafeBufferPointer(start: UnsafePointer<UInt8>($0), count: sizeof(UInt64)))
		}
		array = array.reverse()
		
		guard let index = array.indexOf({$0 > 0}) else {
			return Array(array)
		}
		
		if index != array.endIndex-1 {
			return Array(array[index...array.endIndex-1])
		}else{
			return [array.last!]
		}
		
	}
}

extension UInt8 {
	public func toAsciiHex() -> String{
		let temp = self;
		return String(format: "%02X", temp);
	}
	
	func isConstructedTag() -> Bool{
		return ((self & 0x20) == 0x20)
	}
}

extension String{
	public func asciiHexToData() -> [UInt8]?{
		let trimmedString = self.stringByTrimmingCharactersInSet(NSCharacterSet(charactersInString: "<> ")).stringByReplacingOccurrencesOfString(" ", withString: "")
		
		if(isValidHex(trimmedString)){
			var data = [UInt8]()
			
			for var index = trimmedString.startIndex; index < trimmedString.endIndex; index = index.successor().successor() {
				let byteString = trimmedString.substringWithRange(Range<String.Index>(start: index, end: index.successor().successor()))
				let num = UInt8(byteString.withCString { strtoul($0, nil, 16) })
				data.append(num)
			}
			
			return data
		}else{
			return nil
		}
	}
}