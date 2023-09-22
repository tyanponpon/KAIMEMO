//
//  MainTableViewCell.swift
//  KAIWASURE
//
//  Created by 藤崎花音 on 2023/01/20.
//

import UIKit

class MainTableViewCell: UITableViewCell {
   
    @IBOutlet weak var categorylabel: UILabel!
    @IBOutlet weak var itemlabel: UILabel!
    @IBOutlet weak var itemImageView: UIImageView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
