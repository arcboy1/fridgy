//
//  AddViewController.swift
//  FridgyApp
//
//  Created by Noah Taggart on 2024-11-06.
//

import UIKit

class AddViewController: UIViewController {
    //MARK: PROPERTIES
    var fridgeStore: FridgeStore!
    var expiry=Date()
    var passedItem:FridgeItem?

    
    let filterOptions: [FridgeType] = [.drinks, .condiments, .food, .snacks, .fruit, .vegetable, .meat, .dairy, .dessert, .other]
    
    
    //MARK: OUTLETS
    @IBOutlet weak var addButton: UIButton!
    @IBOutlet weak var imageView: UIImageView!
    
    @IBOutlet weak var nameField: UITextField!
    
    @IBOutlet weak var quantityField: UITextField!
    
    @IBOutlet weak var datePicker: UIDatePicker!
    
    @IBOutlet weak var notes: UITextView!
    @IBOutlet weak var filterButton: UIButton!
    
    //MARK: ACTIONS
    
    @IBAction func datePicked(_ sender: UIDatePicker) {
        expiry=sender.date
    }
    
    @IBAction func typeButtonClicked(_ sender: UIButton) {
        print("Filter button clicked")
        let actions = filterOptions.map { type in
            UIAction(title: type.rawValue, handler: { _ in
                self.filterButton.setTitle(type.rawValue, for: .normal)

            })
        }
            
        // create menu with the actions
        let menu = UIMenu(title: "Select Filter", children: actions)
        filterButton.menu = menu
        filterButton.showsMenuAsPrimaryAction = true
    }
    
    
    @IBAction func addItemClicked(_ sender: UIButton) {
        // guard statements to validate info
        guard let name = nameField.text, !name.isEmpty else {
            showAlertWithMessage(message: "Please enter a name for this item")
            return
        }

        guard let quantityText = quantityField.text, let quantity = Int(quantityText), quantity > 0 else {
            showAlertWithMessage(message: "Please enter a valid quantity")
            return
        }

        // get the selected date from the date picker
        let selectedDate = datePicker.date

        // ensure a type is selected
        guard let selectedTypeTitle = filterButton.title(for: .normal),
              let selectedType = FridgeType(rawValue: selectedTypeTitle) else {
            showAlertWithMessage(message: "Please select a type for this inventory item")
            return
        }

        // get the notes text
        let notesText = notes.text ?? ""

        // handle the item update or creation logic
        if let passedItem = passedItem {
            // update existing item
            passedItem.name = name
            passedItem.quantity = quantity
            passedItem.expirationDate = selectedDate
            passedItem.details = notesText
            passedItem.type = selectedType

            // update the image if one has been selected
            if let image = imageView.image {
                fridgeStore.saveImage(image: image, withIdentifier: passedItem.id)
            }

            // save changes to the fridge store
            fridgeStore.saveItems()
            
            removePendingNotifications(for: passedItem)
            
        } else {
            // create a new FridgeItem if were not editing/updating
            let newItem = FridgeItem(name: name, quantity: quantity, currentDate: Date(), expirationDate: selectedDate, details: notesText, type: selectedType)

            // save the image if one has been selected
            if let image = imageView.image {
                fridgeStore.saveImage(image: image, withIdentifier: newItem.id)
            }

            // add the new item to the fridge store
            fridgeStore.addNewItem(item: newItem)
            
            removePendingNotifications(for: newItem)
        }

        // navigate back to the previous screen
        navigationController?.popViewController(animated: true)
    }
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        imageView.isUserInteractionEnabled=true
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(importPicture))
        imageView.addGestureRecognizer(tapGesture)
        
        let dismissKeyboardTap = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        view.addGestureRecognizer(dismissKeyboardTap)
        
        //initialize passed item to proper fields
        if let passedItem = passedItem {
            nameField.text = passedItem.name
            quantityField.text = "\(passedItem.quantity)"
            datePicker.date = passedItem.expirationDate
            notes.text = passedItem.details
            addButton.setTitle("Update Item", for: .normal)
            // fetch the image for the passed item
            if let fetchedImage = fridgeStore.fetchImage(withIdentifier: passedItem.id) {
                imageView.image = fetchedImage
            } else {
                imageView.image = UIImage(named: "selectimage") // set default image if none found
            }

            filterButton.setTitle(passedItem.type.rawValue, for: .normal)
        }
    }
    
    //MARK: CAMERA AND PHOTO LIBRARY

    // method to import a picture from the camera or photo library
    @objc func importPicture() {
        let imagePicker = UIImagePickerController()
        
        imagePicker.allowsEditing = true
        
        imagePicker.delegate = self
        
        //present action sheet to choose between camera or photo library
        let actionSheet = UIAlertController(title: "Select Image Source", message: nil, preferredStyle: .actionSheet)
        
        if UIImagePickerController.isSourceTypeAvailable(.camera){
            let cameraAction = UIAlertAction(title: "Camera", style: .default){[weak self] _ in
                
                imagePicker.sourceType = .camera
                self?.present(imagePicker, animated:  true)
            }
            actionSheet.addAction(cameraAction)
        }
        
        let photoLibrary = UIAlertAction(title: "Photo Library", style: .default){ [weak self] _ in
            imagePicker.sourceType = .photoLibrary
            self?.present(imagePicker, animated:  true)
            
        }
        
        actionSheet.addAction(photoLibrary)
        
        present(actionSheet, animated: true)
    }
    
    //MARK: UI SETUP
    private func setupUI() {
        self.navigationController?.navigationBar.tintColor = UIColor(named: "darkBlue")
        //round corners and add borders
        notes.layer.cornerRadius = 30
        notes.layer.masksToBounds = true
        
        nameField.layer.cornerRadius = 15
        nameField.layer.masksToBounds = true
        
        quantityField.layer.cornerRadius = 15
        quantityField.layer.masksToBounds = true
        
        imageView.layer.cornerRadius = 10
        imageView.layer.masksToBounds = true
        imageView.layer.borderColor = UIColor.white.cgColor
        imageView.layer.borderWidth = 2.0
    }
    
    //MARK: - ERROR MSGS
    func showAlertWithMessage(message: String){
        let alert = UIAlertController(title: NSLocalizedString("Missing information", comment: "missingText"), message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .cancel))
        present(alert, animated: true)
    }
    
    //MARK: NAVIGATION
    // method to remove pending notifications for the item
    func removePendingNotifications(for item: FridgeItem) {
        let center = UNUserNotificationCenter.current()
        center.getPendingNotificationRequests { requests in
            let identifiersToRemove = requests.compactMap { request -> String? in
                return request.identifier.hasPrefix(item.id) ? request.identifier : nil
            }
            center.removePendingNotificationRequests(withIdentifiers: identifiersToRemove)

            // after removing notifications, schedule the new notifications
            self.scheduleNotifications(for: item)
        }
    }

    // combined method to schedule both notifications
    func scheduleNotifications(for item: FridgeItem) {
        
        // check if the item is expired
        guard item.expirationDate > Date() else {
            print("cannot schedule notifications: item has already expired.")
            return
        }

        // schedule expiration notification
        let expirationContent = UNMutableNotificationContent()
        expirationContent.title = "Item Expired"
        expirationContent.body = "The item '\(item.name)' has expired."
        expirationContent.sound = .default

        let expirationTrigger = UNTimeIntervalNotificationTrigger(timeInterval: item.expirationDate.timeIntervalSinceNow, repeats: false)
        // ensure the time interval is valid
        guard expirationTrigger.timeInterval > 0 else {
            print("cannot schedule expiration notification: time interval must be greater than 0.")
            return
        }

        let expirationRequest = UNNotificationRequest(identifier: "\(item.id)_expiration", content: expirationContent, trigger: expirationTrigger)
        let center = UNUserNotificationCenter.current()
        center.add(expirationRequest) { error in
            if let error = error {
                print("error scheduling expiration notification: \(error.localizedDescription)")
            } else {
                print("expiration notification scheduled successfully")
            }
        }

        // schedule nearing expiration notification (3 days before expiration)
        let nearingExpirationContent = UNMutableNotificationContent()
        nearingExpirationContent.title = "Item Expiration Reminder"
        nearingExpirationContent.body = "The item '\(item.name)' is close to expiring in 3 days."
        nearingExpirationContent.sound = .default

        let threeDaysBefore = Calendar.current.date(byAdding: .day, value: -3, to: item.expirationDate)
        // check if three days before is in the future
        guard let threeDaysBeforeDate = threeDaysBefore, threeDaysBeforeDate > Date() else {
            print("cannot schedule nearing expiration notification: item is expiring within 3 days.")
            return
        }

        let nearingExpirationTrigger = UNTimeIntervalNotificationTrigger(timeInterval: threeDaysBeforeDate.timeIntervalSinceNow, repeats: false)
        // ensure the time interval is valid
        guard nearingExpirationTrigger.timeInterval > 0 else {
            print("cannot schedule nearing expiration notification: time interval must be greater than 0.")
            return
        }

        let nearingExpirationRequest = UNNotificationRequest(identifier: "\(item.id)_nearing_expiration", content: nearingExpirationContent, trigger: nearingExpirationTrigger)
        center.add(nearingExpirationRequest) { error in
            if let error = error {
                print("error scheduling nearing expiration notification: \(error.localizedDescription)")
            } else {
                print("nearing expiration notification scheduled successfully")
            }
        }
    }
    
    @objc func dismissKeyboard() {
        view.endEditing(true)
    }

}

//MARK: Extension Methods
extension AddViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    // delegate method for when an image is picked

    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        guard let image = info[.editedImage] as? UIImage else { return }
        dismiss(animated: true)
        imageView.image = image // set the selected image to the imageView
    }
   
}
