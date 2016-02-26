//
//  BasicInstrument.swift
//  Singerpad
//
//  Created by Carlos Millan on 12/31/15.
//  Copyright © 2015 Carlos Millan. All rights reserved.
//

import Foundation


class BasicInstrument: NSObject, CsoundInstrument 
{
    var csound: CsoundObj
    
    init?(csd: String, csound csound_: CsoundObj) {
        csound = csound_
        super.init()
        if let mb: NSBundle = NSBundle.mainBundle(),
            tempFile: String? = mb.pathForResource(csd, ofType: "csd") {
                csound.addBinding(self)
                csound.play(tempFile)
        } else {
            return nil
        }
    }
    
    func newNote() -> PlainNote? {
        if let i = csdLinks.indexOf({$0.note==nil}) {
            csdLinks[i].note = BasicNote(instrument: self,
                idInCsd: csdLinks[i].idInCsd)
            return csdLinks[i].note
        }
        return nil
    }
    
    func deleteNote(note: PlainNote) {
        if let note = note as? BasicNote,
           i = csdLinks.indexOf({$0.note === note}) {
            note.sounding = false
            csdLinks[i].note = nil
        }
    }
    
    func setup(csoundObj: CsoundObj) {
        for idInCsd in 0..<csdLinks.count {
            
            csdLinks[idInCsd].idInCsd = idInCsd
            
            csdLinks[idInCsd].frqChannel =
                csoundObj.getInputChannelPtr("freq.\(idInCsd)",
                    channelType: CSOUND_CONTROL_CHANNEL)
            
            csdLinks[idInCsd].volChannel =
                csoundObj.getInputChannelPtr("vol.\(idInCsd)",
                    channelType: CSOUND_CONTROL_CHANNEL)
            
            csdLinks[idInCsd].vibChannel =
                csoundObj.getInputChannelPtr("vib.\(idInCsd)",
                    channelType: CSOUND_CONTROL_CHANNEL)

        }
    }
    
    
    func cleanup()
    {
        for var csdLink in csdLinks {
            csdLink.frqChannel = nil
            csdLink.volChannel = nil
            csdLink.vibChannel = nil
        }

    }
    
    func updateValuesFromCsound()
    {
    }
    
    func updateValuesToCsound()
    {
        for csdLink in csdLinks {
            csdLink.updateChannels()
        }
    }

    
    class BasicNote: PlainNote {
        init(instrument instr_: BasicInstrument, idInCsd idInCsd_: Int) {
            instrument = instr_
            idInCsd = idInCsd_
        }
        var instrument: BasicInstrument
        var _sounding: Bool = false
        var sounding: Bool {
            get {
                return _sounding
            }
            set {
                guard _sounding != newValue else {return}
                _sounding = newValue
                if newValue {
                    instrument.csound.sendScore("i1.\(idInCsd) 0 -1 \(idInCsd)")
                } else {
                    instrument.csound.sendScore("i-1.\(idInCsd) 0 0 \(idInCsd)")
                }
            }
        }
        var hertz: Float = 0
        var volume: Float = 0
        var vibrato: Float = 0
        var idInCsd: Int = 0
    }
    
    
    struct CsdLink {
        var frqChannel : UnsafeMutablePointer<Float>! = nil
        var volChannel : UnsafeMutablePointer<Float>! = nil
        var vibChannel : UnsafeMutablePointer<Float>! = nil
        var idInCsd = 0
        var note : BasicNote? = nil
        func updateChannels () {
            if let note = note {
                frqChannel.memory = note.hertz
                volChannel.memory = note.volume
                vibChannel.memory = note.vibrato
            } else {
                frqChannel.memory = 0
                volChannel.memory = 0
                vibChannel.memory = 0
            }
        }
    }
    
    var csdLinks = [CsdLink](count: 10, repeatedValue: CsdLink())
    
    
}