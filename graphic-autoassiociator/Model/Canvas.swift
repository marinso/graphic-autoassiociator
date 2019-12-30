//
//  Canvas.swift
//  graphic-autoassiociator
//
//  Created by Martin Nasierowski on 30/11/2019.
//  Copyright © 2019 Martin Nasierowski. All rights reserved.
//

import UIKit
import CoreGraphics

class Canvas: UIView {
    
    var rgbPosition = [String: RGB]()
                
    override func draw(_ rect: CGRect) {
        super.draw(rect)
    
        let context = UIGraphicsGetCurrentContext()
        
        for (key,value) in rgbPosition {
            
            let end = key.firstIndex(of: "-")!
            let x:Int = Int(String(key[..<end]))!
            var y:Int = Int(String(key[end...]))!
            y = y * (-1) 
            
            
            let clipPath = UIBezierPath(roundedRect: CGRect(x: x, y: y, width: 1, height: 1), cornerRadius: 0.0).cgPath
            context?.addPath(clipPath)

            context?.setFillColor(red: CGFloat(value.r), green: CGFloat(value.g), blue: CGFloat(value.b), alpha: 1)

            context?.closePath()
            context?.fillPath()
        }
        setNeedsDisplay()
    }
    
    func reDraw() {
        setNeedsDisplay()
    }
    
    func check(_ rgbPosition: [String: RGB]) {
        self.rgbPosition = rgbPosition
        
        setNeedsDisplay()
    }
}
