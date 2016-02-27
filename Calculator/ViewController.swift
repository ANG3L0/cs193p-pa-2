//
//  ViewController.swift
//  Calculator
//
//  Created by Angelo Wong on 2/22/16.
//  Copyright © 2016 Stanford. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    @IBOutlet weak var display: UILabel! //implicit unwrapped optional
    @IBOutlet weak var opHistory: UILabel!
    
    let errmsg = "N/A (please clear)"
    var userIsInTheMiddleOfTypingANumber = false
    var brain = CalculatorBrain()
    var freeze = false

    @IBAction func appendDigit(sender: UIButton) {
        if freeze { return }
        let digit = sender.currentTitle!
        let dupDecimal = decimalDupCheck(inputDigit: digit, stringToCheck: display.text)
        if userIsInTheMiddleOfTypingANumber {
            if !dupDecimal {
                display.text = display.text! + digit
            }
        } else {
            display.text = digit == "." ? "0" + digit : digit
            userIsInTheMiddleOfTypingANumber = true
        }
    }
    func decimalDupCheck(inputDigit digit: String, stringToCheck text: String?) -> Bool {
        if userIsInTheMiddleOfTypingANumber {
            return digit == "." && text?.containsString(".") == true
        } else {
            return false
        }
    }

    @IBAction func valueManip(sender: UIButton) {
        if freeze { return }
        let manipulator = sender.currentTitle!
        switch manipulator {
        case "⌫":
            delDispLastChar()
            if display.text!.isEmpty {
                display.text! = "0"
                userIsInTheMiddleOfTypingANumber = false //erased to 0, don't want to have "03" in display
            } else {
                userIsInTheMiddleOfTypingANumber = true
            }
        case "ᐩ/-":
            let startIdx = display.text!.startIndex
            if (!display.text!.isEmpty) {
                //cosmetic changes for nontyping, else actually do a *=-1
                if userIsInTheMiddleOfTypingANumber {
                    if (display.text![startIdx] != "-") {
                        display.text!.insert("-", atIndex: startIdx)
                    } else {
                        display.text!.removeAtIndex(startIdx)
                    }
                } else {
                    updateDispVal(manipulator)
                    appendDispEquals()
                    opHistory.text = brain.printOpHistory()
                }
            }
            
        default: break
        }
    }
    
    @IBAction func operate(sender: UIButton) {
        
        if userIsInTheMiddleOfTypingANumber {
            enter() //add to stack if say "6 enter 3 times"
        }
        if let operation = sender.currentTitle {
            if freeze && operation != "C" { return }
            updateDispVal(operation)
            if operation != "π" && operation != "C" {
                appendDispEquals()
            }
        }
        opHistory.text = brain.printOpHistory()
//        case "C":
//            resetCalc()
//            freeze = false
//            displayValue = 0
        //        }
        

    }

    
    
    
    @IBAction func enter() {
        if freeze { return }
        userIsInTheMiddleOfTypingANumber = false
        if let result = brain.pushOperand(displayValue) {
            displayValue = result
        } else {
            displayValue = nil
        }
    }
    
    var displayValue: Double? {
        get {
            if display.text!.characters.last == "=" {
                delDispLastChar()
            }
            if let strNumber = NSNumberFormatter().numberFromString(display.text!) {
                return strNumber.doubleValue
            } else {
                //special case of PI and the spec to clear the display if N/A
                if (display.text! != "π") {
                    display.text = errmsg
                    freeze = true
                    resetCalc()
                    return 0
                }
                return M_PI
            }
        }
        set {
            if let num = newValue {
                display.text = num == M_PI ? "π" : "\(num)"
            } else {
                display.text = "N/A"
            }
            
            userIsInTheMiddleOfTypingANumber = false
        }
    }
    private func delDispLastChar() {
        display.text! = String(display.text!.characters.dropLast())
    }
    private func appendDispEquals() {
        if (display.text!.characters.last != "=" && display.text! != errmsg) {
            display.text! += "="
        }
    }
    private func resetCalc() {
        userIsInTheMiddleOfTypingANumber = false
        opHistory.text! = ""
    }
    private func updateDispVal(operation: String) {
        if let result = brain.performOperation(operation) {
            displayValue = result
        } else {
            displayValue = nil
        }
    }
}

