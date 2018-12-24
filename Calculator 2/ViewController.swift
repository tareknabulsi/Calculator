//
//  ViewController.swift
//  Calculator 2
//
//  Created by Tarek Nabulsi on 10/27/18.
//  Copyright © 2018 Tarek's Ideas Inc. All rights reserved.
//

import UIKit
import AudioToolbox

class ViewController: UIViewController {
    
    @IBOutlet weak var clearButton: UIButton!
    @IBOutlet weak var divideButton: UIButton!
    @IBOutlet weak var multiplyButton: UIButton!
    @IBOutlet weak var minusButton: UIButton!
    @IBOutlet weak var plusButton: UIButton!
    var buttons: [UIButton] = []
    
    var lastButtonPressedTagNumber = 0
    var isDecimalPressed = false
    var numberString = ""
    var numOperator = ""
    var firstNumber: Double?
    var secondNumber: Double?
    var result: Double = 0
    
    let highlightedColor = UIColor(red:1.00, green:1.00, blue:1.00, alpha:1.0) //White
    var neutralColor: UIColor? //Orange. Set to divide button background color in viewDidLoad()
    
    @IBOutlet weak var numberLabel: UILabel!
    
    //MARK: - Number Buttons
    /***************************************************************/
    
    @IBAction func buttonNumber(_ sender: UIButton) {
        AudioServicesPlaySystemSound(1104)
        selectButton(buttonName: nil) //Deselect operator buttons
        if (lastButtonPressedTagNumber == 10){ //If last button pressed was equals, erase the numOperator.
            numOperator = ""
        }
        clearButton.setTitle("C", for: .normal)
        numberString += "\(sender.tag)"
        updateNumberLabel(numberString)
    }
    
    @IBAction func button0(_ sender: UIButton) {
        AudioServicesPlaySystemSound(1104)
        selectButton(buttonName: nil) //Deselect operator buttons
        lastButtonPressedTagNumber = sender.tag
        if (isDecimalPressed){ //Check for decimal. Add the 0 then stop.
            numberString += "0"
            numberLabel.text = numberString
            return
        }
        if (numberString != "" && numberString != "0" && numberString != "-0"){ //If string is not nothing and not 0, add the 0.
            numberString += "0"
            updateNumberLabel(numberString)
        } else if (numberString != "-0"){ //If not -0, decimal isn't pressed and string is nothing or 0, update label with 0.
            updateNumberLabel("0")
        }
    }
    @IBAction func buttonDecimal(_ sender: UIButton) {
        AudioServicesPlaySystemSound(1104)
        selectButton(buttonName: nil) //Deselect operator buttons
        lastButtonPressedTagNumber = sender.tag
        if (!isDecimalPressed){
            isDecimalPressed = true
            clearButton.setTitle("C", for: .normal)
            if (numberString.hasPrefix("-")){
                numberString += "."
            }
            else if (numberString == "" || Double(numberString) == 0){
                numberString = "0."
            } else {
                numberString += "."
            }
        }
        numberLabel.text = numberString
    }
    
    //MARK: - Operator Buttons
    /***************************************************************/
    
    @IBAction func buttonClear(_ sender: UIButton) {
        AudioServicesPlaySystemSound(1104)
        if (lastButtonPressedTagNumber == 10){
            numOperator = ""
        }
        lastButtonPressedTagNumber = sender.tag
        isDecimalPressed = false
        numberString = ""
        updateNumberLabel("0")
        if (clearButton.title(for: .normal) == "C"){
            clearButton.setTitle("AC", for: .normal)
            if (lastButtonPressedTagNumber != 10){ //If last pressed was not equals...
                switch numOperator { //Highlight the operator button that was previously pressed.
                case "Divide":
                    selectButton(buttonName: divideButton)
                case "Multiply":
                    selectButton(buttonName: multiplyButton)
                case "Minus":
                    selectButton(buttonName: minusButton)
                case "Plus":
                    selectButton(buttonName: plusButton)
                default:
                    return
                }
            }
        } else {
            selectButton(buttonName: nil) //Deselect operator buttons
            numOperator = ""
            firstNumber  = nil
            secondNumber  = nil
            result = 0
        }
    }
    @IBAction func buttonInvertSign(_ sender: UIButton) {
        AudioServicesPlaySystemSound(1104)
        lastButtonPressedTagNumber = sender.tag
        if (numberString == "-0"){
            numberString = "0"
        }
        else if (numberString == "" && result == 0){
            numberString = "-0"
        }
        else if (numberString == "" && result != 0){
            result *= -1
            updateNumberLabel("\(result)")
            return
        } else if (numberString.hasPrefix("-")){
            numberString.remove(at: numberString.startIndex)
        } else {
            numberString.insert("-", at: numberString.startIndex)
        }
        updateNumberLabel(numberString)
    }
    @IBAction func buttonPercent(_ sender: UIButton) {
        AudioServicesPlaySystemSound(1104)
        lastButtonPressedTagNumber = sender.tag
        numOperator = "Divide" //Set to divide and second num to 100 so if = is hit next the operation is repeated.
        secondNumber = 100
        result = (Double(numberString) ?? result) / 100
        updateNumberLabel(String(result))
        numberString = ""
    }
    @IBAction func buttonOperator(_ sender: UIButton) {
        AudioServicesPlaySystemSound(1104)
        lastButtonPressedTagNumber = sender.tag
        var operation = ""
        switch sender.tag {
        case 14:
            operation = "Divide"
            selectButton(buttonName: divideButton)
        case 13:
            operation = "Multiply"
            selectButton(buttonName: multiplyButton)
        case 12:
            operation = "Minus"
            selectButton(buttonName: minusButton)
        case 11:
            operation = "Plus"
            selectButton(buttonName: plusButton)
        default:
            return
        }
        performOperation(operation)
    }
    
    @IBAction func buttonEquals(_ sender: UIButton) {
        AudioServicesPlaySystemSound(1104)
        equals()
        selectButton(buttonName: nil) //Deselect operator buttons
        lastButtonPressedTagNumber = sender.tag
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        neutralColor = divideButton.backgroundColor
        buttons.append(divideButton)
        buttons.append(multiplyButton)
        buttons.append(minusButton)
        buttons.append(plusButton)
    }
    
    func equals(){
        secondNumber = Double(numberString) ?? secondNumber ?? firstNumber ?? 0
        print(firstNumber ?? result, " \(numOperator) ", secondNumber!)
        switch numOperator { //If no first number was specified, then use the result of the previous calculation.
        case "Divide":
            result = (firstNumber ?? result) / (secondNumber!)
        case "Multiply":
            result = (firstNumber ?? result) * (secondNumber!)
        case "Minus":
            result = (firstNumber ?? result) - (secondNumber!)
        case "Plus":
            result = (firstNumber ?? result) + (secondNumber!)
        default: //If user just hits enter, show the current displayed number or last result.
            result = secondNumber ?? result
        }
        print(result) //Hitting equals clears the following variables:
        isDecimalPressed = false
        firstNumber = nil
        numberString = ""
        updateNumberLabel(String(result))
    }
    func performOperation(_ operationType: String){
        print(operationType)
        print(lastButtonPressedTagNumber)
        if (numOperator == operationType && numberString != ""){
            print("call equals")
            equals()
        } else {
            print("set first num")
            numOperator = operationType
            firstNumber = Double(numberString) ?? firstNumber ?? result
            numberString = ""
        }
    }
    func updateNumberLabel(_ numString: String){
        let numToDisplay: Double = Double(numString)!
        let upperLimit: Double = 100000000
        let formatter: NumberFormatter = NumberFormatter()
        
        if (numToDisplay > upperLimit){
            formatter.numberStyle = .scientific
            formatter.positiveFormat = "0.###E+0"
            formatter.exponentSymbol = "e"
            numberLabel.text = formatter.string(for: Double(numString)!)
        } else {
            formatter.numberStyle = .decimal
            let num: NSNumber = NSNumber(value: Double(numString) ?? 0)
            numberLabel.text = formatter.string(for: num)
        }
    }
    
    func selectButton(buttonName: UIButton?){
        for i in 0..<buttons.count {
            let button = buttons[i]
            button.layer.backgroundColor = neutralColor!.cgColor
            button.setTitleColor(highlightedColor, for: .normal)
        }
        buttonName?.layer.backgroundColor = highlightedColor.cgColor
        buttonName?.setTitleColor(neutralColor, for: .normal)
    }
}
