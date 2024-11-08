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
    
    var currentItems: [FridgeItem] = []
    
    var isAscendingOrder = true // true for ascending, false for descending
    
    var currentFilterType: FridgeType = .allItems
    
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
                self.currentFilterType = type
                self.createSnapshot(for: type)
            })
        }
        
        // create menu with the actions
        let menu = UIMenu(title: "Select Filter", children: actions)
        filterButton.menu = menu
        filterButton.showsMenuAsPrimaryAction = true
    }
    
    
    
    
    //MARK: VIEW METHODS

    override func viewDidLoad() {
        super.viewDidLoad()
        pickerView.delegate = self
        pickerView.dataSource = self
        collectionView.delegate=self
        createSnapshot(for: .allItems)
        
        let longPressGesture = UILongPressGestureRecognizer(target: self, action: #selector(handleLongPress))
        collectionView.addGestureRecognizer(longPressGesture)
        
        
        let center = UNUserNotificationCenter.current()

        center.requestAuthorization(options: [.alert, .badge, .sound]) { granted, error in
            if granted {
                print("Access for notifications is granted")
            } else {
                print("Notifications permission denied")
            }
            
            if let error = error {
                print("Error requesting notifications permissions: \(error.localizedDescription)")
            }
        }
        
        center.getPendingNotificationRequests(completionHandler: {
            requests in
            print(requests)
        })
        
    }
    
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        createSnapshot(for: .allItems)
        }
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        collectionView.reloadData()
        filterButton.setTitle("All Items", for: .normal)
        currentFilterType = .allItems
    }
    
    
    //MARK: - DATASOURCE METHODS
    private lazy var collectionViewDataSource = UICollectionViewDiffableDataSource<FridgeType, FridgeItem>(collectionView: collectionView) { collectionView, indexPath, itemIdentifier in
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "fridgeCell", for: indexPath) as! CustomCollectionViewCell
        
        // set up cells
        cell.itemName.text = itemIdentifier.name
        cell.quantity.text = "Quantity: \(itemIdentifier.quantity)"
        
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
        if type == .allItems {
            currentItems = fridgeStore.allItems.sorted {
                isAscendingOrder ? $0.expirationDate < $1.expirationDate : $0.expirationDate > $1.expirationDate
            }
        } else {
            currentItems = fridgeStore.allItems.filter { $0.type == type }.sorted {
                isAscendingOrder ? $0.expirationDate < $1.expirationDate : $0.expirationDate > $1.expirationDate
            }
        }
        
        // add filtered items to the snapshot for the specified section
        snapshot.appendItems(currentItems, toSection: type)
        
        collectionViewDataSource.apply(snapshot, animatingDifferences: true)
    }
    
    //MARK: NAVIGATION
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        guard let destination = segue.destination as? AddViewController else { return }
        destination.fridgeStore=fridgeStore
        if segue.identifier == "showDetail" {
                if let indexPath = collectionView.indexPathsForSelectedItems?.first {
                    let snapshot = collectionViewDataSource.snapshot()
                    // get the item for the selected index path
                    let item = snapshot.itemIdentifiers[indexPath.item]
                    destination.passedItem = item
                }
            }

        }
    
    //MARK: NOTIFICATIONS
    func removeNotifications(for item: FridgeItem) {
        let center = UNUserNotificationCenter.current()
        // remove pending notifications for the item
        center.getPendingNotificationRequests { requests in
            let identifiersToRemove = requests.compactMap { request -> String? in
                return request.identifier.hasPrefix(item.id) ? request.identifier : nil
            }
            center.removePendingNotificationRequests(withIdentifiers: identifiersToRemove)
            print("Removed notifications for item: \(item.name)")
        }
    }
    
    //MARK: GESTURES
    //shake to change sort ascending/descending
    override func motionEnded(_ motion: UIEvent.EventSubtype, with event: UIEvent?) {
        if motion == .motionShake {
            // Toggle sorting order
            isAscendingOrder.toggle()
            print("Sorting order changed: \(isAscendingOrder ? "Ascending" : "Descending")")
            
            // refresh the snapshot with the current filter type
            createSnapshot(for: currentFilterType)
        }
    }
    
    @objc func handleLongPress(gesture: UILongPressGestureRecognizer) {
        let point = gesture.location(in: collectionView)
        guard let indexPath = collectionView.indexPathForItem(at: point), gesture.state == .began else { return }

        // get the item to delete from currentItems
        let itemToDelete = currentItems[indexPath.item]
        
        let alert = UIAlertController(title: "Manage Item", message: "What would you like to do with \(itemToDelete.name)?", preferredStyle: .alert)
        
        // delete
        alert.addAction(UIAlertAction(title: "Delete", style: .destructive, handler: { _ in
            self.fridgeStore.removeItem(item: itemToDelete)
            self.createSnapshot(for: self.currentFilterType) // update the snapshot based on the current filter type
            self.removeNotifications(for: itemToDelete)
        }))
        
        // remove 1
        alert.addAction(UIAlertAction(title: "Remove 1", style: .default, handler: { _ in
            itemToDelete.quantity -= 1
            
            // if quantity 0 then remove the item
            if itemToDelete.quantity <= 0 {
                self.fridgeStore.removeItem(item: itemToDelete)
                self.removeNotifications(for: itemToDelete)
            } else {
                self.fridgeStore.saveItems()
            }
            
            // refresh collection
            self.createSnapshot(for: self.currentFilterType)

            self.collectionView.reloadData()
        }))
        
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        
        present(alert, animated: true)
    }
    
    
    
    
    

}

//MARK: EXTENSION METHODS
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
extension ViewController: UICollectionViewDelegateFlowLayout {
    
    // no space between rows
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 10
    }
    
    // space between items
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 5
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: 170, height: 170)
    }
    
}

extension ViewController: UICollectionViewDelegate{
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        // deselect the item immediately after it's tapped
        collectionView.deselectItem(at: indexPath, animated: true)
    }
    
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        collectionView.collectionViewLayout.invalidateLayout()
    }
   
}
