//
//  String.swift
//  Mane HKU
//
//  Created by Yau Chin Pang on 6/1/2024.
//

import Foundation

func checkPattern(allowed: String, input: String) -> Bool {
    guard !input.isEmpty else {
        return false
    }
    let characterSet = CharacterSet(charactersIn: allowed)
    guard input.rangeOfCharacter(from: characterSet.inverted) == nil else {
        return false
    }
    return true
}

extension String {
    public var isAlphanumeric: Bool {
            let allowed = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ1234567890"
            return checkPattern(allowed: allowed, input: self)
        }
    
    public var isAlphabetical: Bool {
        let allowed = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ"
        return checkPattern(allowed: allowed, input: self)
        }
}
