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
    
    @IBOutlet weak var collectionView: UICollectionView!
    
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
        titleLabel.text = "Fridgy Inventory"

        if let customFont = UIFont(name: "PlaywriteDEGrund-VariableFont_wght", size: 17) {
            titleLabel.font = UIFontMetrics(forTextStyle: .title1).scaledFont(for: customFont)
        } else {
            print("Custom font failed to load")
        }

        titleLabel.textColor = .white
        
        navigationItem.titleView = titleLabel
        super.viewDidLoad()
        pickerView.delegate = self
        pickerView.dataSource = self
        collectionView.delegate=self
        createSnapshot(for: .allItems)
        
    }
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
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
                cell.itemImageView.image = UIImage(named: "placeholderimage")
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


//MARK: - Extension Methods

//sets layout for collectionview cells
extension ViewController: UICollectionViewDelegateFlowLayout {
    
    // no space between rows
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 10
    }
    
    // space between items
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 10
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
