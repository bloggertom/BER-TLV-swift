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
		var moo = self;
		var array = withUnsafeBytes(of: &moo) { Array($0) }
		array = array.reversed()
		guard let index = array.index(where: {$0 > 0}) else {
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
		var array = withUnsafeBytes(of: &moo) { Array($0) }
		array = array.reversed()
		
		guard let index = array.index(where: {$0 > 0}) else {
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
		
		let trimmedString = self.trimmingCharacters(in: CharacterSet(charactersIn: "<> ")).replacingOccurrences(of: " ", with: "")
		
		if(isValidHex(trimmedString)){
			var data = [UInt8]()
			var index = 0
			while index < trimmedString.count {

				let start = trimmedString.index(trimmedString.startIndex, offsetBy: index);
				let finish = trimmedString.index(trimmedString.startIndex,offsetBy: index+1);
				let range = start...finish
				let byteString = trimmedString[range]
				
				let byte = UInt8(byteString.withCString { strtoul($0, nil, 16) })
				data.append(byte)

				index = index+2;
			}
			
			return data
		}else{
			return nil
		}
	}
}
