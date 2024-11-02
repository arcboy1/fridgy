//
//  CustomTableViewCell.swift
//  FridgyApp
//
//  Created by Noah Taggart on 2024-11-02.
//

import Foundation
import UIKit


class CustomTableViewCell: UITableViewCell {
    

    @IBOutlet weak var itemImageView: UIImageView!
    
    @IBOutlet weak var itemName: UILabel!
    
    @IBOutlet weak var quantity: UILabel!
    
    @IBOutlet weak var expiration: UILabel!
    
    @IBOutlet weak var animationView: UIView!
    
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
