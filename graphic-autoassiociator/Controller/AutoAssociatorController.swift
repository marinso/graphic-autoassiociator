//
//  ViewController.swift
//  graphic-autoassiociator
//
//  Created by Martin Nasierowski on 30/11/2019.
//  Copyright © 2019 Martin Nasierowski. All rights reserved.
//

import UIKit
import Accelerate

struct RGB {
   var r: Float
   var g: Float
   var b: Float
}

var RGBPosition = [String: RGB]()

class AutoAssiociatorController: UIViewController {
    
    // MARK: - VARIABLES
    
    var HIDDEN_LAYERS_AMOUNT = 3
    var NEURONS_IN_LAYER_AMOUNT = 24
    var LEARNING_VALUE:Float = 0.1
    var LEARNING_STEPS = 4000000
    var imageSIZE = 256

    var HIDDEN_LAYERS = [[Neuron]]()
    var OUTPUT_LAYER  = [Neuron]()
    
    var INPUT_DATA = [Float]()
    
    var result = [String: RGB]()
    
    let brainView: UIImageView = {
        let iv = UIImageView()
        iv.image = UIImage(named: "mustang")
        return iv
    }()
    
    let outputView: Canvas = {
        let canvas = Canvas()
        canvas.backgroundColor = .white
        return canvas
    }()
    
    let checkButton: UIButton = {
        let btn = UIButton(type: .system)
        btn.setTitle("Check", for: .normal)
        btn.addTarget(self, action: #selector(handleCheck), for: .touchUpInside)
        btn.setTitleColor(.black, for: .normal)
        return btn
    }()
    
    let learnButton: UIButton = {
        let btn = UIButton(type: .system)
        btn.setTitle("Learn", for: .normal)
        btn.addTarget(self, action: #selector(learnNeuralNetwork), for: .touchUpInside)
        btn.setTitleColor(.black, for: .normal)
        return btn
    }()
    
    // MARK: - DID LOAD

    override func viewDidLoad() {
        super.viewDidLoad()
        reDrawPicture()
        createUI()
        createNeuralNetwork()
    }
    
    func createUI() {
        view.addSubview(brainView)
        view.addSubview(outputView)
        view.addSubview(checkButton)
        view.addSubview(learnButton)

        brainView.anchor(top: view.topAnchor, bottom: nil, left: nil, right: nil, paddingTop: 60, paddingBottom: 0, paddingLeft: 0, paddingRight: 0, width: CGFloat(imageSIZE), height: CGFloat(imageSIZE))
        brainView.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        
        outputView.anchor(top: brainView.bottomAnchor, bottom: nil, left: nil, right: nil, paddingTop: 60, paddingBottom: 0, paddingLeft: 0, paddingRight: 0, width: CGFloat(imageSIZE), height: CGFloat(imageSIZE))
        outputView.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        
        checkButton.anchor(top: nil, bottom: view.bottomAnchor, left: view.leftAnchor, right: nil, paddingTop: 0, paddingBottom: 100, paddingLeft: 50, paddingRight: 0, width: 0, height: 0)
        
        learnButton.anchor(top: nil, bottom: view.bottomAnchor, left: nil, right: view.rightAnchor, paddingTop: 0, paddingBottom: 100, paddingLeft: 0, paddingRight: 50, width: 0, height: 0)

        view.backgroundColor = UIColor.init(red: 183/255, green: 196/255, blue: 208/255, alpha: 1)
    }
    
    func reDrawPicture() {
        let image = UIImage.init(named: "mustang")
        
        let width = Int(image!.size.width)
        let height = Int(image!.size.height)
        
        for y in 0...height-1 {
            for x in 0...width-1 {
                let rgb = image!.getRGB(x: x, y: y)
                let key = "\(x)-\(y)"
                let value = RGB.init(r: Float(rgb!["red"]!), g: Float(rgb!["green"]!), b: Float(rgb!["blue"]!))
                RGBPosition[key] = value
            }
        }
    }
    
    //MARK: - CREATE NEURAL NETWORK
    
    func createNeuralNetwork() {
        
        for i in 0...HIDDEN_LAYERS_AMOUNT-1 {
            var temp_layer = [Neuron]()
            for _ in 0...NEURONS_IN_LAYER_AMOUNT-1 {
                if (i == 0) {
                    temp_layer.append(Neuron.init(weights: getRandomWeights(amount: 10), x: 0, y: 0, delta: 0));
                } else {
                    temp_layer.append(Neuron.init(weights: getRandomWeights(amount: NEURONS_IN_LAYER_AMOUNT), x: 0, y: 0, delta: 0))
                }
            }
            HIDDEN_LAYERS.append(temp_layer)
        }

        //Initialize output layer which contains 3 neurons for R, G, B
        OUTPUT_LAYER.append(Neuron.init(weights: getRandomWeights(amount: NEURONS_IN_LAYER_AMOUNT), x: 0, y: 0, delta: 0));
        OUTPUT_LAYER.append(Neuron.init(weights: getRandomWeights(amount: NEURONS_IN_LAYER_AMOUNT), x: 0, y: 0, delta: 0));
        OUTPUT_LAYER.append(Neuron.init(weights: getRandomWeights(amount: NEURONS_IN_LAYER_AMOUNT), x: 0, y: 0, delta: 0));
    }
    
    func getRandomWeights(amount:Int) -> [Float] {
        var weights = [Float]()
        
        for _ in 0...amount {
            weights.append(Float.random(in: 0..<1) * 2 - 1)
        }
        
        return weights
    }
    
    // MARK: - FORWARD TRANSITION
    
    func runForwardNetworkTransition(_ x:Int,_ y:Int) {
        
        let x_prim: Float = Float(x / ( imageSIZE / 2 ) - 1)
        let y_prim: Float = Float(y / ( imageSIZE / 2 ) - 1)
        
        INPUT_DATA = [x_prim, y_prim]
        
        for i in 1...4 {
            INPUT_DATA.append(sin(Float(i) * ( Float(x / imageSIZE ) * 2 * Float.pi)))
            INPUT_DATA.append(sin(Float(i) * ( Float(y / imageSIZE ) * 2 * Float.pi)))
        }
        
        // bias
        INPUT_DATA.append(1)
        
        //Calculation of entry and output value for all neurons in all hidden layers
        for i in 0...HIDDEN_LAYERS.count-1 {
            if i == 0 {
                for j in 0...NEURONS_IN_LAYER_AMOUNT-1 {
                    HIDDEN_LAYERS[i][j].x = getMultiplicationResult(weights: HIDDEN_LAYERS[i][j].weights, values: INPUT_DATA)
                    HIDDEN_LAYERS[i][j].neuronOutputValue()
                }
            } else {
                var outputValuesFromPreviousLayerNeurons = [Float]()
                
                for n in 0...HIDDEN_LAYERS[i-1].count-1 {
                    outputValuesFromPreviousLayerNeurons.append(HIDDEN_LAYERS[i-1][n].y)
                }
                
                outputValuesFromPreviousLayerNeurons.append(1)
                
                for p in 0...NEURONS_IN_LAYER_AMOUNT-1 {
                    HIDDEN_LAYERS[i][p].x = getMultiplicationResult(weights: HIDDEN_LAYERS[i][p].weights, values: outputValuesFromPreviousLayerNeurons)
                    HIDDEN_LAYERS[i][p].neuronOutputValue()
                }
            }
        }
        
        //Calculation of entry and output value for all neurons in output layer
        var outputValuesFromPreviousLayerNeurons = [Float]()
        
        for i in 0...HIDDEN_LAYERS[HIDDEN_LAYERS_AMOUNT-1].count-1 {
            outputValuesFromPreviousLayerNeurons.append(HIDDEN_LAYERS[HIDDEN_LAYERS_AMOUNT - 1][i].y)
        }
        
        outputValuesFromPreviousLayerNeurons.append(1)
        
        for i in 0...OUTPUT_LAYER.count-1 {
            OUTPUT_LAYER[i].x = getMultiplicationResult(weights: OUTPUT_LAYER[i].weights, values: outputValuesFromPreviousLayerNeurons)
            OUTPUT_LAYER[i].neuronOutputValue()
        }
    }
    
    func getMultiplicationResult(weights: [Float], values: [Float]) -> Float {
       var summary:Float = 0
       vDSP_dotpr(weights, 1, values, 1, &summary, vDSP_Length(values.count))
       return (summary)
    }
    
    // MARK: - DELTA
    
    func deltaCalculation(_ correct_RGB: RGB) {
        
        //Backward network transition and delta calculation
        OUTPUT_LAYER[0].deltaInOutputLayer(correct_answer: reduceRangeOfValue(value: correct_RGB.r))
        OUTPUT_LAYER[1].deltaInOutputLayer(correct_answer: reduceRangeOfValue(value: correct_RGB.g))
        OUTPUT_LAYER[2].deltaInOutputLayer(correct_answer: reduceRangeOfValue(value: correct_RGB.b))
        
        for i in 0...HIDDEN_LAYERS_AMOUNT-1 {
            for j in 0...NEURONS_IN_LAYER_AMOUNT-1 {
                if ( i == HIDDEN_LAYERS_AMOUNT-1) {
                    var temp_value:Float = 0
                    
                    for n in 0...2 {
                        temp_value += (OUTPUT_LAYER[n].delta * OUTPUT_LAYER[n].weights[j]);
                    }
                    
                    HIDDEN_LAYERS[i][j].delta = temp_value * HIDDEN_LAYERS[i][j].y * ( 1 - HIDDEN_LAYERS[i][j].y )
                } else {
                    var temp_value:Float = 0
                    
                    for m in 0...NEURONS_IN_LAYER_AMOUNT-1 {
                        temp_value += (HIDDEN_LAYERS[i + 1][m].delta * HIDDEN_LAYERS[i + 1][m].weights[j])
                    }
                    
                    HIDDEN_LAYERS[i][j].delta = temp_value *  HIDDEN_LAYERS[i][j].y * ( 1 - HIDDEN_LAYERS[i][j].y )
                }
            }
        }
    }
    
    func reduceRangeOfValue(value: Float) -> Float {
        return (((value / 255) * 0.8) + 0.1)
    }
    
    // MARK: - UPDATE WEIGHTS
    
    func updateWeightsInHiddenLayers() {
        for i in 0...HIDDEN_LAYERS_AMOUNT-1 {
            for j in 0...NEURONS_IN_LAYER_AMOUNT-1 {
                
                let computedDelta = LEARNING_VALUE * HIDDEN_LAYERS[i][j].delta

                for k in 0...HIDDEN_LAYERS[i][j].weights.count-1 {
                    
                    if i == 0 {
                        HIDDEN_LAYERS[i][j].weights[k] -= (computedDelta * INPUT_DATA[k])
                    }
                    else {
                        if (HIDDEN_LAYERS[i - 1].indices.contains(k)) {
                            HIDDEN_LAYERS[i][j].weights[k] -= (computedDelta * HIDDEN_LAYERS[i - 1][k].y)
                        } else {
                            HIDDEN_LAYERS[i][j].weights[k] -= computedDelta
                        }
                    }
                }
            }
        }
    }
    
    func updateWeightsInOutputLayers() {
        
       for i in 0...OUTPUT_LAYER.count-1 {
           for j in 0...OUTPUT_LAYER[i].weights.count-1 {
            
               let computedDelta = LEARNING_VALUE * OUTPUT_LAYER[i].delta

               if (HIDDEN_LAYERS[HIDDEN_LAYERS_AMOUNT - 1].indices.contains(j)) {
                
                   OUTPUT_LAYER[i].weights[j] = OUTPUT_LAYER[i].weights[j] - ( computedDelta * HIDDEN_LAYERS[HIDDEN_LAYERS_AMOUNT - 1][j].y)
                
               } else {
                   OUTPUT_LAYER[i].weights[j] -= computedDelta
               }
           }
       }
    }
    
    // MARK: - HANDLERS
    
    @objc func handleCheck() {
        for y in 0...imageSIZE-1 {
            for x in 0...imageSIZE-1 {
                
                runForwardNetworkTransition(x, y)
                
                let R = (((255 * OUTPUT_LAYER[0].y) - 25.5) / 0.8)
                let G = (((255 * OUTPUT_LAYER[1].y) - 25.5) / 0.8)
                let B = (((255 * OUTPUT_LAYER[2].y) - 25.5) / 0.8)
                
                let key = "\(x)-\(y)"
                let value = RGB.init(r: R, g: G, b: B)
                result[key] = value
            }
        }
        
        self.outputView.check(result)
    }
    
//    @objc func learnNeuralNetwork() {
//
//        for x in 0...0 {
//
//            printTimeElapsedWhenRunningCode(title: "fmod") {
//                if fmod( Double(x), 1000.0) == 0 {
//                    print(x)
//                }
//            }
//
//            let x = Int.random(in: 0...255)
//            let y = Int.random(in: 0...255)
//
//            printTimeElapsedWhenRunningCode(title: "forward") {
//                runForwardNetworkTransition(x,y)
//            }
//
//            let correct_RGB = RGBPosition["\(x)-\(y)"]!
//
//            printTimeElapsedWhenRunningCode(title: "Delta") {
//                deltaCalculation(correct_RGB)
//            }
//
//            printTimeElapsedWhenRunningCode(title: "Update Hidden") {
//                updateWeightsInHiddenLayers()
//            }
//
//            printTimeElapsedWhenRunningCode(title: "Update Output") {
//                updateWeightsInOutputLayers()
//            }
//        }
//    }
    
    @objc func learnNeuralNetwork() {

        for x in 0...LEARNING_STEPS {

            if fmod( Double(x), 10000.0) == 0 {
                print(x)
            }

            let x = Int.random(in: 0...imageSIZE-1)
            let y = Int.random(in: 0...imageSIZE-1)

            runForwardNetworkTransition(x,y)

            let correct_RGB = RGBPosition["\(x)-\(y)"]!

            deltaCalculation(correct_RGB)

            updateWeightsInHiddenLayers()

            updateWeightsInOutputLayers()
        }
    }
    
    // MARK: - TIME
    
    func printTimeElapsedWhenRunningCode(title:String, operation:()->()) {
        let startTime = CFAbsoluteTimeGetCurrent()
        operation()
        let timeElapsed = CFAbsoluteTimeGetCurrent() - startTime
        print("Time elapsed for \(title): \(timeElapsed) s.")
    }
}

