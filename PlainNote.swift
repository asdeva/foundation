//
//  PlainNote.swift
//  Singerpad
//
//  Created by Carlos Millan on 12/31/15.
//  Copyright © 2015 Carlos Millan. All rights reserved.
//

import Foundation

protocol PlainNote {
    var sounding: Bool {get set}
    var hertz: Float {get set}
    var volume: Float {get set}
    var vibrato: Float {get set}
}

extension PlainNote {
    var hertz: (Float, Int) {
        get {
            return (hertz, 0)
        }
        set {
            hertz = newValue.0 * Float(pow(2, Float(newValue.1)/Float(12.0)))
            print(hertz)
        }
    }
}
