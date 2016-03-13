//
//  MovingAverage.swift
//  CsoundBasic2
//
//  Created by Carlos Millan on 3/12/16.
//  Copyright © 2016 Carlos Millan. All rights reserved.
//

import Foundation


class MovingAverage {
    var samples: Array<Double>
    var sampleCount = 0
    var period = 5
    
    init(period: Int = 5) {
        self.period = period
        samples = Array<Double>()
    }
    
    var average: Double {
        let sum: Double = samples.reduce(0, combine: +)
        
        if period > samples.count {
            return sum / Double(samples.count)
        } else {
            return sum / Double(period)
        }
    }
    
    func addSample(value: Double) -> Double {
        let pos = Int(fmodf(Float(sampleCount++), Float(period)))
        
        if pos >= samples.count {
            samples.append(value)
        } else {
            samples[pos] = value
        }
        //print("average=\(average)")
        return average
    }
}