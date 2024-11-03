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
    
    @IBOutlet weak var tableView: UITableView!
    
    
    //MARK: PROPERTIES
    var fridgeStore=FridgeStore()
    
    //format for expiration date
    var dateFormatter: DateFormatter = {
        let df = DateFormatter()
        df.dateFormat = "dd/MM/yyyy"
        return df
    }()
    
    //instance of UIPickerView
    let pickerView = UIPickerView()
    
    let filterOptions: [FridgeType] = [.allItems, .drinks, .condiments, .food, .snacks, .fruit, .vegetable, .meat, .dairy, .dessert, .other]
    
    //MARK: View methods

    override func viewDidLoad() {
        
        let titleLabel = UILabel()
        titleLabel.text = "Fridge Inventory"
        titleLabel.font = UIFont(name: "PlaywriteDEGrund-VariableFont_wght", size: 17)
        titleLabel.textColor = .white
        
        navigationItem.titleView = titleLabel
        super.viewDidLoad()
        pickerView.delegate = self
        pickerView.dataSource = self
        filterButton.addTarget(self, action: #selector(showPicker), for: .touchUpInside)
        
        createSnapshot(for: .allItems)
        
    }
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
    }
    
    
    
    //MARK: - Datasource methods
    private lazy var tableDataSource = UITableViewDiffableDataSource<FridgeType, FridgeItem>(tableView: tableView) { tableView, indexPath, itemIdentifier in
        let cell = tableView.dequeueReusableCell(withIdentifier: "fridgeCell", for: indexPath) as! CustomTableViewCell
        
        // set up cells
        cell.itemName?.text = itemIdentifier.name
        cell.quantity?.text = "\(itemIdentifier.quantity)"
        cell.expiration?.text = "\(self.dateFormatter.string(from: itemIdentifier.expirationDate))"
        
        // fetch and assign the image
        if let itemImage = self.fridgeStore.fetchImage(withIdentifier: itemIdentifier.id) {
            cell.itemImageView?.image = itemImage
        } else {
            cell.itemImageView?.image = UIImage(named: "placeholderimage")
        }
        
        cell.configureProgress(startDate: itemIdentifier.currentDate, expirationDate: itemIdentifier.expirationDate)

        
        
        return cell
    }
    
    func createSnapshot(for type: FridgeType) {
        var snapshot = NSDiffableDataSourceSnapshot<FridgeType, FridgeItem>()
        
        snapshot.appendSections([type])
        
        // filter items based on the selected type
        let filteredItems: [FridgeItem]
        if type == .allItems {
            filteredItems = fridgeStore.allItems //default all items
        } else {
            filteredItems = fridgeStore.allItems.filter { $0.type == type }
        }
        
        // add filtered items to the snapshot for the specified section
        snapshot.appendItems(filteredItems, toSection: type)
        
    
        tableDataSource.applySnapshotUsingReloadData(snapshot)
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
            
            self.createSnapshot(for: selectedType)
            
        }))
        
        present(alertController, animated: true, completion: nil)
    }
    


}

//MARK: Extension methods
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
