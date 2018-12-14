//  AddBMIViewController.swift
//  IOSMP-FinalTest
//  App Description: A simple BMI Calculator using core data
//
//  Created by Jose Aleixo Porpino Filho on 2018-12-13.
//  Student ID 301005491
//
//  Version 1.0.0


import UIKit
import CoreData

class AddBMIViewController: UIViewController, UIPickerViewDelegate, UIPickerViewDataSource  {
    
    var managedContext: NSManagedObjectContext!
    var calculation: Calculation?

    @IBOutlet weak var unitSegmented: UISegmentedControl!
    @IBOutlet weak var nameTextView: UITextField!
    @IBOutlet weak var ageTextView: UITextField!
    @IBOutlet weak var genderPicker: UIPickerView!
    @IBOutlet weak var weightTextView: UITextField!
    @IBOutlet weak var heightTextView: UITextField!
    
    @IBOutlet weak var cancelButton: UIButton!
    @IBOutlet weak var calculateButton: UIButton!
    
    
    let gender = ["Female","Male"]
    var genderSelected = "Female"

    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.hideKeyboardWhenTappedAround()
        genderPicker.delegate = self
        genderPicker.dataSource = self
        
        // Set the buttons with rounds
        calculateButton.layer.cornerRadius = 10
        calculateButton.clipsToBounds = true
        cancelButton.layer.cornerRadius = 10
        cancelButton.clipsToBounds = true
        
        // Get the calculation if existent from another screen
        if let calculation = calculation {
            unitSegmented.selectedSegmentIndex = Int(calculation.unit)
            nameTextView.text = calculation.name
            ageTextView.text = "\(calculation.age)"
            //gender
            weightTextView.text = "\(calculation.weight)"
            heightTextView.text = "\(calculation.height)"
            if calculation.gender == "Female"{
                genderPicker.selectRow(0, inComponent: 0, animated: true)
            } else {
                genderPicker.selectRow(1, inComponent: 0, animated: true)
            }
            
        }
    }
    
    
    
    @IBAction func onClickCancel() {
        dismiss()
    }
    @IBAction func onClickCalculate(_ sender: UIButton) {
        if let calculation = self.calculation {
            setCalculationValues(calculation)
        } else {
            let calculation = Calculation(context: managedContext)
            calculation.date = Date()
            setCalculationValues(calculation)
        }
        
        do {
            try managedContext.save()
            dismiss()
        } catch {
            print("Error when try to save: \(error)")
        }
    }
    
    // Dismiss the screen
    func dismiss() {
        dismiss(animated: true)
    }
    
    // Set the properties of the calculations according to the functionality
    func setCalculationValues(_ calculation:Calculation) {
        calculation.name = nameTextView.text
        calculation.age = Int16(ageTextView.text!) ?? 0
        calculation.height = Double(heightTextView.text!) ?? 0.0
        calculation.weight = Double(weightTextView.text!) ?? 0.0
        calculation.unit = Int16(unitSegmented.selectedSegmentIndex)
        calculation.gender = genderSelected
        calculateBMI(calculation)
    }
    
    func calculateBMI(_ calculation:Calculation) {
        
        let weight:Double = calculation.weight
        let height:Double = calculation.height
        
        if calculation.unit == 0 {
            calculation.bmi = (weight * 703) / pow(height, 2)
        } else {
            calculation.bmi = weight / pow(height, 2)
        }
        
        let bmi:Double = calculation.bmi
        
        if bmi < 16 {
            calculation.category = "Severe sickness"
        } else if bmi >= 16 && bmi <= 17 {
            calculation.category = "Moderate thiness"
        } else if bmi > 17 && bmi <= 18.5 {
            calculation.category = "Mild thiness"
        } else if bmi > 18.5 && bmi <= 25 {
            calculation.category = "Normal"
        } else if bmi > 25 && bmi <= 30 {
            calculation.category = "Overweight"
        } else if bmi > 30 && bmi <= 35 {
            calculation.category = "Obese class I"
        } else if bmi > 35 && bmi <= 40 {
            calculation.category = "Obese class II"
        } else if bmi > 40 {
            calculation.category = "Obese class III"
        }
    }
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return gender.count
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return gender[row]
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        genderSelected = gender[row] as String
    }
    
}

// Extension to hide the keyboard if tap in the screen
extension UIViewController {
    func hideKeyboardWhenTappedAround() {
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(UIViewController.dismissKeyboard))
        tap.cancelsTouchesInView = false
        view.addGestureRecognizer(tap)
    }
    
    @objc func dismissKeyboard() {
        view.endEditing(true)
    }
}
