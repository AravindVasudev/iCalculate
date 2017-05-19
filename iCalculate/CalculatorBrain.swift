//
//  ClaculatorBrain.swift
//  iCalculate
//
//  Created by Aravind Vasudevan on 5/19/17.
//  Copyright © 2017 Aravind Vasudevan. All rights reserved.
//

import Foundation

struct CalculatorBrain {
    private var accumlator: Double?
    
    private enum Operation {
        case constant(Double)
        case unaryOperation((Double) -> Double)
        case binaryOperation((Double, Double) -> Double)
        case equals
    }
    
    private struct PendingBinaryOperation {
        let function: (Double, Double) -> Double
        let firstOperand: Double
        
        func perform(with secondOperand: Double) -> Double {
            return function(firstOperand, secondOperand)
        }
    }
    
    private var pendingBinaryOperation: PendingBinaryOperation?

    private var operations: Dictionary<String, Operation> = [
        "π"   : Operation.constant(Double.pi),
        "e"   : Operation.constant(M_E),
        "√"   : Operation.unaryOperation(sqrt),
        "x²"  : Operation.unaryOperation({ $0 * $0 }),
        "±"   : Operation.unaryOperation({ -$0 }),
        "×"   : Operation.binaryOperation({ $0 * $1 }),
        "÷"   : Operation.binaryOperation({ $0 / $1 }),
        "+"   : Operation.binaryOperation({ $0 + $1 }),
        "-"   : Operation.binaryOperation({ $0 - $1 }),
        "sin" : Operation.unaryOperation(sin),
        "tan" : Operation.unaryOperation(tan),
        "cos" : Operation.unaryOperation(cos),
        "log" : Operation.unaryOperation(log),
        "ln" : Operation.unaryOperation({ 2.303 * log($0) }),
        "="   : Operation.equals
    ]
    
    var result: Double? {
        get {
            return accumlator
        }
    }
    
    mutating func performOperation(_ symbol: String) {
        if let operation = operations[symbol] {
            switch operation {
                case .constant(let value):
                    accumlator = value
                case .unaryOperation(let function):
                    if accumlator != nil {
                        accumlator = function(accumlator!)
                    }
                case .binaryOperation(let function):
                    if accumlator != nil {
                        pendingBinaryOperation = PendingBinaryOperation(function: function, firstOperand: accumlator!)
                        accumlator = nil
                    }
                case .equals:
                    performPendingBinaryOperation()
            }
        }
    }
    
    private mutating func performPendingBinaryOperation() {
        if pendingBinaryOperation != nil && accumlator != nil {
            accumlator = pendingBinaryOperation!.perform(with: accumlator!)
            pendingBinaryOperation = nil
        }
    }
    
    mutating func setOperand(_ operand: Double) {
        accumlator = operand
    }
}
