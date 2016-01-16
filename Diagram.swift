//
//  Diagram.swift
//  CoreGraphicsFunctional
//
//  Created by Carlos Millan on 8/26/15.
//  Copyright (c) 2015 Carlos Millan. All rights reserved.
//

import Foundation
import UIKit


// A 2-D Vector
struct Vector2D {
    let x: CGFloat
    let y: CGFloat
    var point : CGPoint { return CGPointMake(x, y) }
    var size : CGSize { return CGSizeMake(x, y) }
}

func *(l: CGPoint, r: CGRect) -> CGPoint {
    return CGPointMake(r.origin.x + l.x*r.size.width,
        r.origin.y + l.y*r.size.height)
}


func *(l: CGFloat, r: CGPoint) -> CGPoint {
    return CGPointMake(l*r.x, l*r.y)
}
func *(l: CGFloat, r: CGSize) -> CGSize {
    return CGSizeMake(l*r.width, l*r.height)
}

func pointWise(f: (CGFloat, CGFloat) -> CGFloat,
    l: CGRect, r: CGPoint) -> CGPoint {
        
        return CGPointMake(f(l.width, r.x), f(l.height, r.y))
}

func pointWise(f: (CGFloat, CGFloat) -> CGFloat,
    l: CGPoint, r: CGRect) -> CGPoint {
        
        return CGPointMake(f(l.x, r.width), f(l.y, r.height))
}


func pointWise(f: (CGFloat, CGFloat) -> CGFloat,
    l: CGSize, r: CGSize) -> CGSize {
        
        return CGSizeMake(f(l.width, r.width), f(l.height, r.height))
}

func pointWise(f: (CGFloat, CGFloat) -> CGFloat,
    l: CGPoint, r:CGPoint) -> CGPoint {
        
        return CGPointMake(f(l.x, r.x), f(l.y, r.y))
}

func /(l: CGSize, r: CGSize) -> CGSize {
    return pointWise(/, l: l, r: r)
}
func *(l: CGSize, r: CGSize) -> CGSize {
    return pointWise(*, l: l, r: r)
}
func +(l: CGSize, r: CGSize) -> CGSize {
    return pointWise(+, l: l, r: r)
}
func -(l: CGSize, r: CGSize) -> CGSize {
    return pointWise(-, l: l, r: r)
}

func /(l: CGPoint, r: CGRect) -> CGPoint {
    return pointWise(/, l: l, r: r)
}

func /(l: CGRect, r: CGPoint) -> CGPoint {
    return pointWise(/, l: l, r: r)
}


func -(l: CGPoint, r: CGPoint) -> CGPoint {
    return pointWise(-, l: l, r: r)
}
func +(l: CGPoint, r: CGPoint) -> CGPoint {
    return pointWise(+, l: l, r: r)
}
func *(l: CGPoint, r: CGPoint) -> CGPoint {
    return pointWise(*, l: l, r: r)
}
func /(l: CGPoint, r: CGPoint) -> CGPoint {
    return pointWise(/, l: l, r: r)
}



extension CGSize {
    var point : CGPoint {
        return CGPointMake(self.width, self.height)
    }
}

func isHorizontalEdge(edge: CGRectEdge) -> Bool {
    switch edge {
    case .MaxXEdge, .MinXEdge:
        return true
    default:
        return false
    }
}

func splitRect(rect: CGRect, sizeRatio: CGSize,
    edge: CGRectEdge) -> (CGRect, CGRect) {
        
        let ratio = isHorizontalEdge(edge) ? sizeRatio.width
            : sizeRatio.height
        let multiplier = isHorizontalEdge(edge) ? rect.width
            : rect.height
        let distance : CGFloat = multiplier * ratio
        var mySlice : CGRect = CGRectZero
        var myRemainder : CGRect = CGRectZero
        CGRectDivide(rect, &mySlice, &myRemainder, distance, edge)
        return (mySlice, myRemainder)
}

func splitHorizontal(rect: CGRect,
    ratio: CGSize) -> (CGRect, CGRect) {
        
        return splitRect(rect, sizeRatio: ratio, edge: CGRectEdge.MinXEdge)
}

func splitVertical(rect: CGRect,
    ratio: CGSize) -> (CGRect, CGRect) {
        
        return splitRect(rect, sizeRatio: ratio, edge: CGRectEdge.MinYEdge)
}

enum Primitive {
    case Ellipse
    case Rectangle
    case Text(String)
}


indirect enum Diagram {
    case Prim(CGSize, Primitive)
    case Beside(Diagram, Diagram)
    case Below(Diagram, Diagram)
    case Attributed(Attribute, Diagram)
    case Align(Vector2D, Diagram)
}

enum Attribute {
    case FillColor(UIColor)
    case StrokeColor(UIColor)
}


extension Diagram {
    var size: CGSize {
        switch self {
        case .Prim(let size, _): return size
        case .Attributed(_, let x): return x.size
        case .Beside(let l, let r):
            let sizeL = l.size
            let sizeR = r.size
            return CGSizeMake(sizeL.width + sizeR.width,
                max(sizeL.height, sizeR.height))
        case .Below(let l, let r):
            let sizeL = l.size
            let sizeR = r.size
            return CGSizeMake(max( sizeL.width, sizeR.width),
                sizeL.height + sizeR.height)
        case .Align(_, let r): return r.size }
    }
}

func fit(alignment: Vector2D, inputSize: CGSize, rect: CGRect) -> CGRect
{
    let scaleSize = rect.size / inputSize
    let scale = min(scaleSize.width, scaleSize.height)
    let size = scale * inputSize
    let space = alignment.size * (size - rect.size)
    return CGRect(origin: rect.origin - space.point, size: size)
}

func makeLayer(bounds: CGRect, diagram: Diagram) -> CALayer?
{
    let v = Draw(frame: bounds, diagram: diagram)
    let result = CALayer(layer: v.layer)
    return result
}

func draw(context: CGContext, bounds: CGRect, diagram: Diagram)
{
    switch diagram
    {
    case .Prim(let size, .Ellipse):
        let frame = fit(Vector2D(x: 0.5, y: 0.5), inputSize: size, rect: bounds)
        CGContextFillEllipseInRect(context, frame)
        CGContextStrokeEllipseInRect(context, frame)
    case .Prim(let size, .Rectangle):
        let frame = fit(Vector2D(x: 0.5, y: 0.5), inputSize: size, rect: bounds)
        CGContextFillRect(context, frame)
        CGContextStrokeRect(context, frame)
    case .Prim(let size, .Text(let text)):
        let frame = fit(Vector2D(x: 0.5, y: 0.5), inputSize: size, rect: bounds)
        let font = UIFont.systemFontOfSize(12)
        let attributes = [NSFontAttributeName: font]
        let attributedText = NSAttributedString(
            string: text, attributes: attributes)
        attributedText.drawInRect(frame)
    case .Attributed(.FillColor(let color), let d):
        CGContextSaveGState(context)
        color.setFill()
        draw(context, bounds: bounds, diagram: d)
        CGContextRestoreGState(context)
    case .Attributed(.StrokeColor(let color), let d):
        CGContextSaveGState(context)
        color.setStroke()
        draw(context, bounds: bounds, diagram: d)
        CGContextRestoreGState(context)
    case .Beside(let left, let right):
        let l = left
        let r = right
        let (lFrame, rFrame) = splitHorizontal(
            bounds, ratio: l.size/diagram.size)
        draw(context, bounds: lFrame, diagram: l)
        draw(context, bounds: rFrame, diagram: r)
    case .Below(let top, let bottom):
        let t = top
        let b = bottom
        let (lFrame, rFrame) = splitVertical(
            bounds, ratio: t.size/diagram.size)
        draw(context, bounds: lFrame, diagram: t)
        draw(context, bounds: rFrame, diagram: b)
    case .Align(let vec, let d):
        let diagram = d
        let frame = fit(vec, inputSize: diagram.size, rect: bounds)
        draw(context, bounds: frame, diagram: diagram)
    }
}

class Draw: UIView
{
    let diagram: Diagram
    
    init(frame frameRect: CGRect, diagram: Diagram) {
        self.diagram = diagram
        super.init(frame:frameRect)
    }
    
    required init?(coder: NSCoder) {
        fatalError("NSCoding not supported")
    }
    
    override func drawRect(dirtyRect: CGRect) {
        if let context = UIGraphicsGetCurrentContext() {
            draw(context, bounds: self.bounds, diagram: diagram)
        }
    }
}


func rectangle(width width: CGFloat, height: CGFloat) -> Diagram {
    return Diagram.Prim(CGSizeMake(width, height), .Rectangle)
}

func circle(diameter diameter: CGFloat) -> Diagram {
    return Diagram.Prim(CGSizeMake(diameter, diameter), .Ellipse)
}

func text(width width: CGFloat,
    height: CGFloat, text theText: String) -> Diagram {
        
        return Diagram.Prim(CGSizeMake(width, height), .Text(theText))
}

func square(side side: CGFloat) -> Diagram {
    return rectangle(width: side, height: side)
}

infix operator ||| { associativity left }
func ||| (l: Diagram, r: Diagram) -> Diagram {
    return Diagram.Beside(l, r)
}

infix operator --- { associativity left }
func --- (l: Diagram, r: Diagram) -> Diagram {
    return Diagram.Below(l, r)
}

extension Diagram {
    func fill(color: UIColor) -> Diagram {
        return Diagram.Attributed(Attribute.FillColor(color),self)
    }
    
    func stroke(color: UIColor) -> Diagram {
        return Diagram.Attributed(Attribute.StrokeColor(color), self)
    }
    
    
    func alignTop() -> Diagram {
        return Diagram.Align(Vector2D(x: 0.5, y: 1), self)
    }
    
    func alignBottom() -> Diagram {
        return Diagram.Align(Vector2D(x:0.5, y: 0), self)
    }
}

let empty: Diagram = rectangle(width: 0, height: 0)

func hcat(diagrams: [Diagram]) -> Diagram {
    return diagrams.reduce(empty, combine: |||)
}












