//
//  DictionaryExtensions.swift
//  Singerpad
//
//  Created by Carlos Millan on 1/2/16.
//  Copyright © 2016 Carlos Millan. All rights reserved.
//

import Foundation


extension Dictionary {
    func keysOf (@noescape predicate: (Key, Value) throws ->Bool) rethrows -> [Key]? {
        var result: [Key]!
        for (k, v) in self {
            if (try predicate(k,v)) {
                if result == nil {
                    result = [Key]()
                }
                result.append(k)
            }
        }
        return result
    }
}

extension Dictionary where Value : Equatable {
    func keysOf (value: Value) -> [Key]? {
        var result: [Key]!
        for (k, v) in self {
            if v == value {
                if result == nil {
                    result = [Key]()
                }
                result.append(k)
            }
        }
        return result
    }
}

