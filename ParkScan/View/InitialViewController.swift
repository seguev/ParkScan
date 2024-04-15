//
//  ViewController.swift
//  ParkScan
//
//  Created by segev perets on 15/03/2024.
//

import UIKit

class InitialViewController: UIViewController, UIPickerViewDataSource, UIPickerViewDelegate {
    
    
    
    
    var pickerOptions: [Int] {
        return Array(1...20)
    }
    
    
    @IBOutlet weak var pickerView: UIPickerView!
    override func viewDidLoad() {
        super.viewDidLoad()
        
    }
    
    
    //MARK: - DataSource functions
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return pickerOptions.count
    }
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        pickerOptions[row].description
    }
    
    //MARK: - Delegate functions
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        UserData.shared.parkingNum = pickerOptions[row]
    }

}

