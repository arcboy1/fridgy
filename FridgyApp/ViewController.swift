//
//  ViewController.swift
//  FridgyApp
//
//  Created by Noah Taggart on 2024-09-25.
//

import UIKit

class ViewController: UIViewController {
    
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
    
    
    //MARK: OUTLETS

    @IBOutlet weak var filterButton: UIButton!
    
    @IBOutlet weak var collectionView: UICollectionView!
    
    //MARK: ACTIONS
    @IBAction func filterPressed(_ sender: UIButton) {
        let actions = filterOptions.map { type in
            UIAction(title: type.rawValue, handler: { _ in
                self.filterButton.setTitle(type.rawValue, for: .normal)
                self.createSnapshot(for: type)
            })
        }
            
        // create menu with the actions
        let menu = UIMenu(title: "Select Filter", children: actions)
        filterButton.menu = menu
        filterButton.showsMenuAsPrimaryAction = true
    }
    
    
    
    
    //MARK: View methods

    override func viewDidLoad() {
        super.viewDidLoad()
        pickerView.delegate = self
        pickerView.dataSource = self
        collectionView.delegate=self
        createSnapshot(for: .allItems)
        
        let longPressGesture = UILongPressGestureRecognizer(target: self, action: #selector(handleLongPress))
        collectionView.addGestureRecognizer(longPressGesture)
        
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        createSnapshot(for: .allItems)
        }
    
    
    
    //MARK: - Datasource methods
    private lazy var collectionViewDataSource = UICollectionViewDiffableDataSource<FridgeType, FridgeItem>(collectionView: collectionView) { collectionView, indexPath, itemIdentifier in
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "fridgeCell", for: indexPath) as! CustomCollectionViewCell
        
        // set up cells
        cell.itemName.text = itemIdentifier.name
        cell.quantity.text = "\(itemIdentifier.quantity)"
        
        // fetch and assign the image
        if let itemImage = self.fridgeStore.fetchImage(withIdentifier: itemIdentifier.id) {
            cell.itemImageView.image = itemImage
        } else {
            cell.itemImageView.image = UIImage(named: "selectimage")
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
            filteredItems = fridgeStore.allItems // default to all items
        } else {
            filteredItems = fridgeStore.allItems.filter { $0.type == type }
        }
        
        // add filtered items to the snapshot for the specified section
        snapshot.appendItems(filteredItems, toSection: type)
        
        collectionViewDataSource.apply(snapshot, animatingDifferences: true)
    }
    
    //MARK: NAVIGATION
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        guard let destination = segue.destination as? AddViewController else { return }
        destination.fridgeStore=fridgeStore
        if segue.identifier == "showDetail" {
                // Get the selected index path from the collection view
                if let indexPath = collectionView.indexPathsForSelectedItems?.first {
                    // Access the snapshot from the data source
                    let snapshot = collectionViewDataSource.snapshot()
                    
                    // Get the item for the selected index path
                    let item = snapshot.itemIdentifiers[indexPath.item]
                    
                    // Pass the selected item to the destination
                    destination.passedItem = item
                }
            }

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

//sets layout for collectionview cells
//extension ViewController: UICollectionViewDelegateFlowLayout {
    
//    // no space between rows
//    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
//        return 10
//    }
//    
//    // space between items
//    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
//        return 10
//    }
//    
//}

extension ViewController: UICollectionViewDelegate{
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        // deselect the item immediately after it's tapped
        collectionView.deselectItem(at: indexPath, animated: true)
    }
    // handle long press to delete item
    @objc func handleLongPress(gesture: UILongPressGestureRecognizer) {
        let point = gesture.location(in: collectionView)
        guard let indexPath = collectionView.indexPathForItem(at: point), gesture.state == .began else { return }

        // confirm deletion
        let itemToDelete = fridgeStore.allItems[indexPath.item]
        let alert = UIAlertController(title: "Delete Item", message: "Are you sure you want to delete \(itemToDelete.name)?", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        alert.addAction(UIAlertAction(title: "Delete", style: .destructive, handler: { _ in
            self.fridgeStore.removeItem(item: itemToDelete)
            self.createSnapshot(for: .allItems)
        }))
        present(alert, animated: true)
    }
    
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        collectionView.collectionViewLayout.invalidateLayout()
    }
   
}
