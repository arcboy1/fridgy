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
        
        //rounded corners for cell
        self.layer.cornerRadius = 20
        self.layer.masksToBounds = true

        //round corners of image view
//        itemImageView.layer.cornerRadius = 10
//        itemImageView.layer.masksToBounds = true
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
