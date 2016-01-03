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
}