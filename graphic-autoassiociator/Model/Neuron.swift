//
//  Neuron.swift
//  graphic-autoassiociator
//
//  Created by Martin Nasierowski on 30/11/2019.
//  Copyright © 2019 Martin Nasierowski. All rights reserved.
//

import Foundation

class Neuron {
    
     var weights: [Float]
     var x: Float
     var y: Float
     var delta: Float
    
    init(weights: [Float], x: Float, y: Float, delta: Float) {
        self.weights = weights
        self.delta = 0
        self.x = 0
        self.y = 0
    }
    
    func neuronOutputValue() {
        self.y = (1 / (1 + exp(self.x * (-1))))
    }

    func deltaInOutputLayer(correct_answer: Float) {
        self.delta = (self.y - correct_answer) * (self.y * (1 - self.y))
    }
}
