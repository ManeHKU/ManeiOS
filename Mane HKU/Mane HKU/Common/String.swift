//
//  String.swift
//  Mane HKU
//
//  Created by Yau Chin Pang on 6/1/2024.
//

import Foundation

extension String {
    public var isAlphanumeric: Bool {
            guard !isEmpty else {
                return false
            }
            let allowed = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ1234567890"
            let characterSet = CharacterSet(charactersIn: allowed)
            guard rangeOfCharacter(from: characterSet.inverted) == nil else {
                return false
            }
            return true
        }
}
