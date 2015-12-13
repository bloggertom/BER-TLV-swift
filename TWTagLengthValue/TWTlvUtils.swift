//
//  TWTlvUtils.swift
//  TWTagLengthValue
//
//  Created by Thomas Wilson on 21/11/2015.
//  Copyright © 2015 Thomas Wilson. All rights reserved.
//

import Foundation


func bytesUsed(value:UInt64) -> UInt8{
	let array = value.toByteArray()
	var count:UInt8 = 0;
	for byte in array {
		if byte > 0 {
			count++;
		}
	}
	return count
}

func getLengthData(length:Int) -> [UInt8]{
	if(length > 127){
		var result = [UInt8]()
		let byteCount = bytesUsed(UInt64(length))
		let lengthsLength:UInt8 = 0x80 | byteCount;
		result.append(lengthsLength);
		let lengthArray = length.toByteArray();
		for byte in lengthArray {
			if(byte > 0){
				result.append(byte)
			}
		}
		return result;
	}else{
		return [length.toByteArray().last!]
	}
}

func arrayToUInt64(data:[UInt8]) -> UInt64?{
	if(data.count > 8){
		return nil;
	}
	let temp = NSData(bytes: data.reverse(), length: data.count)
	return UnsafePointer<UInt64>(temp.bytes).memory
}

func cleanHex(hexStr:String) -> String{
	return hexStr.stringByTrimmingCharactersInSet(NSCharacterSet(charactersInString: "<> ")).stringByReplacingOccurrencesOfString(" ", withString: "")
}

public func isValidHex(asciiHex:String) -> Bool{
	let regex = try! NSRegularExpression(pattern: "^[0-9a-f]*$", options: .CaseInsensitive)
	
	let found = regex.firstMatchInString(asciiHex, options: [], range: NSMakeRange(0, asciiHex.characters.count))
	if found == nil || found?.range.location == NSNotFound || asciiHex.characters.count % 2 != 0 {
		return false;
	}
	
	return true;
}