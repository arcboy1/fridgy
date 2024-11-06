//
//  CustomCollectionViewCell.swift
//  FridgyApp
//
//  Created by Noah Taggart on 2024-11-06.
//

import Foundation
import UIKit

class CustomCollectionViewCell: UICollectionViewCell {
    
    // MARK: Outlets
    @IBOutlet weak var itemName: UILabel!
    
    @IBOutlet weak var quantity: UILabel!
    
    @IBOutlet weak var animationView: ExpirationProgressView!
    
    @IBOutlet weak var itemImageView: UIImageView!
    override func awakeFromNib() {
        super.awakeFromNib()
        
        // rounded corners for the cell
        self.layer.cornerRadius = 20
        self.layer.masksToBounds = true
        
        self.layer.borderColor = UIColor.white.cgColor
        self.layer.borderWidth = 2.0

    }

    // MARK: Animation View methods
    func configureProgress(startDate: Date, expirationDate: Date) {
        animationView.startDate = startDate
        animationView.expirationDate = expirationDate
        animationView.setNeedsDisplay()
    }
}
