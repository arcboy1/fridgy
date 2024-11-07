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
        
        imageView.isUserInteractionEnabled = true
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(importPicture))
        imageView.addGestureRecognizer(tapGesture)
    }

    // method to import a picture from the camera or photo library
    @objc func importPicture() {
        let picker = UIImagePickerController()
        
        // check if the camera is available
        if UIImagePickerController.isSourceTypeAvailable(.camera) {
            // present action sheet to choose between Camera and Photo Library
            let alertController = UIAlertController(title: "Select Image Source", message: nil, preferredStyle: .actionSheet)
            
            alertController.addAction(UIAlertAction(title: "Camera", style: .default, handler: { _ in
                picker.sourceType = .camera
                picker.allowsEditing = true
                picker.delegate = self
                self.present(picker, animated: true)
            }))
            
            alertController.addAction(UIAlertAction(title: "Photo Library", style: .default, handler: { _ in
                picker.sourceType = .photoLibrary
                picker.allowsEditing = true
                picker.delegate = self
                self.present(picker, animated: true)
            }))
            
            alertController.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
            
            present(alertController, animated: true, completion: nil)
        } else {
            //default to photo library
            picker.sourceType = .photoLibrary
            picker.allowsEditing = true
            picker.delegate = self
            present(picker, animated: true)
        }
    }

}
extension AddViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    // delegate method for when an image is picked

    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        guard let image = info[.editedImage] as? UIImage else { return }
        dismiss(animated: true)
        imageView.image = image // set the selected image to the imageView
    }
    // delegate method for when the user cancels the picker
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        dismiss(animated: true)
    }
}
