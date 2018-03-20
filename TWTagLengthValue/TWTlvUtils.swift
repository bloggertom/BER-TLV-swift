//
//  TWTlvUtils.swift
//  TWTagLengthValue
//
//  Created by Thomas Wilson on 21/11/2015.
//  Copyright © 2015 Thomas Wilson. All rights reserved.
//

import Foundation


func bytesUsed(_ value:UInt64) -> UInt8{
	let array = value.toByteArray()
	var count:UInt8 = 0;
	for byte in array {
		if byte > 0 {
			count += 1;
		}
	}
	return count
}

func getLengthData(_ length:Int) -> [UInt8]{
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

func arrayToUInt64(_ data:[UInt8]) -> UInt64?{
	if(data.count > 8){
		return nil;
	}
	let nsdata = NSData(bytes: data.reversed(), length: data.count);
	var temp:UInt64 = 0;
	nsdata.getBytes(&temp, length: MemoryLayout<UInt64>.size);
	return temp;
}

func cleanHex(_ hexStr:String) -> String{
	return hexStr.trimmingCharacters(in: CharacterSet(charactersIn: "<> ")).replacingOccurrences(of: " ", with: "")
}

public func isValidHex(_ asciiHex:String) -> Bool{
	let regex = try! NSRegularExpression(pattern: "^[0-9a-f]*$", options: .caseInsensitive)
	
	let found = regex.firstMatch(in: asciiHex, options: [], range: NSMakeRange(0, asciiHex.count))
	if found == nil || found?.range.location == NSNotFound || asciiHex.count % 2 != 0 {
		return false;
	}
	
	return true;
}
