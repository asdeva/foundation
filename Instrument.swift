//
//  Instrument.swift
//  Singerpad
//
//  Created by Carlos Millan on 12/31/15.
//  Copyright © 2015 Carlos Millan. All rights reserved.
//

import Foundation

protocol Instrument {
    typealias Note
    func newNote() -> Note?
    func deleteNote(note: Note) -> ()
}


protocol CsoundInstrument: Instrument, CsoundBinding {
    
}
