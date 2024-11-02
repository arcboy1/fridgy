//
//  ViewController.swift
//  FridgyApp
//
//  Created by Noah Taggart on 2024-09-25.
//

import UIKit

class ViewController: UIViewController {
    
    //MARK: OUTLETS

    @IBOutlet weak var filterButton: UIButton!
    
    //MARK: PROPERTIES
    
    //instance of UIPickerView
    let pickerView = UIPickerView()

    let filterOptions: [FridgeType] = [.allItems, .drinks, .condiments, .food, .snacks, .fruit, .vegetable, .meat, .dairy, .dessert, .other]

    override func viewDidLoad() {
        super.viewDidLoad()
        pickerView.delegate = self
        pickerView.dataSource = self
        filterButton.addTarget(self, action: #selector(showPicker), for: .touchUpInside)
        

    }
    
    //method that displays the UIPickerView when the user selects the button
    @objc func showPicker() {
        // creates alert to show picker as action
        let alertController = UIAlertController(title: "Select Filter", message: "\n\n\n\n\n\n", preferredStyle: .actionSheet)
        
        // add the pickerView as a subview of the alert
        pickerView.frame = CGRect(x: 0, y: 50, width: alertController.view.bounds.width, height: 150)
        alertController.view.addSubview(pickerView)
        
        alertController.addAction(UIAlertAction(title: "Done", style: .default, handler: { _ in
            let selectedRow = self.pickerView.selectedRow(inComponent: 0)
            
            // get the selected FridgeType and set button title to its raw value
            let selectedType = self.filterOptions[selectedRow]
            self.filterButton.setTitle(selectedType.rawValue, for: .normal)
            // TODO: add filter functionality
            
        }))
        
        present(alertController, animated: true, completion: nil)
    }
    


}
extension ViewController: UIPickerViewDelegate, UIPickerViewDataSource {
    
    //methods for supplying data to pickerview and controlling its appearance/text
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return filterOptions.count
    }
    
    //display string value of enum
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return filterOptions[row].rawValue
        }
}
