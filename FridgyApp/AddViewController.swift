//
//  AddViewController.swift
//  FridgyApp
//
//  Created by Noah Taggart on 2024-11-06.
//

import UIKit

class AddViewController: UIViewController {
    
    
    //MARK: Outlets
    @IBOutlet weak var imageView: UIImageView!
    
    @IBOutlet weak var nameField: UITextField!
    
    @IBOutlet weak var quantityField: UITextField!
    
    @IBOutlet weak var datePicker: UIDatePicker!
    
    @IBOutlet weak var notes: UITextView!
    
    //MARK: Actions
    
    @IBAction func typeButtonClicked(_ sender: UIButton) {
    }
    
    
    @IBAction func addItemClicked(_ sender: UIButton) {
    }
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(importPicture))
        imageView.addGestureRecognizer(tapGesture)
    }
    
    //MARK: Camera and Photo Library

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
    
    //MARK: UI Setup
    private func setupUI() {
        //round corners and add borders
        notes.layer.cornerRadius = 40
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
